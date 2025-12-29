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
import 'package:tcs_e_office/router/one_signal_service.dart';
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
    dio.options.connectTimeout = Duration(seconds: 30);
    dio.options.receiveTimeout = Duration(seconds: 30);
    dio.options.sendTimeout = Duration(seconds: 30);

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [CircularProgressIndicator()],
        ),
      ),
    );
    isFetchingUrl.value = true;
    isLoadingMicrosoft.value = true;

    int maxRetries = 3;
    int retryCount = 0;
    Duration retryDelay = Duration(seconds: 1);
    bool dialogClosed = false;

    // Helper function để đóng dialog an toàn
    void safePopDialog() {
      if (!dialogClosed && context.mounted) {
        try {
          Navigator.pop(context);
          dialogClosed = true;
        } catch (e) {
          // Ignore nếu dialog đã được đóng hoặc context không còn valid
        }
      }
    }

    while (retryCount < maxRetries) {
      try {
        final apiUrl = ApiEndpoints.loginUrlMicrosoft(0, 1);

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

        safePopDialog();

        if (response.statusCode == 200 && response.data != null) {
          final statusCode = response.data['statusCode'];
          if (statusCode == 200) {
            final url = response.data['data']?['url'];

            if (url != null && url.isNotEmpty) {
              microsoftRedirectUrl?.value = url;
              goMicrosoftLogin();
              return;
            } else {
              return;
            }
          } else {
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

        if (retryCount >= maxRetries) {
          safePopDialog();
          break;
        } else {
          await Future.delayed(retryDelay);
          retryDelay = Duration(seconds: retryDelay.inSeconds * 2);
        }
      }
    }

    _resetMicrosoftLoginState();
  }

  Future<void> goMicrosoftLogin() async {
    if (Get.context == null) {
      _resetMicrosoftLoginState();
      return;
    }

    try {
      Get.toNamed(
            AppRouter.loginWithMicrosoft,
            arguments: {'url': microsoftRedirectUrl?.value},
          )
          ?.then((value) {
            if (value == false) {
              _resetMicrosoftLoginState();
              return;
            }
            if (value != null) {
              if (Get.context != null) {
                loginWithMicrosoftCode(value['code'], Get.context!);
              } else {
                _resetMicrosoftLoginState();
              }
            } else {
              _resetMicrosoftLoginState();
            }
          })
          .catchError((error) {
            _resetMicrosoftLoginState();
          });
    } catch (e) {
      _resetMicrosoftLoginState();
    }
  }

  void _resetMicrosoftLoginState() {
    isFetchingUrl.value = false;
    isLoadingMicrosoft.value = false;
  }

  Future<void> loginWithMicrosoftCode(String code, BuildContext context) async {
    Services services = await Services.create();
    isLoadingMicrosoft.value = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          const Center(child: CircularProgressIndicator()),
    );
    try {
      final response = await dio.post(
        ApiEndpoints.loginMicrosoft,
        data: {'token': code},
      );
      if (response.statusCode == 200) {
        final accessToken = response.data['data']['accessToken'].toString();
        saveLoginRouter(services, accessToken, context);
      }
    } catch (e) {
      // ignore
    } finally {
      isLoadingMicrosoft.value = false;
      Navigator.pop(context);
    }
  }

  Future<void> loginFramework(BuildContext context) async {
    Services services = await Services.create();
    try {
      if (passwordController.text.isEmpty || usernameController.text.isEmpty) {
        return;
      }
      if (passwordController.text != "123456") {
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
        return;
      }
      var accessTokenId = response.data['data']['accessToken'].toString();
      if (response.data['statusCode'] == 200) {
        saveLoginRouter(services, accessTokenId, context);
      }
    } catch (e) {
      // ignore
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

    try {
      await OneSignalService().registerTokenAfterLogin();
    } catch (e) {
      // ignore
    }

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
