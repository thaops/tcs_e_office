import 'package:flutter/material.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/widgets/enhanced_text_widget.dart';
import '../services/document_preview_service.dart';
import 'document_viewer_section.dart';
import 'section_header.dart';

class DocumentPreviewSection extends StatefulWidget {
  final String documentId;
  final String title;
  const DocumentPreviewSection({super.key, required this.documentId, required this.title});

  @override
  State<DocumentPreviewSection> createState() => _DocumentPreviewSectionState();
}

class _DocumentPreviewSectionState extends State<DocumentPreviewSection> {
  final DocumentPreviewService _previewService = DocumentPreviewService();
  String? _previewUrl;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPreviewUrl();
  }

  Future<void> _loadPreviewUrl() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final url = await _previewService.getPreviewUrl(widget.documentId);
      if (mounted) {
        setState(() {
          _previewUrl = url;
          _isLoading = false;
          if (url == null) {
            _hasError = true;
            _errorMessage = 'Không thể tải tài liệu preview';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Lỗi khi tải preview: $e';
        });
      }
    }
  }

  void _retryLoad() {
    _loadPreviewUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoading)
          _buildLoadingState()
        else if (_hasError)
          _buildErrorState()
        else if (_previewUrl != null)
          DocumentViewerSection(pdfUrl: _previewUrl!, title: widget.title)
        else
          _buildEmptyState(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.bacgroundApp,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006884)),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải tài liệu...',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.bacgroundApp,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 40, color: AppColors.colorRed),
              const SizedBox(height: 12),
              Text(
                'Không thể tải tài liệu',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.colorRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  _errorMessage.isNotEmpty
                      ? _errorMessage
                      : 'Vui lòng kiểm tra kết nối mạng',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _retryLoad,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Thử lại', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.bacgroundApp,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                size: 40,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 12),
              Text(
                'Không có tài liệu preview',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                'Tài liệu này không có phiếu triển khai',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
