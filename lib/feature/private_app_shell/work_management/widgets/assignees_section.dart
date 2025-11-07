import 'package:flutter/material.dart';
import '../models/task_detail_model.dart';
import 'section_header.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/widgets/empty_state_widget.dart';

class AssigneesSection extends StatefulWidget {
  final List<TaskAssignee> assignees;

  const AssigneesSection({super.key, required this.assignees});

  @override
  State<AssigneesSection> createState() => _AssigneesSectionState();
}

class _AssigneesSectionState extends State<AssigneesSection> {
  bool _isExpanded = true;
  final Map<String, bool> _expandedNodes =
      {}; // Track expanded state for each node

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Danh sách người thực hiện',
          icon: Icons.group_outlined,
          trailing: IconButton(
            icon: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xFF006884),
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
        ),
        const SizedBox(height: 6), // Chuẩn hóa spacing
        if (_isExpanded) ...[
          _assigneeGroup(
            'Xử lý chính',
            widget.assignees.where((a) => a.roleId == 1).toList(),
          ),
          const SizedBox(height: 8),
          _assigneeGroup(
            'Phối hợp',
            widget.assignees.where((a) => a.roleId == 2).toList(),
          ),
          const SizedBox(height: 8),
          _assigneeGroup(
            'Theo dõi',
            widget.assignees.where((a) => a.roleId == 3).toList(),
          ),
        ],
      ],
    );
  }

  Widget _assigneeGroup(String title, List<TaskAssignee> assignees) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12, // Giảm font size
              ),
            ),
          ),
          const SizedBox(height: 6), // Giảm spacing
          if (assignees.isEmpty)
            EmptyStatePresets.listEmpty(title: 'Không có dữ liệu')
          else
            // Hiển thị cây đổ xuống trong group
            _buildAssigneeTree(assignees),
        ],
      ),
    );
  }

  /// Xây dựng cây assignees theo dạng đổ xuống
  Widget _buildAssigneeTree(List<TaskAssignee> assignees) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: assignees.map<Widget>((assignee) {
          return _buildAssigneeNode(assignee, 0);
        }).toList(),
      ),
    );
  }

  /// Xây dựng một node assignee với children
  Widget _buildAssigneeNode(TaskAssignee assignee, int level) {
    final hasChildren = assignee.children.isNotEmpty;
    final isCompleted = assignee.statusCode == 2; // Status 2 = Hoàn thành
    final isOverdue = assignee.statusCode == 3; // Status 3 = Quá hạn
    final nodeId = assignee.id;
    final isExpanded = _expandedNodes[nodeId] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: hasChildren
              ? () {
                  setState(() {
                    _expandedNodes[nodeId] = !isExpanded;
                  });
                }
              : null,
          child: Container(
            margin: EdgeInsets.only(
              left: level * 16.0, // Giảm indent từ 20 xuống 16
              bottom: 6, // Giảm margin bottom
            ),
            padding: const EdgeInsets.all(8), // Giảm padding từ 10 xuống 8
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors
                        .primaryOpacity // Màu chính của app cho hoàn thành
                  : isOverdue
                  ? Colors.red.withOpacity(0.1) // Background đỏ nhẹ cho quá hạn
                  : const Color(
                      0xFFFAFAFA,
                    ), // Background nhạt cho các trạng thái khác
              borderRadius: BorderRadius.circular(6), // Giảm border radius
              border: Border.all(
                color: isCompleted
                    ? AppColors
                          .primary // Viền màu chính cho hoàn thành
                    : isOverdue
                    ? Colors.red.withOpacity(0.3) // Viền đỏ nhẹ cho quá hạn
                    : const Color(
                        0xFFE8E8E8,
                      ), // Border nhẹ hơn cho các trạng thái khác
                width: 0.5, // Giảm border width
              ),
            ),
            child: Row(
              children: [
                // Icon với màu theo status
                Icon(
                  hasChildren ? Icons.group : Icons.person_outline,
                  color: isCompleted
                      ? AppColors
                            .primary // Màu chính cho hoàn thành
                      : isOverdue
                      ? Colors
                            .red // Màu đỏ cho quá hạn
                      : AppColors.colorIcon, // Màu xám cho các trạng thái khác
                  size: 20,
                ),
                const SizedBox(width: 10),
                // Thông tin assignee
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${assignee.name} – ${assignee.code}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isCompleted
                              ? AppColors
                                    .primary // Màu chính cho hoàn thành
                              : isOverdue
                              ? Colors
                                    .red // Màu đỏ cho quá hạn
                              : AppColors
                                    .black, // Màu đen cho các trạng thái khác
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${assignee.roleName} • ${assignee.status}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isCompleted
                              ? AppColors.primary.withOpacity(
                                  0.7,
                                ) // Màu chính nhạt cho hoàn thành
                              : isOverdue
                              ? Colors.red.withOpacity(
                                  0.7,
                                ) // Màu đỏ nhạt cho quá hạn
                              : AppColors
                                    .colortextGray, // Màu xám cho các trạng thái khác
                        ),
                      ),
                      if (isCompleted && assignee.completedDate != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Hoàn thành: ${_formatDateTime(assignee.completedDate!)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Icon mũi tên nếu có children
                if (hasChildren)
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isCompleted
                        ? AppColors
                              .primary // Màu chính cho hoàn thành
                        : isOverdue
                        ? Colors
                              .red // Màu đỏ cho quá hạn
                        : AppColors
                              .colorIcon, // Màu xám cho các trạng thái khác
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
        // Hiển thị children nếu có và đang mở
        if (hasChildren && isExpanded)
          Column(
            children: assignee.children.map<Widget>((child) {
              return _buildAssigneeNode(child, level + 1);
            }).toList(),
          ),
      ],
    );
  }

  /// Format ngày giờ hoàn thành
  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
}
