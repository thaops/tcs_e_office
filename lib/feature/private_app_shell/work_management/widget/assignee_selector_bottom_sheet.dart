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
  List<String> excludedEmployeeCodes =
      const [], // Thêm parameter để loại trừ những người đã chọn ở role khác
}) async {
  final c = controller;
  final RxString keyword = ''.obs;
  final RxSet<String> selected = <String>{}.obs;
  final RxSet<String> expanded = <String>{}.obs;

  // Khởi tạo sẵn những người đã chọn
  if (initialSelectedCodes.isNotEmpty) {
    selected.addAll(initialSelectedCodes);
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    isDismissible: true,
    useSafeArea: true,
    builder: (ctx) {
      return AnimatedContainer(
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
                      icon: const Icon(Icons.close, color: AppColors.colorIcon),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => keyword.value = v.trim(),
                decoration: const InputDecoration(
                  hintText: 'Nhập từ khóa…',
                  prefixIcon: Icon(Icons.search, color: AppColors.colorIcon),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tree list
            Expanded(
              child:
                  c.departmentTree.isEmpty
                      ? _buildSkeletonLoading()
                      : SingleChildScrollView(
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
                                      excludedEmployeeCodes:
                                          excludedEmployeeCodes,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
            ),

            // Confirm button
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: () {
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
      );
    },
  );
}

/// Widget skeleton loading cho danh sách departments
Widget _buildSkeletonLoading() {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(children: List.generate(3, (index) => _buildSkeletonItem())),
  );
}

/// Widget skeleton cho một item
Widget _buildSkeletonItem() {
  return Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      children: [
        // Skeleton checkbox
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
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
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 12,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
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
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    ),
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
