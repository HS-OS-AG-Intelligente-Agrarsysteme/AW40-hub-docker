import "package:aw40_hub_frontend/utils/enums.dart";
import "package:enum_to_string/enum_to_string.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";

class StorageService {
  Future<String?> loadStringFromLocalStorage({
    required LocalStorageKey key,
  }) async {
    const FlutterSecureStorage secStorage = FlutterSecureStorage();
    final String? returnString = await secStorage.read(
      key: EnumToString.convertToString(key),
    );
    return returnString;
  }

  Future<void> storeStringToLocalStorage({
    required LocalStorageKey key,
    required String value,
  }) async {
    const FlutterSecureStorage secStorage = FlutterSecureStorage();
    await secStorage.write(
      key: EnumToString.convertToString(key),
      value: value,
    );
  }

  Future<void> resetLocalStorage() async {
    const FlutterSecureStorage secStorage = FlutterSecureStorage();
    await secStorage.deleteAll();
  }
}
