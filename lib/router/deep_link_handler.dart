import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/Services/services.dart';
import 'package:tcs_e_office/common/widgets/app_dialog.dart';
import 'package:tcs_e_office/common/services/navigation_service.dart';
import 'package:tcs_e_office/router/app_router.dart';
import 'package:tcs_e_office/feature/private_app_shell/document_management/views/document_detail_view.dart';
import 'package:tcs_e_office/feature/private_app_shell/work_management/views/task_detail_view.dart';
import 'package:tcs_e_office/feature/private_app_shell/work_management/controllers/work_management_controller.dart';
import 'package:tcs_e_office/feature/private_app_shell/work_management/controllers/task_detail_controller.dart';
import 'package:tcs_e_office/feature/private_app_shell/document_management/controllers/document_detail_controller.dart';
import 'package:tcs_e_office/feature/private_app_shell/document_management/controllers/document_management_controller.dart';

class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();
  factory DeepLinkHandler() => _instance;
  DeepLinkHandler._internal();

  late final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri?>? _sub;
  bool _isProcessing = false;

  // Map pattern để xử lý các deep link paths
  late final Map<String, Future<void> Function(String)> _handlers = {
    '/documents-to/': _handleDocumentIncoming,
    '/documents-waiting/': _handleDocumentWaiting,
    '/documents-draft/': _handleDocumentDraft,
    '/documents-rejected/': _handleDocumentRejected,
    '/documents-approved/': _handleDocumentApproved,
    '/documents-published/': _handleDocumentPublished,
    '/task-management/assigned-to-me/': _handleTaskAssignedToMe,
    '/task-management/created-by-me/': _handleTaskCreatedByMe,
  };

  void init() {
    try {
      _sub?.cancel();
    } catch (e) {
      // Ignore error when canceling subscription
    }

    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        processDeepLink(uri);
      },
      onError: (err) {
        // Ignore stream errors
      },
      onDone: () {
        // Stream closed
      },
    );

    _checkInitialLink();
  }

  Future<void> _checkInitialLink() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        await Future.delayed(const Duration(milliseconds: 1000));
        await processDeepLink(initialLink);
      }
    } catch (e) {
      // Ignore error checking initial link
    }
  }

  Future<void> processDeepLink(Uri? uri) async {
    if (uri == null) return;

    if (_isProcessing) {
      return;
    }

    _isProcessing = true;
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await _handleDeepLink(uri);
        } catch (e) {
          // Ignore error processing deep link
        } finally {
          _isProcessing = false;
        }
      });
    } catch (e) {
      _isProcessing = false;
      rethrow;
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    // Guard: Kiểm tra app lifecycle state
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Kiểm tra authentication
    final service = await Services.create();
    final accessToken = await service.getAccessToken();

    if (accessToken.isEmpty) {
      AppDialog.showError(
        title: 'Thông báo',
        message: 'Vui lòng đăng nhập để xem nội dung này.',
        useBackdrop: false,
      );
      return;
    }

    // Normalize path
    String path = uri.path.trim();
    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    // Tìm handler phù hợp từ map
    String? matchedPrefix;
    for (final prefix in _handlers.keys) {
      if (path.startsWith(prefix)) {
        matchedPrefix = prefix;
        break;
      }
    }

    if (matchedPrefix != null) {
      final id = _extractId(path, matchedPrefix);
      if (id.isNotEmpty) {
        await _handlers[matchedPrefix]!(id);
      }
    }
  }

  // Document handlers
  Future<void> _handleDocumentIncoming(String documentId) async {
    await _navigateDetail<DocumentDetailController>(
      id: documentId,
      switchTab: _switchToDocumentManagementTab,
      createView: () =>
          DocumentDetailView(documentId: documentId, tabType: 'incoming'),
    );
  }

  Future<void> _handleDocumentWaiting(String documentId) async {
    await _navigateDetail<DocumentDetailController>(
      id: documentId,
      switchTab: _switchToDocumentManagementTab,
      createView: () =>
          DocumentDetailView(documentId: documentId, tabType: 'outgoing'),
    );
  }

  Future<void> _handleDocumentDraft(String documentId) async {
    await _navigateDetail<DocumentDetailController>(
      id: documentId,
      switchTab: _switchToDocumentManagementTab,
      createView: () =>
          DocumentDetailView(documentId: documentId, tabType: 'outgoing'),
    );
  }

  Future<void> _handleDocumentRejected(String documentId) async {
    await _navigateDetail<DocumentDetailController>(
      id: documentId,
      switchTab: _switchToDocumentManagementTab,
      createView: () =>
          DocumentDetailView(documentId: documentId, tabType: 'outgoing'),
    );
  }

  Future<void> _handleDocumentApproved(String documentId) async {
    await _navigateDetail<DocumentDetailController>(
      id: documentId,
      switchTab: _switchToDocumentManagementTab,
      createView: () =>
          DocumentDetailView(documentId: documentId, tabType: 'outgoing'),
    );
  }

  Future<void> _handleDocumentPublished(String documentId) async {
    await _navigateDetail<DocumentDetailController>(
      id: documentId,
      switchTab: _switchToDocumentManagementTab,
      createView: () =>
          DocumentDetailView(documentId: documentId, tabType: 'outgoing'),
    );
  }

  // Task handlers
  Future<void> _handleTaskAssignedToMe(String taskId) async {
    await _navigateDetail<TaskDetailController>(
      id: taskId,
      switchTab: _switchToWorkManagementTab,
      createView: () =>
          TaskDetailView(taskId: taskId, tabType: 'assigned_by_me'),
    );
  }

  Future<void> _handleTaskCreatedByMe(String taskId) async {
    await _navigateDetail<TaskDetailController>(
      id: taskId,
      switchTab: _switchToWorkManagementTab,
      createView: () =>
          TaskDetailView(taskId: taskId, tabType: 'assigned_to_me'),
    );
  }

  // Helper function chung để navigate đến detail view
  Future<void> _navigateDetail<T>({
    required String id,
    required Future<void> Function() switchTab,
    required Widget Function() createView,
  }) async {
    await _ensureMainScreen();
    await switchTab();

    // Cleanup controller cũ trước khi navigate
    if (Get.isRegistered<T>()) {
      Get.delete<T>(force: true);
    }

    await _clearStackUntilMain();
    await Get.to(createView);
  }

  Future<void> _ensureMainScreen() async {
    final currentRoute = Get.currentRoute;
    if (currentRoute != AppRouter.main) {
      Get.until((route) => route.settings.name == AppRouter.main);

      // Đợi UI render xong ngay sau Get.until
      await Future.delayed(const Duration(milliseconds: 200));
      await WidgetsBinding.instance.endOfFrame;

      // Đợi thêm để đảm bảo main screen đã được navigate xong
      int retryCount = 0;
      const maxRetries = 10;
      while (retryCount < maxRetries && Get.currentRoute != AppRouter.main) {
        await Future.delayed(const Duration(milliseconds: 100));
        await WidgetsBinding.instance.endOfFrame;
        retryCount++;
      }

      // Đợi thêm một chút để đảm bảo main screen đã render xong
      await Future.delayed(const Duration(milliseconds: 200));
      await WidgetsBinding.instance.endOfFrame;
    } else {
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _switchToDocumentManagementTab() async {
    NavigationService.navigateToDocumentManagement(
      targetTab: 0,
      resetFilter: false,
    );

    await Future.delayed(const Duration(milliseconds: 100));
    await WidgetsBinding.instance.endOfFrame;

    // Đợi DocumentManagementController được khởi tạo
    int retryCount = 0;
    const maxRetries = 10;
    while (retryCount < maxRetries) {
      try {
        Get.find<DocumentManagementController>();
        break;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 100));
        retryCount++;
      }
    }

    // Đợi layout ổn định
    for (int i = 0; i < 3; i++) {
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> _switchToWorkManagementTab() async {
    NavigationService.navigateToWorkManagement(
      targetTab: 0,
      resetFilter: false,
    );

    await Future.delayed(const Duration(milliseconds: 100));
    await WidgetsBinding.instance.endOfFrame;

    // Đợi WorkManagementController được khởi tạo
    int retryCount = 0;
    const maxRetries = 10;
    while (retryCount < maxRetries) {
      try {
        Get.find<WorkManagementController>();
        break;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 100));
        retryCount++;
      }
    }

    // Đợi layout ổn định
    for (int i = 0; i < 3; i++) {
      await WidgetsBinding.instance.endOfFrame;
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> _clearStackUntilMain() async {
    Get.until((route) => route.settings.name == AppRouter.main);
  }

  String _extractId(String path, String prefix) {
    String id = path.replaceFirst(prefix, '');

    // Remove trailing slash
    if (id.endsWith('/')) {
      id = id.substring(0, id.length - 1);
    }

    // Remove query parameters if any
    if (id.contains('?')) {
      id = id.substring(0, id.indexOf('?'));
    }

    // Trim whitespace
    id = id.trim();

    return id;
  }

  void dispose() {
    try {
      _sub?.cancel();
    } catch (e) {
      // Ignore error when disposing subscription
    }
    _sub = null;
  }
}
