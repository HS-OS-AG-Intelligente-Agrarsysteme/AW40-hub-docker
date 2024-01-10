import "package:aw40_hub_frontend/utils/utils.dart";

class LoggedInUserModel {
  LoggedInUserModel(
    this.roles,
    this.fullName,
    this.userName,
    this.mailAddress,
    this.workShopId,
  );
  final List<AuthorizedRole> roles;
  final String fullName;
  final String userName;
  final String mailAddress;
  final String workShopId;
}
