import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../models/task_detail_model.dart';

Future<void> showAssigneeSelectorBottomSheet(
  BuildContext context, {
  required dynamic
  controller, // Hỗ trợ cả CreateTaskController và UpdateTaskController
  required void Function(List<String> selectedEmployeeCodes) onConfirm,
  List<String> initialSelectedCodes = const [],
  String title = 'Chọn người thực hiện', // Thêm parameter cho title
  List<String> excludedEmployeeCodes = const [],
}) async {
  final c = controller;
  final RxString keyword = ''.obs;
  final RxSet<String> selected = <String>{}.obs;
  final RxSet<String> expanded = <String>{}.obs;
  Timer? _debounceTimer; // Timer cho debounce
  final TextEditingController _searchController =
      TextEditingController(); // Controller cho search field

  // Khởi tạo sẵn những người đã chọn
  if (initialSelectedCodes.isNotEmpty) {
    selected.addAll(initialSelectedCodes);
  }

  // Reset search state khi mở bottom sheet (optimized for instant opening)
  void _resetSearchState() {
    _searchController.clear();
    keyword.value = '';
    _debounceTimer?.cancel();
    // Load data trong background, không block UI
    Future.microtask(() async {
      try {
        await c.searchEmployees(''); // Load data async
      } catch (e) {
        debugPrint('Controller không hỗ trợ search: $e');
      }
    });
  }

  // Gọi reset ngay khi mở bottom sheet (không await)
  _resetSearchState();

  // Thêm listener để update UI khi text thay đổi
  _searchController.addListener(() {
    // Trigger UI update khi text thay đổi
    keyword.value = _searchController.text;
  });

  // Function để xử lý search với debounce
  void _handleSearch(String value) {
    final trimmedValue = value.trim();
    // keyword.value đã được set trong listener, không cần set lại

    // Hủy timer cũ nếu có
    _debounceTimer?.cancel();

    // Nếu search rỗng, gọi ngay lập tức để reset data
    if (trimmedValue.isEmpty) {
      try {
        c.searchEmployees('');
      } catch (e) {
        debugPrint('Controller không hỗ trợ search: $e');
      }
      return;
    }

    // Tạo timer mới với delay 500ms cho search có keyword
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      try {
        c.searchEmployees(trimmedValue);
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
                        title,
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
                          color:
                              c.searching.value
                                  ? AppColors.primary
                                  : Colors.grey.shade600,
                          size: 22,
                        ),
                      ),
                      suffixIcon:
                          c.searching.value
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
                                  // Clear text field và reset data ngay lập tức
                                  _searchController
                                      .clear(); // keyword.value sẽ được update qua listener
                                  _debounceTimer?.cancel();
                                  try {
                                    c.searchEmployees('');
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

              // Tree list
              Expanded(
                child: Obx(() {
                  // Hiển thị loading khi đang search
                  if (c.searching.value) {
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

                  // Hiển thị skeleton khi chưa có dữ liệu
                  if (c.departmentTree.isEmpty) {
                    // Nếu đang có keyword thì hiển thị empty state
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
                    // Nếu không có keyword thì hiển thị skeleton loading
                    return _buildSkeletonLoading();
                  }

                  // Hiển thị danh sách
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children:
                          c.departmentTree
                              .map<Widget>(
                                (node) => _DeptNode(
                                  node: node,
                                  keyword: keyword,
                                  expanded: expanded,
                                  selected: selected,
                                  excludedEmployeeCodes: excludedEmployeeCodes,
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
                  child: ElevatedButton(
                    onPressed: () {
                      _debounceTimer?.cancel(); // Chỉ cancel timer
                      onConfirm(selected.toList());
                      Navigator.of(ctx).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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

class _DeptNode extends StatelessWidget {
  final DepartmentNode node;
  final RxString keyword;
  final RxSet<String> expanded;
  final RxSet<String> selected; // employeeCodes
  final int level; // Thêm level để xác định cấp bậc
  final List<String>
  excludedEmployeeCodes; // Thêm danh sách những người đã chọn ở role khác

  const _DeptNode({
    required this.node,
    required this.keyword,
    required this.expanded,
    required this.selected,
    this.level = 0, // Mặc định level 0 cho phòng ban gốc
    this.excludedEmployeeCodes = const [], // Mặc định rỗng
  });

  bool _matches(String text, String kw) {
    if (kw.isEmpty) return true;
    return text.toLowerCase().contains(kw.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = node.children.isNotEmpty || node.employees.isNotEmpty;
    return Obx(() {
      // Các giá trị phụ thuộc Rx phải được tính bên trong Obx
      final isExpanded = expanded.contains(node.code);
      final kw = keyword.value;
      final filteredEmployees = node.employees.where(
        (e) => _matches(e.employeeName, kw) || _matches(e.employeeCode, kw),
      );
      // Tính trạng thái checkbox phòng theo cây nhân viên con
      final subtreeEmployeeCodes = _collectEmployeeCodes(node).toList();
      final int totalCount = subtreeEmployeeCodes.length;
      final int selectedCount =
          subtreeEmployeeCodes.where((code) => selected.contains(code)).length;
      final bool allSelected = totalCount > 0 && selectedCount == totalCount;
      final bool noneSelected = selectedCount == 0;
      final filteredChildren =
          node.children
              .map<Widget>(
                (c) => _DeptNode(
                  node: c,
                  keyword: keyword,
                  expanded: expanded,
                  selected: selected,
                  level: level + 1, // Tăng level cho phòng ban con
                  excludedEmployeeCodes: excludedEmployeeCodes,
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
                // Thêm indent dựa trên level
                SizedBox(width: level * 16.0), // Mỗi level indent 16px
                Checkbox(
                  value: allSelected ? true : (noneSelected ? false : null),
                  tristate: true,
                  activeColor: AppColors.primary,
                  onChanged: (_) {
                    if (allSelected) {
                      for (final code in subtreeEmployeeCodes) {
                        selected.remove(code);
                      }
                    } else {
                      for (final code in subtreeEmployeeCodes) {
                        selected.add(code);
                      }
                    }
                  },
                ),
                const SizedBox(width: 4),
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
              final checked = selected.contains(emp.employeeCode);
              final isExcluded = excludedEmployeeCodes.contains(
                emp.employeeCode,
              );
              final isDisabled =
                  isExcluded &&
                  !checked; // Disable nếu đã chọn ở role khác và chưa chọn ở role hiện tại

              return Padding(
                padding: EdgeInsets.only(
                  left: (level + 1) * 16.0,
                ), // Indent cho nhân viên
                child: CheckboxListTile(
                  value: checked,
                  activeColor: AppColors.primary,
                  onChanged:
                      isDisabled
                          ? null
                          : (v) {
                            if (v == true) {
                              selected.add(emp.employeeCode);
                            } else {
                              selected.remove(emp.employeeCode);
                            }
                          },
                  title: Text(
                    emp.employeeName,
                    style: TextStyle(color: isDisabled ? Colors.grey : null),
                  ),
                  subtitle: Text(
                    emp.employeeCode,
                    style: TextStyle(color: isDisabled ? Colors.grey : null),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                  secondary:
                      isExcluded && !checked
                          ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Đã chọn',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                          : null,
                ),
              );
            }),
            ...filteredChildren,
          ],
        ],
      );
    });
  }

  Iterable<String> _collectEmployeeCodes(DepartmentNode n) sync* {
    for (final e in n.employees) {
      yield e.employeeCode;
    }
    for (final child in n.children) {
      yield* _collectEmployeeCodes(child);
    }
  }
}
