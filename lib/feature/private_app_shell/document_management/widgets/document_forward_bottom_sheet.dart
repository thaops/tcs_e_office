import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/share/cache/my_id.dart';
import '../../work_management/controllers/task_api_service.dart';
import '../../work_management/models/task_detail_model.dart';

Future<void> showDocumentForwardBottomSheet(
  BuildContext context, {
  required String documentId,
  required void Function(String employeeCode, String employeeName) onConfirm,
}) async {
  final controller = _DocumentForwardController();
  final RxString keyword = ''.obs;
  final RxString selectedEmployeeCode = ''.obs;
  final RxString selectedEmployeeName = ''.obs;
  final RxSet<String> expanded = <String>{}.obs;
  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();
  String? _currentEmployeeCode;

  Future<void> _loadCurrentEmployeeCode() async {
    try {
      final myId = await MyId.create();
      final employeeCode = await myId.getMyId();
      _currentEmployeeCode = employeeCode.isNotEmpty ? employeeCode : null;
    } catch (e) {
      debugPrint('Error loading current employee code: $e');
      _currentEmployeeCode = null;
    }
  }

  void _resetSearchState() {
    _searchController.clear();
    keyword.value = '';
    _debounceTimer?.cancel();
    Future.microtask(() async {
      await _loadCurrentEmployeeCode();
      try {
        await controller.searchEmployees('');
      } catch (e) {
        debugPrint('Controller không hỗ trợ search: $e');
      }
    });
  }

  _resetSearchState();

  _searchController.addListener(() {
    keyword.value = _searchController.text;
  });

  void _handleSearch(String value) {
    final trimmedValue = value.trim();

    _debounceTimer?.cancel();

    if (trimmedValue.isEmpty) {
      try {
        controller.searchEmployees('');
      } catch (e) {
        debugPrint('Controller không hỗ trợ search: $e');
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      try {
        controller.searchEmployees(trimmedValue);
      } catch (e) {
        debugPrint('Controller không hỗ trợ search: $e');
      }
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
                          _debounceTimer?.cancel();
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),

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
                child: Obx(
                  () => TextField(
                    controller: _searchController,
                    onChanged: _handleSearch,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm nhân viên...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.search_rounded,
                          color: controller.searching.value
                              ? AppColors.primary
                              : Colors.grey.shade600,
                          size: 22,
                        ),
                      ),
                      suffixIcon: controller.searching.value
                          ? Container(
                              padding: const EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            )
                          : _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _debounceTimer?.cancel();
                                try {
                                  controller.searchEmployees('');
                                } catch (e) {
                                  debugPrint(
                                    'Controller không hỗ trợ search: $e',
                                  );
                                }
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
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Obx(() {
                  if (controller.searching.value) {
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
                            'Đang tìm kiếm nhân viên...',
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

                  if (controller.departmentTree.isEmpty) {
                    if (keyword.value.isNotEmpty) {
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
                              'Không tìm thấy nhân viên',
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
                    return _buildSkeletonLoading();
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: controller.departmentTree
                          .map<Widget>(
                            (node) => _DeptNode(
                              node: node,
                              keyword: keyword,
                              expanded: expanded,
                              selectedEmployeeCode: selectedEmployeeCode,
                              selectedEmployeeName: selectedEmployeeName,
                              currentEmployeeCode: _currentEmployeeCode,
                            ),
                          )
                          .toList(),
                    ),
                  );
                }),
              ),

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
                              _debounceTimer?.cancel();
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

class _DocumentForwardController {
  final RxList<DepartmentNode> _departmentTree = <DepartmentNode>[].obs;
  final RxBool _searching = false.obs;
  final TaskApiService _apiService = TaskApiService();

  List<DepartmentNode> get departmentTree => _departmentTree;

  RxBool get searching => _searching;

  Future<void> searchEmployees(String keyword) async {
    final trimmedKeyword = keyword.trim();

    _searching.value = true;
    try {
      final searchResults = await _apiService.searchEmployeesByDepartment(
        trimmedKeyword,
      );
      _departmentTree.assignAll(searchResults);
    } catch (e) {
      debugPrint('Error searching employees: $e');
    } finally {
      _searching.value = false;
    }
  }
}

Widget _buildSkeletonLoading() {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: List.generate(5, (index) => _buildSkeletonItem(index)),
    ),
  );
}

Widget _buildSkeletonItem(int index) {
  return TweenAnimationBuilder<double>(
    duration: Duration(milliseconds: 600 + (index * 100)),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, value, child) {
      return Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
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
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 16),
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

class _DeptNode extends StatelessWidget {
  final DepartmentNode node;
  final RxString keyword;
  final RxSet<String> expanded;
  final RxString selectedEmployeeCode;
  final RxString selectedEmployeeName;
  final String? currentEmployeeCode;
  final int level;

  const _DeptNode({
    required this.node,
    required this.keyword,
    required this.expanded,
    required this.selectedEmployeeCode,
    required this.selectedEmployeeName,
    this.currentEmployeeCode,
    this.level = 0,
  });

  bool _matches(String text, String kw) {
    if (kw.isEmpty) return true;
    return text.toLowerCase().contains(kw.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = node.children.isNotEmpty || node.employees.isNotEmpty;
    return Obx(() {
      final isExpanded = expanded.contains(node.code);
      final kw = keyword.value;
      final filteredEmployees = node.employees.where(
        (e) => _matches(e.employeeName, kw) || _matches(e.employeeCode, kw),
      );
      final filteredChildren = node.children
          .map<Widget>(
            (c) => _DeptNode(
              node: c,
              keyword: keyword,
              expanded: expanded,
              selectedEmployeeCode: selectedEmployeeCode,
              selectedEmployeeName: selectedEmployeeName,
              currentEmployeeCode: currentEmployeeCode,
              level: level + 1,
            ),
          )
          .toList();
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
                SizedBox(width: level * 16.0),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (isExpanded) {
                        expanded.remove(node.code);
                      } else {
                        expanded.add(node.code);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        node.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasChildren)
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
                        expanded.remove(node.code);
                      } else {
                        expanded.add(node.code);
                      }
                    },
                  ),
              ],
            ),
          ),
          if (isExpanded) ...[
            ...filteredEmployees.map<Widget>((emp) {
              final isEmployeeSelected =
                  selectedEmployeeCode.value == emp.employeeCode;
              final isCurrentUser =
                  currentEmployeeCode != null &&
                  currentEmployeeCode!.isNotEmpty &&
                  emp.employeeCode == currentEmployeeCode;

              return Padding(
                padding: EdgeInsets.only(left: (level + 1) * 16.0),
                child: CheckboxListTile(
                  value: isEmployeeSelected,
                  activeColor: AppColors.primary,
                  onChanged: isCurrentUser
                      ? null
                      : (v) {
                          if (v == true) {
                            selectedEmployeeCode.value = emp.employeeCode;
                            selectedEmployeeName.value = emp.employeeName;
                          } else {
                            selectedEmployeeCode.value = '';
                            selectedEmployeeName.value = '';
                          }
                        },
                  title: Text(
                    emp.employeeName,
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.grey.shade400
                          : (isEmployeeSelected ? AppColors.primary : null),
                      fontWeight: isEmployeeSelected ? FontWeight.w600 : null,
                    ),
                  ),
                  subtitle: Text(
                    emp.employeeCode,
                    style: TextStyle(
                      color: isEmployeeSelected
                          ? AppColors.primary
                          : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              );
            }),
            ...filteredChildren,
          ],
        ],
      );
    });
  }
}
