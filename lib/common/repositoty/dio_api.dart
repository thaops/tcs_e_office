import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as dioLib;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/Services/network_controller.dart';
import 'package:tcs_e_office/common/Services/services.dart';
import 'package:tcs_e_office/common/constants/http_status_codes.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tcs_e_office/common/share/auth/sign_out_clear.dart';
import 'package:uuid/uuid.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException({this.statusCode, required this.message});

  @override
  String toString() {
    return 'ApiException: $message (Status Code: $statusCode)';
  }
}

class DioApi {
  late final NetworkController networkController;
  final dioLib.Dio dio = dioLib.Dio()
    ..options.validateStatus = (status) => status! < 500;
  static final Map<String, dynamic> _cache = {};
  static final RxBool _hasShownDialog = false.obs;

  DioApi() {
    networkController = Get.find<NetworkController>();
    _initDio();
  }

  void _initDio() {
    dio.interceptors.add(
      dioLib.LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );
    dio.interceptors.add(
      dioLib.InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _checkNetwork();
          final header = await _buildHeader();
          options.headers.addAll(header);
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.statusCode == HttpStatusCodes.STATUS_CODE_UNAUTHORIZED) {
            SignOutClear().signOut();
          }
          handler.next(response);
        },
        onError: (error, handler) {
          throw ApiException(
            statusCode: error.response?.statusCode,
            message: error.response?.data['message'] ?? 'Something went wrong',
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getHeader() async {
    return _buildHeader();
  }

  void logLong(String tag, String text) {
    const int chunkSize = 800;
    for (var i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      debugPrint('$tag: ${text.substring(i, end)}');
    }
  }

  Future<Map<String, dynamic>> _buildHeader() async {
    final services = await Services.create();
    final packageInfo = await _getPackageInfo();
    final deviceInfo = await _getDeviceInfo();
    final udid = await _getUdid();
    final accessToken = await services.getAccessToken();

    return {
      "X_API_ID": "VN_CREW_2017",
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Accept-Language": "vi-VN",
      "Connection": "keep-alive",
      "X_REQUEST_PLATFORM": deviceInfo['platform'],
      "X_REQUEST_DEVICE_NAME": deviceInfo['deviceName'],
      "X_REQUEST_OS_VERSION": deviceInfo['osVersion'],
      "X_REQUEST_UDID": udid,
      "X_APP_ID": "NPP",
      "X_APP_BUILD": packageInfo['buildNumber'],
      "X_APP_VERSION": packageInfo['version'],
    };
  }

  Future<Map<String, dynamic>> _getPackageInfo() async {
    if (_cache.containsKey('packageInfo')) {
      return _cache['packageInfo'];
    }
    final info = await PackageInfo.fromPlatform();
    final data = {'buildNumber': info.buildNumber, 'version': info.version};
    _cache['packageInfo'] = data;
    return data;
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    if (_cache.containsKey('deviceInfo')) {
      return _cache['deviceInfo'];
    }

    final plugin = DeviceInfoPlugin();
    final device = await plugin.deviceInfo;

    late final Map<String, dynamic> data;

    if (Platform.isAndroid) {
      final android = device as AndroidDeviceInfo;
      data = {
        'platform': 'Android',
        'deviceName': android.model,
        'osVersion': android.version.release,
      };
    } else if (Platform.isIOS) {
      final ios = device as IosDeviceInfo;
      data = {
        'platform': 'iOS',
        'deviceName': ios.name,
        'osVersion': ios.systemVersion,
      };
    } else {
      data = {'platform': 'Unknown', 'deviceName': '', 'osVersion': ''};
    }

    _cache['deviceInfo'] = data;
    return data;
  }

  Future<String> _getUdid() async {
    final services = await Services.create();
    final saved = await services.getUdid();
    if (saved != null) return saved;

    final udid = const Uuid().v4();
    await services.saveUdid(udid);
    return udid;
  }

  Future<void> _checkNetwork() async {
    await networkController.checkInternet();
    if (!networkController.isOnline.value) {
      await _showNoNetworkDialog();
      throw ApiException(message: 'No internet connection');
    }
  }

  Future<void> _showNoNetworkDialog() async {
    if (_hasShownDialog.value || Get.isDialogOpen == true) return;
    _hasShownDialog.value = true;

    await Get.dialog(
      CupertinoAlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text(
          'Please check your internet connection and try again.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Close'),
            onPressed: () {
              Get.back();
              _hasShownDialog.value = false;
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );

    _hasShownDialog.value = false;
  }

  Future<dioLib.Response> get(String url, {Map<String, dynamic>? params}) {
    return dio.get(url, queryParameters: params);
  }

  Future<dioLib.Response> post(
    String url, {
    dynamic data,
    dioLib.Options? options,
  }) {
    return dio.post(url, data: data, options: options);
  }

  Future<dioLib.Response> put(String url, {dynamic data}) {
    return dio.put(url, data: data);
  }

  Future<dioLib.Response> delete(String url, {Map<String, dynamic>? params}) {
    return dio.delete(url, queryParameters: params);
  }

  Future<dioLib.Response> getBytes(String url, {Map<String, dynamic>? params}) {
    return dio.get(
      url,
      queryParameters: params,
      options: dioLib.Options(responseType: dioLib.ResponseType.bytes),
    );
  }
}
