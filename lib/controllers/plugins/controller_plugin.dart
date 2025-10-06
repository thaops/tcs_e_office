import 'package:tcs_e_office/controllers/base/base_controller.dart';

abstract class ControllerPlugin {
  Future<void> beforeAction(BaseController controller);
  Future<void> afterAction(BaseController controller);
  Future<void> onError(BaseController controller, dynamic error);
}