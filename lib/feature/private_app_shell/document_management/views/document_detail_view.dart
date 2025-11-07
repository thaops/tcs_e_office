import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/widgets/app_bar_widget.dart';
import 'package:tcs_e_office/common/widgets/error_404_widget.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/share/cache/my_id.dart';
import '../controllers/document_detail_controller.dart';
import '../widgets/document_header_card.dart';
import '../widgets/document_attachments_section.dart';
import '../widgets/document_preview_section.dart';
import '../widgets/document_detail_section.dart';
import '../widgets/document_comments_section.dart';
import '../widgets/document_action_buttons.dart';
import '../widgets/document_forward_bottom_sheet.dart';
import '../widgets/document_history_dialog.dart';
import '../widgets/document_distributors_dept_section.dart';
import '../services/document_action_service.dart';
import '../models/document_detail_model.dart';
import '../../work_management/views/create_task_view.dart';

class DocumentDetailView extends StatefulWidget {
  final String documentId;
  final String? tabType;

  const DocumentDetailView({super.key, required this.documentId, this.tabType});

  @override
  State<DocumentDetailView> createState() => _DocumentDetailViewState();
}

class _DocumentDetailViewState extends State<DocumentDetailView> {
  String _appBarTitle = 'Chi tiết văn bản';
  String outgoingKey = 'outgoing';
  final DocumentActionService _actionService = DocumentActionService();
  bool _isProcessingAction = false;
  bool _isDocumentRead = false;
  String? _currentUserId;

