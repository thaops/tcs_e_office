import 'package:tcs_e_office/feature/private_app_shell/profile/data/models/profile_model.dart';
import 'package:tcs_e_office/src/config/constants/url/url.dart';
import 'package:tcs_e_office/src/services/lib/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ProfileFetchUsers {
  Profile? profile;
  final Dio dio = Dio();

  Future<String> getBaseUrl(BuildContext context) async {
    return await BaseUrlProvider.getBaseUrl(context);
  }

  Future<String?> _getAccessToken() async {
    final authService = AuthService();
    return await authService.getAccessToken();
  }


}