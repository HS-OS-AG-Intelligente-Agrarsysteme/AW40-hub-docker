import "package:aw40_hub_frontend/models/logged_in_user_model.dart";
import "package:aw40_hub_frontend/utils/enums.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("LoggedInUserModel", () {
    const groups = <AuthorizedGroup>[
      AuthorizedGroup.Analysts,
      AuthorizedGroup.Mechanics,
    ];
    const fullName = "John Doe";
    const userName = "jdoe";
    const mailAddress = "a@b.c";
    const workShopId = "some_workshop_id";

    final loggedInUserModel = LoggedInUserModel(
      groups,
      fullName,
      userName,
      mailAddress,
      workShopId,
    );

    test("correctly assigns groups", () {
      expect(loggedInUserModel.groups, groups);
    });
    test("correctly assigns fullName", () {
      expect(loggedInUserModel.fullName, fullName);
    });
    test("correctly assigns userName", () {
      expect(loggedInUserModel.userName, userName);
    });
    test("correctly assigns mailAddress", () {
      expect(loggedInUserModel.mailAddress, mailAddress);
    });
    test("correctly assigns workShopId", () {
      expect(loggedInUserModel.workShopId, workShopId);
    });
  });
}
