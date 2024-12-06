import "dart:convert";

import "package:aw40_hub_frontend/dtos/asset_dto.dart";
import "package:aw40_hub_frontend/dtos/nautilus_private_key_dto.dart";
import "package:aw40_hub_frontend/dtos/new_asset_dto.dart";
import "package:aw40_hub_frontend/dtos/new_publication_dto.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/asset_model.dart";
import "package:aw40_hub_frontend/models/new_publication_model.dart";
import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart";
import "package:logging/logging.dart";

class AssetProvider with ChangeNotifier {
  AssetProvider(this._httpService);

  final HttpService _httpService;

  final Logger _logger = Logger("asset_provider");

  String? _authToken;

  Future<List<AssetModel>> getAssets() async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.getAssets(
      authToken,
    );
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not get assets. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return [];
    }
    final json = jsonDecode(response.body);
    if (json is! List) {
      _logger.warning("Could not decode json response to List.");
      return [];
    }
    return json.map((e) => AssetDto.fromJson(e).toModel()).toList();
  }

  Future<AssetModel?> createAsset(NewAssetDto newAssetDto) async {
    final String authToken = _getAuthToken();
    final Map<String, dynamic> newAssetJson = newAssetDto.toJson();
    final Response response =
        await _httpService.createAsset(authToken, newAssetJson);
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      201,
      "Could not create asset. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return null;
    notifyListeners();
    return _decodeAssetModelFromResponseBody(response);
  }

  Future<NewPublicationModel?> publishAsset(
    String assetId,
    NewPublicationDto newPublicationDto,
  ) async {
    final String authToken = _getAuthToken();
    final Map<String, dynamic> newPublicationJson = newPublicationDto.toJson();
    final Response response =
        await _httpService.publishAsset(authToken, assetId, newPublicationJson);
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      201,
      "Could not publish asset. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return null;
    notifyListeners();
    return _decodeNewPublicationModelFromResponseBody(response);
  }

  Future<bool> deleteAsset(
    String assetId,
    NautilusPrivateKeyDto nautilusPrivateKeyDto,
  ) async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.deleteAsset(
      authToken,
      assetId,
      nautilusPrivateKeyDto.toJson(),
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not delete asset. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return false;
    notifyListeners();
    return true;
  }

  NewPublicationModel _decodeNewPublicationModelFromResponseBody(
    Response response,
  ) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    final NewPublicationDto receivedNewPublication = NewPublicationDto.fromJson(
      body,
    );
    return receivedNewPublication.toModel();
  }

  AssetModel _decodeAssetModelFromResponseBody(Response response) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    final AssetDto assetDto = AssetDto.fromJson(body);
    return assetDto.toModel();
  }

  Future<void> fetchAndSetAuthToken(AuthProvider authProvider) async {
    _authToken = await authProvider.getAuthToken();
    notifyListeners();
  }

  String _getAuthToken() {
    final String? authToken = _authToken;
    if (authToken == null) {
      throw AppException(
        exceptionMessage: "Called AssetsProvider without auth token.",
        exceptionType: ExceptionType.unexpectedNullValue,
      );
    }
    return authToken;
  }
}
