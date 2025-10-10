import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/img/img.dart';
import 'package:tcs_e_office/common/widgets/text_widget.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/feature/public_app_shell/auth/login/controller/login_controller.dart';
import 'package:tcs_e_office/feature/public_app_shell/auth/login/widget/frame_login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tcs_e_office/common/widgets/widgets/background_fill_view.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controllerlogin = Get.find<LoginController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: IntrinsicHeight(
          child: SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: BackgroundFillView(
              child: _buildActionLogin(controllerlogin, context),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildActionLogin(
    LoginController controllerlogin,
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(controllerlogin),
          FrameLogin(
            controllerLogin: controllerlogin,
            passwordControllerl: controllerlogin.passwordController,
            usernameController: controllerlogin.usernameController,
          ),
          _buildIntrucdtion(context),
        ],
      ),
    );
  }

  Widget _buildIntrucdtion(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(
            'Sứ mệnh',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16.sp,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
              decorationThickness: 1.5,
            ),
          ),
        ),
        SizedBox(height: 10.h),

        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: TextWidget(
            text: '''
Cung cấp dịch vụ phục vụ hàng hóa chuyên nghiệp cho khách hàng, phát triển sự nghiệp cho nhân viên, đóng góp cho cộng đồng xã hội cũng như là nơi đầu tư mang lại hiệu quả cho cổ đông.''',
            textAlign: TextAlign.center,
            maxLines: 6,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade500,
            fontSize: 14.sp,
          ),
        ),

        SizedBox(height: 10.h),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: TextWidget(
            text: 'Powered by NP Technology',
            textAlign: TextAlign.center,
            color: Color.fromRGBO(54, 125, 154, 1),
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  GestureDetector _buildLogo(LoginController controllerlogin) {
    return GestureDetector(
      child: Image.asset(Img.logo, width: 250.w, height: 137.h),

      onTap: () {
        controllerlogin.tapCount++;
        controllerlogin.showConfigDialog();
      },
    );
  }
}
