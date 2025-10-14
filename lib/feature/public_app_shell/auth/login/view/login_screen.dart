import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/img/img.dart';
import 'package:tcs_e_office/common/widgets/text_widget.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/feature/public_app_shell/auth/login/controller/login_controller.dart';
import 'package:tcs_e_office/feature/public_app_shell/auth/login/widget/frame_login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tcs_e_office/common/widgets/widgets/background_fill_view.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controllerlogin = Get.find<LoginController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BackgroundFillView(
          child: _buildResponsiveLayout(controllerlogin, context),
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(
    LoginController controllerlogin,
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              maxHeight: double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 30.h : 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: isTablet ? 120.h : 60.h),
                    child: _buildLogo(controllerlogin),
                  ),
                  SizedBox(height: isTablet ? 20.h : 0.h),

                  _buildLoginForm(controllerlogin, isTablet),
                  SizedBox(height: isTablet ? 100.h : 90.h),
                  _buildIntrucdtion(context, isTablet),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(LoginController controllerlogin, bool isTablet) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 400.w : double.infinity,
        ),
        child: FrameLogin(
          controllerLogin: controllerlogin,
          passwordControllerl: controllerlogin.passwordController,
          usernameController: controllerlogin.usernameController,
        ),
      ),
    );
  }

  Widget _buildIntrucdtion(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 20.w : 16.w),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _openMissionUrl(),
            child: Text(
              'Sứ mệnh Test OTA',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: isTablet ? 18.sp : 16.sp,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
                decorationThickness: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 16.h : 12.h),

          TextWidget(
            text: '''
Cung cấp dịch vụ phục vụ hàng hóa chuyên nghiệp cho khách hàng, phát triển sự nghiệp cho nhân viên, đóng góp cho cộng đồng xã hội cũng như là nơi đầu tư mang lại hiệu quả cho cổ đông.''',
            textAlign: TextAlign.center,
            maxLines: isTablet ? 8 : 6,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade500,
            fontSize: isTablet ? 15.sp : 14.sp,
          ),

          SizedBox(height: isTablet ? 18.h : 16.h),
          TextWidget(
            text: 'Powered by NP Technology',
            textAlign: TextAlign.center,
            color: Color.fromRGBO(54, 125, 154, 1),
            fontSize: isTablet ? 15.sp : 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(LoginController controllerlogin) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final logoWidth = isTablet ? 300.w : 250.w;
        final logoHeight = isTablet ? 165.h : 137.h;

        return GestureDetector(
          child: Image.asset(
            Img.logo,
            width: logoWidth,
            height: logoHeight,
            fit: BoxFit.contain,
          ),
          onTap: () {
            controllerlogin.tapCount++;
            controllerlogin.showConfigDialog();
          },
        );
      },
    );
  }

  Future<void> _openMissionUrl() async {
    const url =
        'https://www.tcs.com.vn/gioi-thieu/su-menh-tam-nhin-gia-tri-cot-loi#';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: show error message
        Get.snackbar(
          'Lỗi',
          'Không thể mở liên kết. Vui lòng kiểm tra kết nối mạng.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    } catch (e) {
      // Handle any errors
      Get.snackbar(
        'Lỗi',
        'Có lỗi xảy ra khi mở liên kết.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
}
