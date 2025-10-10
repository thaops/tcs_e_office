import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../controllers/create_task_controller.dart';
import '../widget/assignee_selector_bottom_sheet.dart';
import 'task_form_section.dart';

/// Widget cho phần danh sách người thực hiện
class TaskAssigneeSection extends StatelessWidget {
  const TaskAssigneeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateTaskController>(
      builder: (c) {
        return TaskFormSection(
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
                onAdd:
                    () => _openAssigneeSelector(
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
                onAdd:
                    () => _openAssigneeSelector(
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
                onAdd:
                    () => _openAssigneeSelector(
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Obx(() {
                  final count = selectedCodes.length;
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
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
                    Icons.person_outline,
                    color: Color(0xFF006884),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: Obx(() {
                if (selectedCodes.isEmpty) {
                  return Row(
                    children: [
                      Icon(
                        Icons.person_add_alt_1_outlined,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Không có dữ liệu',
                          style: TextStyle(color: Color(0xFF757575)),
                        ),
                      ),
                    ],
                  );
                }
                // Map mã -> tên nhân viên
                final codeToName = {
                  for (final e in controller.allEmployees)
                    e.employeeCode: e.employeeName,
                };
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...selectedCodes.map((code) {
                      final name = codeToName[code] ?? code;
                      return InputChip(
                        avatar: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          radius: 10,
                          child: Text(
                            _initialsFromName(name),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        label: Text(name),
                        backgroundColor: AppColors.backgroundTab,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onPressed: onAdd,
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          selectedCodes.remove(code);
                        },
                      );
                    }),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _initialsFromName(String name) {
    final parts =
        name.trim().split(RegExp(r"\s+")).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
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
