import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/widgets/empty_state_widget.dart';
import '../controllers/create_task_controller.dart';
import '../widget/assignee_selector_bottom_sheet.dart';

/// Widget cho phần danh sách người thực hiện
class TaskAssigneeSection extends StatelessWidget {
  const TaskAssigneeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateTaskController>(
      builder: (c) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Danh sách người thực hiện',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              _assigneeCard(
                title: 'Xử lý chính',
                selectedCodes: c.primaryEmployeeCodes,
                controller: c,
                onAdd: () => _openAssigneeSelector(
                  context,
                  controller: c,
                  initialSelectedCodes: c.primaryEmployeeCodes.toList(),
                  excludedEmployeeCodes: [
                    ...c.collabEmployeeCodes,
                    ...c.followEmployeeCodes,
                  ],
                  onConfirm: (codes) {
                    // Loại bỏ những người được chọn làm xử lý chính khỏi các role khác
                    _removeFromOtherRoles(c, codes, 'primary');
                    c.primaryEmployeeCodes.assignAll(codes);
                  },
                ),
              ),
              const SizedBox(height: 6),
              _assigneeCard(
                title: 'Phối hợp',
                selectedCodes: c.collabEmployeeCodes,
                controller: c,
                onAdd: () => _openAssigneeSelector(
                  context,
                  controller: c,
                  initialSelectedCodes: c.collabEmployeeCodes.toList(),
                  excludedEmployeeCodes: [
                    ...c.primaryEmployeeCodes,
                    ...c.followEmployeeCodes,
                  ],
                  onConfirm: (codes) {
                    // Loại bỏ những người được chọn làm phối hợp khỏi các role khác
                    _removeFromOtherRoles(c, codes, 'collab');
                    c.collabEmployeeCodes.assignAll(codes);
                  },
                ),
              ),
              const SizedBox(height: 6),
              _assigneeCard(
                title: 'Theo dõi',
                selectedCodes: c.followEmployeeCodes,
                controller: c,
                onAdd: () => _openAssigneeSelector(
                  context,
                  controller: c,
                  initialSelectedCodes: c.followEmployeeCodes.toList(),
                  excludedEmployeeCodes: [
                    ...c.primaryEmployeeCodes,
                    ...c.collabEmployeeCodes,
                  ],
                  onConfirm: (codes) {
                    // Loại bỏ những người được chọn làm theo dõi khỏi các role khác
                    _removeFromOtherRoles(c, codes, 'follow');
                    c.followEmployeeCodes.assignAll(codes);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _assigneeCard({
    required String title,
    required RxList<String> selectedCodes,
    required VoidCallback onAdd,
    required CreateTaskController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Obx(() {
                  final count = selectedCodes.length;
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOpacity,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(
                    Icons.person_add_alt_1_outlined,
                    color: Color(0xFF006884),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Obx(() {
              if (selectedCodes.isEmpty) {
                return EmptyStatePresets.listEmpty(title: 'Không có dữ liệu');
              }

              // Map mã -> tên nhân viên
              final codeToName = {
                for (final e in controller.allEmployees)
                  e.employeeCode: e.employeeName,
              };

              return Padding(
                padding: EdgeInsets.all(selectedCodes.length > 0 ? 8 : 0),
                child: Column(
                  children: [
                    ...selectedCodes.map((code) {
                      final name = codeToName[code] ?? code;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE8E8E8),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              spacing: 4,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => selectedCodes.remove(code),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _openAssigneeSelector(
    BuildContext context, {
    required CreateTaskController controller,
    required void Function(List<String> selectedEmployeeCodes) onConfirm,
    List<String> initialSelectedCodes = const [],
    List<String> excludedEmployeeCodes = const [],
  }) {
    showAssigneeSelectorBottomSheet(
      context,
      controller: controller,
      onConfirm: onConfirm,
      initialSelectedCodes: initialSelectedCodes,
      excludedEmployeeCodes: excludedEmployeeCodes,
    );
  }

  /// Loại bỏ những người được chọn ở role mới khỏi các role khác
  void _removeFromOtherRoles(
    CreateTaskController controller,
    List<String> newSelectedCodes,
    String currentRole,
  ) {
    for (final code in newSelectedCodes) {
      // Loại bỏ khỏi primary nếu không phải role hiện tại
      if (currentRole != 'primary') {
        controller.primaryEmployeeCodes.remove(code);
      }

      // Loại bỏ khỏi collab nếu không phải role hiện tại
      if (currentRole != 'collab') {
        controller.collabEmployeeCodes.remove(code);
      }

      // Loại bỏ khỏi follow nếu không phải role hiện tại
      if (currentRole != 'follow') {
        controller.followEmployeeCodes.remove(code);
      }
    }
  }
}
