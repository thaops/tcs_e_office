import 'package:get/get.dart';
import 'package:tcs_e_office/feature/public_app_shell/auth/login/binding/login_binding.dart';
import 'package:tcs_e_office/feature/public_app_shell/auth/login/view/login_screen.dart';
import 'package:tcs_e_office/feature/public_app_shell/auth/login_with_microsoft/login_with_microsoft.dart';
import 'package:tcs_e_office/feature/private_app_shell/filter_user/filter_user_view.dart';

import 'package:tcs_e_office/feature/private_app_shell/profile/binding/profile_binding.dart';
import 'package:tcs_e_office/feature/private_app_shell/profile/view/profile_screen.dart';
import 'package:tcs_e_office/router/bottom_navigation_main.dart';

class AppRouter {
  // Route cha
  static const auth = '/auth';
  static const report = '/report';
  static const board = '/board';
  static const task = '/task';
  static const leave = '/leave';
  static const support = '/support';
  static const main = '/main';
  static const profile = '/profile';
  static const filter_user = '/filter_user';
  static const splash = '/splash';

  // Route con cho auth
  static const login = '/auth/login';
  static const loginWithMicrosoft = '/auth/loginWithMicrosoft';

  static final List<GetPage> routes = [
    // Auth
    GetPage(name: login, page: () => LoginScreen(), binding: LoginBinding()),
    GetPage(name: loginWithMicrosoft, page: () => LoginWithMicrosoft()),

    // Main
    GetPage(name: main, page: () => MainScreen()),

    // Độc lập
    GetPage(
      name: profile,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(name: filter_user, page: () => FilterUserView()),
  ];
}
