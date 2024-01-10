import "dart:async";

import "package:aw40_hub_frontend/configs/configs.dart";
import "package:aw40_hub_frontend/exceptions/exceptions.dart";
import "package:aw40_hub_frontend/providers/providers.dart";
import "package:aw40_hub_frontend/services/services.dart";
import "package:aw40_hub_frontend/utils/utils.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";
import "package:routemaster/routemaster.dart";
import "package:universal_html/html.dart" as html;
import "package:webview_flutter/webview_flutter.dart";

const String kKeycloakResetUrlPart = "login-actions/reset-credentials?";
const String kKeycloakAuthUrlPart = "login-actions/authenticate?";

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.currentBrowserUrl, super.key});
  final String? currentBrowserUrl;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Logger _logger = Logger("login_screen");
  Future<String>? _codeChallenge;
  bool _showMobileWebView = true;
  WebViewController? webViewController;
  bool showPasswordResetPage = false;

  @override
  void initState() {
    //call after build is complete
    // ignore: discarded_futures
    WidgetsBinding.instance.addPostFrameCallback((_) => loginProcess());
    super.initState();
  }

  bool get _webIsRedirectedAfterKeycloakLogin {
    if (!kIsWeb) {
      throw AppException(
        exceptionMessage: "KIsWeb == false",
        exceptionType: ExceptionType.other,
      );
    }

    final Iterable<String> queryKeys =
        Routemaster.of(context).currentRoute.queryParameters.keys;

    final bool queryContainsKeycloakData =
        queryKeys.contains("code") && queryKeys.contains("session_state");
    _logger.finer(
      "_webIsRedirectedAfterKeycloakLogin: $queryContainsKeycloakData",
    );

    return queryContainsKeycloakData;
  }

  Future<void> _webProcessKeycloakCodeInBrowserUrl() async {
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    _logger.finest("_webProcessKeycloakCodeInBrowserUrl()");
    if (!kIsWeb) {
      throw AppException(
        exceptionMessage:
            "KIsWeb == false, but called _webProcessKeycloakCodeInBrowserUrl()",
        exceptionType: ExceptionType.other,
      );
    }

    final String? code = webRemoveQueryFromUrlAndReturnKeycloakCode();

    final String? redirectUri = await webRetrieveRedirectUri();
    _logger.info("Retrieved redirectUri: $redirectUri");

    if (code == null) {
      throw AppException(
        exceptionMessage: "code == null",
        exceptionType: ExceptionType.unexpectedNullValue,
      );
    }

    if (redirectUri == null) {
      throw AppException(
        exceptionMessage: "retrieved redirectUri == null",
        exceptionType: ExceptionType.unexpectedNullValue,
      );
    }

    await authProvider.setAuthTokensFromKeycloakCode(
      keycloakCode: code,
      redirectUri: redirectUri,
    );
  }

  Future<void> loginProcess() async {
    _logger.finest("loginProcess()");
    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    final CaseProvider caseProvider =
        Provider.of<CaseProvider>(context, listen: false);
    final DiagnosisProvider diagnosisProvider =
        Provider.of<DiagnosisProvider>(context, listen: false);

    await authProvider.tryLoginWithStoredRefreshToken();

    if (!authProvider.isLoggedIn()) {
      setStateIfMounted(() {
        _codeChallenge = authProvider.generateCodeChallengeAndStoreVerifier();
      });

      if (kIsWeb) {
        if (_webIsRedirectedAfterKeycloakLogin) {
          await _webProcessKeycloakCodeInBrowserUrl();
        } else {
          await _webGoToKeyCloakLogin();
        }
      }
    }
    final String workShopId = authProvider.loggedInUser.workShopId;
    caseProvider.workShopId = workShopId;
    diagnosisProvider.workShopId = workShopId;
  }

  Future<void> _webGoToKeyCloakLogin() async {
    _logger.finest("_webGoToKeyCloakLogin()");
    if (!kIsWeb) {
      throw AppException(
        exceptionMessage: "KIsWeb == false",
        exceptionType: ExceptionType.other,
      );
    }

    final AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    final String langCode = kStartLocale.toString().split("_")[0];

    final String? codeChallengeSnapshot = await _codeChallenge;

    if (codeChallengeSnapshot == null) {
      setStateIfMounted(() {
        _codeChallenge = authProvider.generateCodeChallengeAndStoreVerifier();
      });

      return;
    }

    final String? currentBrowserUrl = widget.currentBrowserUrl;
    _logger.finer("currentBrowserUrl: $currentBrowserUrl");

    if (currentBrowserUrl == null) {
      throw AppException(
        exceptionMessage: "_currentBrowserUrl was null",
        exceptionType: ExceptionType.unexpectedNullValue,
      );
    }

    _logger.info("storing redirectUri: $currentBrowserUrl");
    await webStoreRedirectUri(redirectUri: currentBrowserUrl);

    final String keyCloakLoginUrl = AuthService().generateKeyCloakLoginUrl(
      redirectUri: currentBrowserUrl,
      codeChallenge: codeChallengeSnapshot,
      langCode: langCode,
    );
    _logger.finer("keyCloakLoginUrl: $keyCloakLoginUrl");
    html.window.location.href = keyCloakLoginUrl;
  }

  /// Stores `redirectUri` to local storage.
  Future<void> webStoreRedirectUri({required String redirectUri}) async {
    _logger.finest("webStoreRedirectUri()");
    await StorageService().storeStringToLocalStorage(
      key: LocalStorageKey.redirectUri,
      value: redirectUri,
    );
  }

  Future<String?> webRetrieveRedirectUri() async {
    _logger.finest("webRetrieveRedirectUri()");
    final String? redirectUri = await StorageService()
        .loadStringFromLocalStorage(key: LocalStorageKey.redirectUri);
    return redirectUri;
  }

  String? webRemoveQueryFromUrlAndReturnKeycloakCode() {
    _logger.finest("webRemoveQueryFromUrlAndReturnKeycloakCode()");
    if (!kIsWeb) {
      throw AppException(
        exceptionMessage: "KIsWeb == false",
        exceptionType: ExceptionType.other,
      );
    }

    final Routemaster routemaster = Routemaster.of(context);

    final Map<String, String> currentQuery =
        routemaster.currentRoute.queryParameters;

    final String? code = currentQuery["code"];
    final String currentPath = routemaster.currentRoute.path;

    final Map<String, String> newQuery = currentQuery.map(MapEntry.new);

    newQuery.removeWhere((String key, String value) {
      return key == "session_state" || key == "code";
    });

    routemaster.replace(
      currentPath,
      queryParameters: newQuery.isNotEmpty ? newQuery : null,
    );

    return code;
  }

  @override
  Widget build(BuildContext context) {
    _logger.finest("build()");
    String langCode = kStartLocale.toString().split("_")[0];
    try {
      langCode = context.locale.toString().split("_")[0];
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      _logger.warning("Tried getting langCode: $e");
    }

    return (kIsWeb || !_showMobileWebView)
        ? const SizedBox.shrink()
        : FutureBuilder<String?>(
            future: _codeChallenge,
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final String? codeChallengeSnapshot = snapshot.data;

                if (codeChallengeSnapshot == null) {
                  throw AppException(
                    exceptionMessage: "_codeChallenge == null",
                    exceptionType: ExceptionType.unexpectedNullValue,
                  );
                }

                final String loginUrl = AuthService().generateKeyCloakLoginUrl(
                  redirectUri: ConfigService()
                      .getConfigValue(ConfigKey.redirectUriMobile),
                  codeChallenge: codeChallengeSnapshot,
                  langCode: langCode,
                );

                // DEBT keyboard is overlapping the login fields
                return WebView(
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  initialUrl: loginUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  onPageFinished: (url) {
                    if (url.contains(kKeycloakAuthUrlPart) &&
                        showPasswordResetPage) {
                      showPasswordResetPage = false;
                    }
                  },
                  navigationDelegate: (navigationRequest) async {
                    final String url = navigationRequest.url;
                    final AuthProvider authProvider =
                        Provider.of<AuthProvider>(context, listen: false);

                    _logger.info("URL changed: $url");

                    if (url.contains("kc_locale=")) {
                      await _changeLocale(url: url);
                    }

                    // if (url.contains(kKeycloakResetUrlPart)
                    //     &&  !showPasswordResetPage) {
                    //   * Adapt method from Dynamian.
                    //   return _handleKeycloakPasswordReset(url);
                    // }

                    if (url.startsWith(
                      ConfigService()
                          .getConfigValue(ConfigKey.redirectUriMobile),
                    )) {
                      return _handleReturnedKeycloakCode(url, authProvider);
                    }

                    return NavigationDecision.navigate;
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
  }

  NavigationDecision _handleReturnedKeycloakCode(
    String url,
    AuthProvider authProvider,
  ) {
    _logger.finest("_handleReturnedKeycloakCode()");
    setStateIfMounted(() {
      _showMobileWebView = false;
    });

    final RegExp regExp = RegExp("code=(.*)");
    final String? code = regExp.firstMatch(url)?.group(1);

    final String redirectUri = ConfigService().getConfigValue(
      ConfigKey.redirectUriMobile,
    );

    if (code == null) {
      _logger.info(
        "login_screen flutterWebviewPlugin.onUrlChanged.listen: "
        "returned code from keycloak was null",
      );

      setStateIfMounted(() {
        // ignore: discarded_futures
        _codeChallenge = authProvider.generateCodeChallengeAndStoreVerifier();
      });

      return NavigationDecision.navigate;
    }

    unawaited(
      authProvider.setAuthTokensFromKeycloakCode(
        keycloakCode: code,
        redirectUri: redirectUri,
      ),
    );

    return NavigationDecision.prevent;
  }

  Future<void> _changeLocale({required String url}) async {
    _logger.finest("_changeLocale()");
    final Uri? uri = Uri.tryParse(url);
    if (uri != null) {
      final String? kcLocale = uri.queryParameters["kc_locale"];

      if (kcLocale != null && kcLocale.isNotEmpty) {
        final String? currentLanguageCode =
            EasyLocalization.of(context)?.currentLocale?.languageCode;

        if (currentLanguageCode != kcLocale) {
          final Locale? locale = kSupportedLocales[kcLocale];

          if (locale != null) {
            await LocalizationService().changeUserLocale(
              changedLocale: locale,
              buildContext: context,
            );
          }
        }
      }
    }
  }
}
