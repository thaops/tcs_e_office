import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/widgets/empty_state_widget.dart';
import '../controllers/create_task_controller.dart';

/// Widget cho phần tệp đính kèm
class TaskAttachmentSection extends StatelessWidget {
  const TaskAttachmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateTaskController>(
      builder: (c) {
        return Container(
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            top: 4,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label('Tệp đính kèm'),
                  IconButton(
                    onPressed: () => c.pickAttachments(),
                    icon: const Icon(
                      Icons.attach_file_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Obx(() {
                final files = c.attachmentFileNames;

                if (files.isEmpty) {
                  return EmptyStatePresets.listEmpty(
                    title: 'Chưa có tệp đính kèm',
                    onTap: () => c.pickAttachments(),
                  );
                }

                return Column(
                  children: files.asMap().entries.map((entry) {
                    final index = entry.key;
                    final fileName = entry.value;
                    return _buildFileItem(fileName, index, c);
                  }).toList(),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w600));
  }

  /// Widget hiển thị từng file với nút xóa
  Widget _buildFileItem(String fileName, int index, CreateTaskController c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Row(
        children: [
          Icon(_getFileIcon(fileName), color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => c.removeAttachment(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// Lấy icon theo loại file
  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.attach_file;
    }
  }
}
