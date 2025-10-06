import 'package:get/get.dart';
import 'package:tcs_e_office/feature/private_app_shell/profile/logic/profile_logic.dart';

class ProfileBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<ProfileLogic>(() => ProfileLogic());
  }
}