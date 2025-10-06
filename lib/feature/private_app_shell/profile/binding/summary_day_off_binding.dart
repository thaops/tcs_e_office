import 'package:get/get.dart';
import 'package:tcs_e_office/feature/private_app_shell/profile/logic/summary_day_off_logic.dart';

class SummaryDayOffBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SummaryDayOffLogic>(() => SummaryDayOffLogic());
  }
}
