import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../controllers/update_task_controller.dart';
import 'task_form_section.dart';

/// Widget cho phần đính kèm file (Update version)
class UpdateTaskAttachmentSection extends StatelessWidget {
  const UpdateTaskAttachmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UpdateTaskController>(
      builder: (c) {
        return TaskFormSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label('Tệp đính kèm'),
                  Obx(() {
                    if (c.attachmentFileNames.isNotEmpty) {
                      return TextButton(
                        onPressed: () => c.clearAllAttachments(),
                        child: const Text(
                          'Xóa tất cả',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
              const SizedBox(height: 6),
              // Nút thêm file
              GestureDetector(
                onTap: () => c.pickAttachments(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Thêm tệp đính kèm',
                        style: TextStyle(
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Danh sách file đã chọn
              Obx(() {
                final files = c.attachmentFileNames;

                if (files.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children:
                      files.asMap().entries.map((entry) {
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
  Widget _buildFileItem(String fileName, int index, UpdateTaskController c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(_getFileIcon(fileName), color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
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
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
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
