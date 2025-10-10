import 'package:flutter/material.dart';
import '../models/task_detail_model.dart';
import 'section_header.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';

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
        const SizedBox(height: 8),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (assignees.isEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline,
                  color: const Color(0xFFBDBDBD),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Chưa có người thực hiện',
                  style: TextStyle(
                    color: const Color(0xFF757575),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          // Hiển thị cây đổ xuống trong group
          _buildAssigneeTree(assignees),
      ],
    );
  }

  /// Xây dựng cây assignees theo dạng đổ xuống
  Widget _buildAssigneeTree(List<TaskAssignee> assignees) {
    return Column(
      children:
          assignees.map<Widget>((assignee) {
            return _buildAssigneeNode(assignee, 0);
          }).toList(),
    );
  }

  /// Xây dựng một node assignee với children
  Widget _buildAssigneeNode(TaskAssignee assignee, int level) {
    final hasChildren = assignee.children.isNotEmpty;
    final isCompleted = assignee.statusCode == 2; // Status 2 = Hoàn thành
    final nodeId = assignee.id;
    final isExpanded = _expandedNodes[nodeId] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap:
              hasChildren
                  ? () {
                    setState(() {
                      _expandedNodes[nodeId] = !isExpanded;
                    });
                  }
                  : null,
          child: Container(
            margin: EdgeInsets.only(
              left: level * 20.0, // Indent theo level
              bottom: 8,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isCompleted
                      ? AppColors
                          .primaryOpacity // Màu chính của app cho hoàn thành
                      : AppColors
                          .white, // Màu trắng bạc cho các trạng thái khác
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isCompleted
                        ? AppColors
                            .primary // Viền màu chính cho hoàn thành
                        : AppColors.grey, // Viền xám cho các trạng thái khác
                width: 0.8,
              ),
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
                // Icon với màu theo status
                Icon(
                  hasChildren ? Icons.group : Icons.person_outline,
                  color:
                      isCompleted
                          ? AppColors
                              .primary // Màu chính cho hoàn thành
                          : AppColors
                              .colorIcon, // Màu xám cho các trạng thái khác
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
                          color:
                              isCompleted
                                  ? AppColors
                                      .primary // Màu chính cho hoàn thành
                                  : AppColors
                                      .black, // Màu đen cho các trạng thái khác
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${assignee.roleName} • ${assignee.status}',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isCompleted
                                  ? AppColors.primary.withOpacity(
                                    0.7,
                                  ) // Màu chính nhạt cho hoàn thành
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
                    color:
                        isCompleted
                            ? AppColors
                                .primary // Màu chính cho hoàn thành
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
            children:
                assignee.children.map<Widget>((child) {
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