  void _updateAppBarTitle({int? status}) {
    String baseTitle = 'Chi tiết văn bản';

    if (widget.tabType == 'incoming') {
      baseTitle = 'Văn bản đến';
    } else if (widget.tabType == 'outgoing') {
      baseTitle = 'Văn bản đi';
    }

    if (status != null) {
      setState(() {
        _appBarTitle = '$baseTitle';
      });
    } else {
      setState(() {
        _appBarTitle = baseTitle;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _updateAppBarTitle();
    _loadCurrentUserId();

    if (widget.tabType == 'outgoing') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final controller = Get.find<DocumentDetailController>();
        controller.fetchDistributors();
      });
    }
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final myId = await MyId.create();
      final userId = await myId.getMyId();
      if (mounted) {
        setState(() {
          _currentUserId = userId.isNotEmpty ? userId : null;
        });
      }
    } catch (e) {
      print('Error loading current user ID: $e');
    }
  }

  PreferredSizeWidget _buildReactiveAppBar(DocumentDetailController c) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBarWidget(
        title: _appBarTitle,
        backgroundColor: AppColors.primary,
        isTitleCenter: true,
        iconRightfirst: Icons.history,
        functionfirst: () {
          _showHistoryDialog();
        },
      ),
    );
  }

  void _showHistoryDialog() {
    final controller = Get.find<DocumentDetailController>();
    final detail = controller.detail.value;

    if (detail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có lịch sử cập nhật'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (widget.tabType == 'incoming' && detail.histories.isNotEmpty) {
      DocumentHistoryDialog.showHistories(
        context,
        detail.histories,
        tabType: widget.tabType,
      );
      return;
    }

    if (detail.workflows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có lịch sử cập nhật'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    DocumentHistoryDialog.show(
      context,
      detail.workflows,
      tabType: widget.tabType,
    );
  }

  void _handleAddComment() {
    final controller = Get.find<DocumentDetailController>();
    controller.fetchDetail();
  }

  void _handleProcess() {
    showDocumentForwardBottomSheet(
      context,
      documentId: widget.documentId,
      onConfirm: (employeeCode, employeeName) async {
        await _forwardDocument(employeeCode, employeeName);
      },
    );
  }

  Future<void> _forwardDocument(
    String employeeCode,
    String employeeName,
  ) async {
    if (_isProcessingAction) return;

    setState(() {
      _isProcessingAction = true;
    });

    try {
      final result = await _actionService.forwardDocument(
        widget.documentId,
        employeeCode,
      );

      if (mounted) {
        final bool success = result['success'] as bool;
        final String message = result['message'] as String;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success
                ? const Color(0xFF339B00)
                : const Color(0xFFFF2323),
            duration: const Duration(seconds: 3),
          ),
        );

        if (success) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.of(context).pop({'refresh': true});
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: const Color(0xFFFF2323),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingAction = false;
        });
      }
    }
  }

  Future<void> _handleMarkRead() async {
    if (_isProcessingAction) return;

    setState(() {
      _isProcessingAction = true;
    });

    try {
      final success = await _actionService.markSingleAsRead(widget.documentId);

      if (mounted) {
        if (success) {
          final controller = Get.find<DocumentDetailController>();
          controller.fetchDetail();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã đánh dấu văn bản đã đọc'),
              backgroundColor: Color(0xFF339B00),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể đánh dấu đã đọc. Vui lòng thử lại'),
              backgroundColor: Color(0xFFFF2323),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: const Color(0xFFFF2323),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingAction = false;
        });
      }
    }
  }

  Future<void> _handleCreateTask(String documentTitle) async {
    try {
      final myId = await MyId.create();
      final assignerCode = await myId.getMyId();

      if (assignerCode.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Không thể lấy thông tin người dùng. Vui lòng thử lại',
              ),
              backgroundColor: Color(0xFFFF2323),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      if (mounted) {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateTaskView(
              assignerCode: assignerCode,
              documentId: widget.documentId,
              documentTitle: documentTitle,
            ),
          ),
        );

        if (result == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tạo công việc thành công'),
                backgroundColor: Color(0xFF339B00),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: const Color(0xFFFF2323),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleReject(String note) async {
    if (_isProcessingAction) return;

    setState(() {
      _isProcessingAction = true;
    });

    try {
      final result = await _actionService.approveDocuments(
        [widget.documentId],
        false,
        note: note.isEmpty ? 'Từ chối' : note,
      );

      if (mounted) {
        final bool success = result['success'] as bool;
        final String message = result['message'] as String;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success
                ? const Color(0xFF339B00)
                : const Color(0xFFFF2323),
            duration: const Duration(seconds: 3),
          ),
        );

        if (success) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.of(context).pop({'refresh': true});
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: const Color(0xFFFF2323),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingAction = false;
        });
      }
    }
  }

  Future<void> _handleApprove(bool isApprove) async {
    if (_isProcessingAction) return;

    setState(() {
      _isProcessingAction = true;
    });

    try {
      final result = await _actionService.approveDocuments([
        widget.documentId,
      ], isApprove);

      if (mounted) {
        final bool success = result['success'] as bool;
        final String message = result['message'] as String;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success
                ? const Color(0xFF339B00)
                : const Color(0xFFFF2323),
            duration: const Duration(seconds: 3),
          ),
        );

        if (success) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.of(context).pop({'refresh': true});
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: const Color(0xFFFF2323),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingAction = false;
        });
      }
    }
  }

  Future<void> _checkDocumentReadStatus(detail) async {
    try {
      final myId = await MyId.create();
      final currentUserId = await myId.getMyId();

      bool isRead = false;

      if (currentUserId.isEmpty) {
        isRead = detail.distributors.any(
          (distributor) => distributor.isRead == true,
        );
      } else {
        DistributorModel? myDistributor;
        try {
          myDistributor = detail.distributors.firstWhere(
            (distributor) => distributor.employeeCode == currentUserId,
          );
        } catch (e) {
          myDistributor = null;
        }

        if (myDistributor != null) {
          isRead = myDistributor.isRead == true;
        } else {
          isRead = detail.distributors.any(
            (distributor) => distributor.isRead == true,
          );
        }
      }

      if (mounted) {
        setState(() {
          _isDocumentRead = isRead;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDocumentRead = detail.distributors.any(
            (distributor) => distributor.isRead == true,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DocumentDetailController>(
      init: DocumentDetailController(widget.documentId),
      builder: (c) {
        return Scaffold(
          backgroundColor: AppColors.bacgroundApp,
          appBar: _buildReactiveAppBar(c),
          body: Obx(() {
            if (c.isLoading.value && c.detail.value == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (c.error.isNotEmpty) {
              return Error404Widget(
                title: 'Không thể tải dữ liệu',
                message: c.error.value,
                buttonText: 'Thử lại',
                onRetry: () {
                  c.fetchDetail();
                },
              );
            }
            final detail = c.detail.value;
            if (detail == null) {
              return const Error404Widget(
                title: 'Không tìm thấy văn bản',
                message: 'Văn bản này không tồn tại hoặc đã bị xóa.',
                showRetryButton: false,
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateAppBarTitle(status: detail.status);
              _checkDocumentReadStatus(detail);
            });

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DocumentHeaderCard(
                          detail: detail,
                          tabType: widget.tabType,
                        ),

                        DocumentDetailSection(
                          child: DocumentAttachmentsSection(
                            attachments: detail.attachments,
                          ),
                        ),
                        if (widget.tabType == outgoingKey)
                          DocumentDetailSection(
                            child: DocumentCommentsSection(
                              comments: detail.comments,
                              documentId: detail.id,
                              onAddComment: _handleAddComment,
                            ),
                          ),

                        if (widget.tabType == outgoingKey)
                          Obx(() {
                            final distributors = c.distributors;
                            return DocumentDetailSection(
                              child: DocumentDistributorsDeptSection(
                                distributors: distributors.toList(),
                              ),
                            );
                          }),

                        if (detail.category == 1 ||
                            detail.status == 2 ||
                            detail.status == 3)
                          DocumentDetailSection(
                            child: DocumentPreviewSection(
                              documentId: widget.documentId,
                              title: "Phiếu triển khai tài liệu bên ngoài",
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // Sticky action buttons ở dưới
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: DocumentActionButtons(
                    tabType: widget.tabType ?? 'incoming',
                    onProcess: _handleProcess,
                    onMarkRead: _handleMarkRead,
                    onCreateTask: () => _handleCreateTask(detail.title),
                    onReject: (note) => _handleReject(note),
                    onApprove: (isApprove) => _handleApprove(isApprove),
                    isLoading: _isProcessingAction,
                    isRead: _isDocumentRead,
                    status: detail.status,
                    workflows: detail.workflows,
                    currentUserId: _currentUserId,
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
