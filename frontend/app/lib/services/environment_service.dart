import "dart:io";

import "package:aw40_hub_frontend/utils/enums.dart";
import "package:enum_to_string/enum_to_string.dart";
import "package:flutter/foundation.dart";

class EnvironmentService {
  factory EnvironmentService() => _environmentService;
  EnvironmentService._singleton() {
    _determineHostPlatform();
    _determineIfIsMobilePlatform();
  }
  static final EnvironmentService _environmentService =
      EnvironmentService._singleton();

  late HostPlatform _hostPlatform;
  HostPlatform get hostPlatform => _hostPlatform;

  late bool _isMobilePlatform;
  bool get isMobilePlatform => _isMobilePlatform;

  final bool _isDebugMode = kDebugMode;
  bool get isDebugMode => _isDebugMode;

  void _determineHostPlatform() {
    if (kIsWeb) {
      _hostPlatform = HostPlatform.web;
    } else {
      final HostPlatform? hostPlatform = EnumToString.fromString(
        HostPlatform.values,
        Platform.operatingSystem,
      );
      if (hostPlatform == null) {
        throw UnsupportedError(
          "Could not determine host platform ${Platform.operatingSystem}.",
        );
      }
      _hostPlatform = hostPlatform;
    }
  }

  void _determineIfIsMobilePlatform() {
    _isMobilePlatform = _hostPlatform == HostPlatform.android ||
        _hostPlatform == HostPlatform.ios;
  }
}
