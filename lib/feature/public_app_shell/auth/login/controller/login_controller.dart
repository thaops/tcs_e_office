import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/Services/services.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/utils/show_dialog_set_url.dart';
import 'package:tcs_e_office/router/app_router.dart';
import 'package:tcs_e_office/src/api/api_service.dart';
import 'package:tcs_e_office/src/api/models/apiResponse_model.dart';
import 'package:tcs_e_office/src/services/lib/services/auth_service.dart';

class LoginController extends GetxController {
  DioApi dioApi = DioApi();
  late Dio dio;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  final ApiService apiService = ApiService();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  RxInt tapCount = 0.obs;
  final baseUrlController = TextEditingController();
  RxBool isLoadingMicrosoft = false.obs;
  RxString? microsoftRedirectUrl = RxString('');
  StreamSubscription? _sub;
  RxBool isFetchingUrl = false.obs;
  String url = '';

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    dio = Dio();
    // Cấu hình timeout và retry
    dio.options.connectTimeout = Duration(seconds: 30);
    dio.options.receiveTimeout = Duration(seconds: 30);
    dio.options.sendTimeout = Duration(seconds: 30);
    
    // Thêm interceptor để retry khi connection failed
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.type == DioExceptionType.connectionError) {
            print("🔄 Retrying connection...");
            // Retry logic sẽ được xử lý trong fetchMicrosoftRedirectUrl
          }
          handler.next(error);
        },
      ),
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> fetchMicrosoftRedirectUrl(BuildContext context) async {
    if (isFetchingUrl.value) return;
    
    print("🔄 Starting Microsoft login process...");
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
    isFetchingUrl.value = true;
    isLoadingMicrosoft.value = true;

    // Retry logic với exponential backoff
    int maxRetries = 3;
    int retryCount = 0;
    Duration retryDelay = Duration(seconds: 1);

    while (retryCount < maxRetries) {
      try {
        final apiUrl = ApiEndpoints.loginUrlMicrosoft(0, 1);
        print("🌐 API URL (attempt ${retryCount + 1}): $apiUrl");
        
        final response = await dio.get(
          apiUrl,
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            validateStatus: (status) => status != null && status < 500,
          ),
        );
        
        Navigator.pop(context);
        print("📊 Response status: ${response.statusCode}");
        print("📊 Response data: ${response.data}");
        
        if (response.statusCode == 200 && response.data != null) {
          final statusCode = response.data['statusCode'];
          if (statusCode == 200) {
            final url = response.data['data']?['url'];
            print("🔗 Microsoft URL: $url");
            
            if (url != null && url.isNotEmpty) {
              microsoftRedirectUrl?.value = url;
              print("✅ URL set successfully: ${microsoftRedirectUrl?.value}");
              goMicrosoftLogin();
              return; // Thành công, thoát khỏi retry loop
            } else {
              print("❌ URL is empty or null");
              Get.snackbar("Lỗi", "URL đăng nhập Microsoft không hợp lệ");
              return;
            }
          } else {
            print("❌ API response error: $statusCode");
            Get.snackbar("Thông báo", "Lấy URL thất bại: $statusCode");
            return;
          }
        } else {
          throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: "HTTP ${response.statusCode}",
          );
        }
      } catch (e) {
        retryCount++;
        print("❌ Lỗi fetchMicrosoftRedirectUrl (attempt $retryCount): $e");
        
        if (retryCount >= maxRetries) {
          Navigator.pop(context);
          
          // Hiển thị error message chi tiết cho user
          if (e.toString().contains('Connection failed') || 
              e.toString().contains('Operation not permitted')) {
            Get.snackbar(
              "Lỗi kết nối", 
              "Không thể kết nối đến server sau $maxRetries lần thử.\n\nVui lòng kiểm tra:\n• Kết nối internet\n• Firewall/VPN settings\n• Server có hoạt động không\n• Thử lại sau vài phút",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade800,
              duration: Duration(seconds: 8),
              margin: EdgeInsets.all(16),
            );
          } else if (e.toString().contains('timeout')) {
            Get.snackbar(
              "Timeout", 
              "Kết nối quá chậm. Vui lòng kiểm tra kết nối mạng và thử lại.",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.orange.shade100,
              colorText: Colors.orange.shade800,
              duration: Duration(seconds: 5),
            );
          } else {
            Get.snackbar(
              "Lỗi", 
              "Có lỗi xảy ra: ${e.toString()}",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade800,
            );
          }
          break;
        } else {
          print("🔄 Retrying in ${retryDelay.inSeconds} seconds...");
          await Future.delayed(retryDelay);
          retryDelay = Duration(seconds: retryDelay.inSeconds * 2); // Exponential backoff
        }
      }
    }
    
    isLoadingMicrosoft.value = false;
    isFetchingUrl.value = false;
  }

  Future<void> goMicrosoftLogin() async {
    // Kiểm tra GetX context trước khi navigation
    if (Get.context == null) {
      print("❌ GetX context is null, cannot navigate to Microsoft login");
      Get.snackbar("Lỗi", "Không thể đăng nhập. Vui lòng thử lại.");
      return;
    }

    try {
      Get.toNamed(
        AppRouter.loginWithMicrosoft,
        arguments: {'url': microsoftRedirectUrl?.value},
      )?.then((value) {
        print("valueMS: $value");
        if (value == false) {
          Get.snackbar("Thông báo", "Đăng nhập thất bại");
          return;
        }
        if (value != null) {
          print("valueMS: $value");
          // Kiểm tra context trước khi gọi loginWithMicrosoftCode
          if (Get.context != null) {
            loginWithMicrosoftCode(value['code'], Get.context!);
          } else {
            print("❌ GetX context is null in callback");
            Get.snackbar(
              "Lỗi",
              "Không thể hoàn tất đăng nhập. Vui lòng thử lại.",
            );
          }
        }
      });
    } catch (e) {
      print("❌ Error navigating to Microsoft login: $e");
      Get.snackbar(
        "Lỗi",
        "Không thể mở trang đăng nhập Microsoft. Vui lòng thử lại.",
      );
    }
  }

  Future<void> loginWithMicrosoftCode(String code, BuildContext context) async {
    print("codesss: $code");
    Services services = await Services.create();
    isLoadingMicrosoft.value = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext context) =>
              const Center(child: CircularProgressIndicator()),
    );
    try {
      final response = await dio.post(
        ApiEndpoints.loginMicrosoft,
        data: {'token': code},
      );
      print("response.datasss: ${response.data}");
      if (response.statusCode == 200) {
        final accessToken = response.data['data']['accessToken'].toString();
        saveLoginRouter(services, accessToken, context);
      } else {
        Get.snackbar("Thông báo", "Đăng nhập thất bại Vui lòng thử lại");
      }
    } catch (e) {
      print("Lỗi loginWithMicrosoftCode: $e");
    } finally {
      isLoadingMicrosoft.value = false;
      Navigator.pop(context);
    }
  }

  Future<void> loginFramework(BuildContext context) async {
    Services services = await Services.create();
    try {
      if (passwordController.text.isEmpty || usernameController.text.isEmpty) {
        Get.snackbar("Thông báo", "Vui lòng nhập tài khoản");
        return;
      }
      if (passwordController.text != "123456") {
        Get.snackbar("Thông báo", "Tài khoản không đúng");
        return;
      }
      final response = await dioApi.post(
        ApiEndpoints.loginFrame,
        data: {
          "userName": usernameController.text,
          "password": passwordController.text,
        },
      );
      if (response.data['statusCode'] == 500) {
        Get.snackbar("Thông báo", "Tài khoản không đúng");
        return;
      }
      var accessTokenId = response.data['data']['accessToken'].toString();
      if (response.data['statusCode'] == 200) {
        saveLoginRouter(services, accessTokenId, context);
      }
    } catch (e) {
      print("Lỗi loginFramework: $e");
      Get.snackbar("Thông báo", "Lỗi khi đăng nhập: $e");
    }
  }

  void showConfigDialog() {
    ShowDialogSetUrl().showConfigDialog(
      baseUrlController: baseUrlController,
      dioApi: dioApi,
      tapCount: tapCount,
    );
  }

  void saveLoginRouter(
    Services services,
    String accessTokenId,
    BuildContext context,
  ) async {
    if (accessTokenId.isEmpty) {
      return;
    }
    await services.saveAccessToken(accessTokenId);
    await apiService.getProfile(dioApi);

    Navigator.pop(context);
    Get.offAllNamed(AppRouter.main);
  }

  Future<ApiResponse> Login(String token) async {
    DioApi dioApi = DioApi();
    final response = await dioApi.post(
      ApiEndpoints.login,
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {'token': token},
    );
    print('Response: ${response.data}');
    if (response.statusCode == 200) {
      return ApiResponse.fromJson(response.data);
    } else {
      return ApiResponse(
        statusCode: response.statusCode ?? 500,
        message: 'Request failed with status: ${response.statusCode}',
        totalRecord: 0,
        data: null,
      );
    }
  }
}
