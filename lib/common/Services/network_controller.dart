import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NetworkController extends GetxController {
  final RxBool isOnline = false.obs;
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() async {
      await _initConnectivity();
      _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    });
  }

  // Kiểm tra kết nối thủ công
  Future<void> checkInternet() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);
    } catch (e) {
      isOnline.value = false;
    }
  }

  // Khởi tạo trạng thái kết nối ban đầu
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);
    } catch (e) {
      isOnline.value = false;
    }
  }

  // Cập nhật trạng thái kết nối
  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      isOnline.value = false;
      return;
    }

    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'));
      isOnline.value = response.statusCode == 200;
    } catch (e) {
      isOnline.value = false;
    }
  }
}