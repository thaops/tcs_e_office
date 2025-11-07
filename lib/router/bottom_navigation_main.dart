import 'package:get/get.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/feature/private_app_shell/profile/logic/profile_logic.dart';
import 'package:flutter/material.dart';
import 'package:tcs_e_office/feature/private_app_shell/profile/view/profile_screen.dart';
import 'package:tcs_e_office/feature/private_app_shell/work_management/view/work_management_tab.dart';
import 'package:tcs_e_office/feature/private_app_shell/home/view/home_tab.dart';
import 'package:tcs_e_office/feature/private_app_shell/document_management/view/document_management_tab.dart';
import 'package:tcs_e_office/common/services/navigation_service.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    Get.put(ProfileLogic());
    NavigationService.setTabChangeCallback(_onTabTapped);
  }

  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    WorkManagementTab(),
    const DocumentManagementTab(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  );
                }
                return TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                );
              }),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onTabTapped,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            indicatorColor: AppColors.primary.withOpacity(0.8),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Colors.grey.shade600),
                selectedIcon: Icon(Icons.home_rounded, color: Colors.white),
                label: 'Trang chủ',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.list_alt_outlined,
                  color: Colors.grey.shade600,
                ),
                selectedIcon: Icon(Icons.list_alt_rounded, color: Colors.white),
                label: 'Công việc',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.description_outlined,
                  color: Colors.grey.shade600,
                ),
                selectedIcon: Icon(
                  Icons.description_rounded,
                  color: Colors.white,
                ),
                label: 'Văn bản',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: Colors.grey.shade600),
                selectedIcon: Icon(Icons.person_rounded, color: Colors.white),
                label: 'Cá nhân',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
