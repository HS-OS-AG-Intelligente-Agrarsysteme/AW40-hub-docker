import "dart:convert";

import "package:aw40_hub_frontend/dtos/customer_dto.dart";
import "package:aw40_hub_frontend/dtos/customer_update_dto.dart";
import "package:aw40_hub_frontend/dtos/new_customer_dto.dart";
import "package:aw40_hub_frontend/exceptions/app_exception.dart";
import "package:aw40_hub_frontend/models/customer_model.dart";
import "package:aw40_hub_frontend/providers/auth_provider.dart";
import "package:aw40_hub_frontend/services/helper_service.dart";
import "package:aw40_hub_frontend/services/http_service.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter/foundation.dart";
import "package:http/http.dart";
import "package:logging/logging.dart";

class CustomerProvider with ChangeNotifier {
  CustomerProvider(this._httpService);

  final HttpService _httpService;

  final Logger _logger = Logger("customer_provider");
  late final String workshopId;

  late final String costumerId;

  String? _authToken;

  Future<void> fetchAndSetAuthToken(AuthProvider authProvider) async {
    _authToken = await authProvider.getAuthToken();
    notifyListeners();
  }

  String _getAuthToken() {
    final String? authToken = _authToken;
    if (authToken == null) {
      throw AppException(
        exceptionMessage: "Called CustomerProvider without auth token.",
        exceptionType: ExceptionType.unexpectedNullValue,
      );
    }
    return authToken;
  }

  Future<List<CustomerModel>> getSharedCustomers() async {
    final String authToken = _getAuthToken();
    final Response response = await _httpService.getSharedCustomers(
      authToken,
    );
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not get shared customers. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return [];
    }
    final json = jsonDecode(response.body);
    if (json is! List) {
      _logger.warning("Could not decode json response to List.");
      return [];
    }
    return json.map((e) => CustomerDto.fromJson(e).toModel()).toList();
  }

  Future<List<CustomerModel>> getCustomers(int? page, int? pageSize) async {
    final String authToken = _getAuthToken();
    final Response response =
        await _httpService.getCustomers(authToken, page, pageSize);
    if (response.statusCode != 200) {
      _logger.warning(
        "Could not get customers. "
        "${response.statusCode}: ${response.reasonPhrase}",
      );
      return [];
    }
    final respBody = response.body;
    final json = jsonDecode(respBody);
    if (json is! List) {
      _logger.warning("Could not decode json response to List.");
      return [];
    }
    final list = json.map((e) => CustomerDto.fromJson(e).toModel()).toList();
    return list;
  }

  Future<CustomerModel?> addCustomer(NewCustomerDto newCustomerDto) async {
    final String authToken = _getAuthToken();
    final Map<String, dynamic> newCustomerJson = newCustomerDto.toJson();
    final Response response =
        await _httpService.addCustomer(authToken, newCustomerJson);
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      201,
      "Could not add customer. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return null;
    notifyListeners();
    return _decodeCustomerModelFromResponseBody(response);
  }

  Future<CustomerModel?> updateCustomer(
    String customerId,
    CustomerUpdateDto updateCustomerDto,
  ) async {
    final String authToken = _getAuthToken();
    final Map<String, dynamic> updateCustomerJson = updateCustomerDto.toJson();
    final Response response = await _httpService.updateCustomer(
      authToken,
      customerId,
      updateCustomerJson,
    );
    final bool verifyStatusCode = HelperService.verifyStatusCode(
      response.statusCode,
      200,
      "Could not update customer. ",
      response,
      _logger,
    );
    if (!verifyStatusCode) return null;
    notifyListeners();
    return _decodeCustomerModelFromResponseBody(response);
  }

  CustomerModel _decodeCustomerModelFromResponseBody(Response response) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    final CustomerDto receivedCustomer = CustomerDto.fromJson(body);
    return receivedCustomer.toModel();
  }
}
