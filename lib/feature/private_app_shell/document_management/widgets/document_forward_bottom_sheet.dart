import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/share/cache/my_id.dart';
import '../models/issue_unit_model.dart';
import '../models/employee_forward_model.dart';
import '../services/document_forward_service.dart';

Future<void> showDocumentForwardBottomSheet(
  BuildContext context, {
  required String documentId,
  required void Function(String employeeCode, String employeeName) onConfirm,
}) async {
  final DocumentForwardService _forwardService = DocumentForwardService();
  final RxList<IssueUnitModel> issueUnits = <IssueUnitModel>[].obs;
  final RxString selectedDepartmentCode = ''.obs;
  final RxString selectedEmployeeCode = ''.obs;
  final RxString selectedEmployeeName = ''.obs;
  final RxBool isLoadingIssueUnits = true.obs;
  final RxSet<String> expanded = <String>{}.obs;
  Timer? _debounceTimer; // Timer cho debounce
  final TextEditingController _searchController =
      TextEditingController(); // Controller cho search field
  String? _currentEmployeeCode; // Employee code của user hiện tại

  // Cache employees theo từng department code để độc lập
  final Map<String, RxList<EmployeeForwardModel>> _employeesMap = {};
  final Map<String, RxBool> _isLoadingEmployeesMap = {};

  // Load employee code hiện tại
  Future<void> _loadCurrentEmployeeCode() async {
    try {
      final myId = await MyId.create();
      final employeeCode = await myId.getMyId();
      _currentEmployeeCode = employeeCode.isNotEmpty ? employeeCode : null;
    } catch (e) {
      print('Error loading current employee code: $e');
      _currentEmployeeCode = null;
    }
  }

  // Load danh sách đơn vị phát hành
  Future<void> _loadIssueUnits() async {
    try {
      isLoadingIssueUnits.value = true;
      final units = await _forwardService.getIssueUnitOptions();
      issueUnits.value = units;
    } catch (e) {
      print('Error loading issue units: $e');
    } finally {
      isLoadingIssueUnits.value = false;
    }
  }

  // Load danh sách nhân viên theo phòng ban
  Future<void> _loadEmployees(String departmentCode) async {
    try {
      // Khởi tạo nếu chưa có
      if (!_isLoadingEmployeesMap.containsKey(departmentCode)) {
        _isLoadingEmployeesMap[departmentCode] = false.obs;
      }
      if (!_employeesMap.containsKey(departmentCode)) {
        _employeesMap[departmentCode] = <EmployeeForwardModel>[].obs;
      }

      // Nếu đã có data, không cần load lại
      if (_employeesMap[departmentCode]!.isNotEmpty) {
        return;
      }

      _isLoadingEmployeesMap[departmentCode]!.value = true;
      final emps = await _forwardService.getEmployeesByDepartment(
        departmentCode,
      );

      // Đảm bảo đã load currentEmployeeCode trước khi filter
      if (_currentEmployeeCode == null) {
        await _loadCurrentEmployeeCode();
      }

      // Filter ra chính mình khỏi danh sách - không cho chọn employee trùng ID
      List<EmployeeForwardModel> filteredEmps;
      if (_currentEmployeeCode != null && _currentEmployeeCode!.isNotEmpty) {
        filteredEmps = emps.where((emp) {
          return emp.employeeCode != _currentEmployeeCode;
        }).toList();
      } else {
        filteredEmps = emps;
      }

      // Cache lại cho department này
      _employeesMap[departmentCode]!.value = filteredEmps;
    } catch (e) {
      print('Error loading employees: $e');
    } finally {
      _isLoadingEmployeesMap[departmentCode]!.value = false;
    }
  }

  // Lấy employees của một department
  RxList<EmployeeForwardModel>? _getEmployeesForDepartment(
    String departmentCode,
  ) {
    if (!_employeesMap.containsKey(departmentCode)) {
      _employeesMap[departmentCode] = <EmployeeForwardModel>[].obs;
    }
    return _employeesMap[departmentCode];
  }

  // Lấy loading state của một department
  RxBool? _getLoadingStateForDepartment(String departmentCode) {
    if (!_isLoadingEmployeesMap.containsKey(departmentCode)) {
      _isLoadingEmployeesMap[departmentCode] = false.obs;
    }
    return _isLoadingEmployeesMap[departmentCode];
  }

  // Reset search state khi mở bottom sheet (optimized for instant opening)
  void _resetSearchState() {
    _searchController.clear();
    _debounceTimer?.cancel();
    // Load current employee code và data trong background
    Future.microtask(() async {
      await _loadCurrentEmployeeCode();
      _loadIssueUnits();
    });
  }

  // Gọi reset ngay khi mở bottom sheet (không await)
  _resetSearchState();

  // Thêm listener để update UI khi text thay đổi
  _searchController.addListener(() {
    // Trigger UI update khi text thay đổi
  });

  // Function để xử lý search với debounce
  void _handleSearch(String value) {
    final trimmedValue = value.trim();

    // Hủy timer cũ nếu có
    _debounceTimer?.cancel();

    // Nếu search rỗng, gọi ngay lập tức để reset data
    if (trimmedValue.isEmpty) {
      _loadIssueUnits();
      return;
    }

    // Tạo timer mới với delay 500ms cho search có keyword
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Filter issue units based on search
      final filteredUnits = issueUnits
          .where(
            (unit) =>
                unit.label.toLowerCase().contains(trimmedValue.toLowerCase()) ||
                unit.value.toLowerCase().contains(trimmedValue.toLowerCase()),
          )
          .toList();
      issueUnits.value = filteredUnits;
    });
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    isDismissible: true,
    useSafeArea: true,
    builder: (ctx) {
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            // Chỉ cancel timer khi bottom sheet bị đóng
            _debounceTimer?.cancel();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Chọn người chuyển tiếp',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.colorIcon,
                        ),
                        onPressed: () {
                          _debounceTimer?.cancel(); // Chỉ cancel timer
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Search
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _handleSearch,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm đơn vị phát hành...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade600,
                        size: 22,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            onPressed: () {
                              // Clear text field và reset data ngay lập tức
                              _searchController.clear();
                              _debounceTimer?.cancel();
                              _loadIssueUnits();
                            },
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.red.shade300,
                        width: 1,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.red.shade400,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Tree list
              Expanded(
                child: Obx(() {
                  // Hiển thị loading khi đang load
                  if (isLoadingIssueUnits.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Đang tải danh sách đơn vị...',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vui lòng chờ trong giây lát',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Hiển thị skeleton khi chưa có dữ liệu
                  if (issueUnits.isEmpty) {
                    // Nếu đang có keyword thì hiển thị empty state
                    if (_searchController.text.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Không tìm thấy đơn vị',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Thử tìm kiếm với từ khóa khác',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    // Nếu không có keyword thì hiển thị skeleton loading
                    return _buildSkeletonLoading();
                  }

                  // Hiển thị danh sách
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: issueUnits
                          .map<Widget>(
                            (unit) => _DepartmentNode(
                              unit: unit,
                              expanded: expanded,
                              selectedDepartmentCode: selectedDepartmentCode,
                              selectedEmployeeCode: selectedEmployeeCode,
                              selectedEmployeeName: selectedEmployeeName,
                              employees: _getEmployeesForDepartment(
                                unit.value,
                              )!,
                              isLoadingEmployees: _getLoadingStateForDepartment(
                                unit.value,
                              )!,
                              currentEmployeeCode: _currentEmployeeCode,
                              onDepartmentSelected: (departmentCode) {
                                selectedDepartmentCode.value = departmentCode;
                                _loadEmployees(departmentCode);
                              },
                              onEmployeeSelected: (employeeCode, employeeName) {
                                selectedEmployeeCode.value = employeeCode;
                                selectedEmployeeName.value = employeeName;
                              },
                            ),
                          )
                          .toList(),
                    ),
                  );
                }),
              ),

              // Confirm button
              SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Obx(() {
                    final canConfirm = selectedEmployeeCode.value.isNotEmpty;
                    return ElevatedButton(
                      onPressed: canConfirm
                          ? () {
                              _debounceTimer?.cancel(); // Chỉ cancel timer
                              onConfirm(
                                selectedEmployeeCode.value,
                                selectedEmployeeName.value,
                              );
                              Navigator.of(ctx).pop();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canConfirm
                            ? AppColors.yellow
                            : Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Xác nhận',
                        style: TextStyle(
                          color: canConfirm
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Widget skeleton loading cho danh sách departments (with smooth animation)
Widget _buildSkeletonLoading() {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: List.generate(
        5,
        (index) => _buildSkeletonItem(index),
      ), // Tăng lên 5 items
    ),
  );
}

/// Widget skeleton cho một item (with shimmer effect)
Widget _buildSkeletonItem(int index) {
  return TweenAnimationBuilder<double>(
    duration: Duration(
      milliseconds: 600 + (index * 100),
    ), // Staggered animation
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, value, child) {
      return Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)), // Slide up animation
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              children: [
                // Skeleton checkbox
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 16),
                // Skeleton text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 12,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Skeleton expand icon
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _DepartmentNode extends StatelessWidget {
  final IssueUnitModel unit;
  final RxSet<String> expanded;
  final RxString selectedDepartmentCode;
  final RxString selectedEmployeeCode;
  final RxString selectedEmployeeName;
  final RxList<EmployeeForwardModel> employees;
  final RxBool isLoadingEmployees;
  final String? currentEmployeeCode;
  final Function(String) onDepartmentSelected;
  final Function(String, String) onEmployeeSelected;

  const _DepartmentNode({
    required this.unit,
    required this.expanded,
    required this.selectedDepartmentCode,
    required this.selectedEmployeeCode,
    required this.selectedEmployeeName,
    required this.employees,
    required this.isLoadingEmployees,
    required this.currentEmployeeCode,
    required this.onDepartmentSelected,
    required this.onEmployeeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = expanded.contains(unit.value);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryOpacity,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (isExpanded) {
                        expanded.remove(unit.value);
                      } else {
                        expanded.add(unit.value);
                        onDepartmentSelected(unit.value);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        unit.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: AppColors.colorIcon,
                  ),
                  onPressed: () {
                    if (isExpanded) {
                      expanded.remove(unit.value);
                    } else {
                      expanded.add(unit.value);
                      onDepartmentSelected(unit.value);
                    }
                  },
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            if (isLoadingEmployees.value)
              Container(
                margin: const EdgeInsets.only(left: 16, top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Đang tải nhân viên...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...employees.map<Widget>((employee) {
                final isEmployeeSelected =
                    selectedEmployeeCode.value == employee.employeeCode;
                // Kiểm tra nếu employeeCode trùng với currentEmployeeCode thì không cho chọn
                final isCurrentUser =
                    currentEmployeeCode != null &&
                    currentEmployeeCode!.isNotEmpty &&
                    employee.employeeCode == currentEmployeeCode;

                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CheckboxListTile(
                    value: isEmployeeSelected,
                    activeColor: AppColors.primary,
                    onChanged: isCurrentUser
                        ? null
                        : (v) {
                            if (v == true) {
                              selectedEmployeeCode.value =
                                  employee.employeeCode;
                              selectedEmployeeName.value =
                                  employee.employeeName;
                            } else {
                              selectedEmployeeCode.value = '';
                              selectedEmployeeName.value = '';
                            }
                          },
                    title: Text(
                      employee.employeeName,
                      style: TextStyle(
                        color: isCurrentUser
                            ? Colors.grey.shade400
                            : (isEmployeeSelected ? AppColors.primary : null),
                        fontWeight: isEmployeeSelected ? FontWeight.w600 : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.employeeCode,
                          style: TextStyle(
                            color: isEmployeeSelected
                                ? AppColors.primary
                                : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        if (employee.employeeEmail.isNotEmpty)
                          Text(
                            employee.employeeEmail,
                            style: TextStyle(
                              color: isEmployeeSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              }),
          ],
        ],
      );
    });
  }
}
