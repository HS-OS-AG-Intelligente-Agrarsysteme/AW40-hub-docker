import "package:aw40_hub_frontend/utils/enums.dart";

class LoggedInUserModel {
  LoggedInUserModel(
    this.groups,
    this.fullName,
    this.userName,
    this.mailAddress,
    this.workShopId,
  );
  final List<AuthorizedGroup> groups;
  final String fullName;
  final String userName;
  final String mailAddress;
  final String workShopId;
}
