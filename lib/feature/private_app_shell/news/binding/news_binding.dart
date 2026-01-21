import 'package:get/get.dart';
import 'package:tcs_e_office/feature/private_app_shell/news/controllers/news_controller.dart';

class NewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NewsController());
  }
}