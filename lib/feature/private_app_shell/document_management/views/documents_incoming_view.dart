import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/document_management_controller.dart';
import '../widgets/document_card_widget.dart';
import '../widgets/refreshable_empty_state.dart';
import '../../../../common/widgets/common_loading_indicator.dart';

class DocumentsIncomingView extends StatelessWidget {
  const DocumentsIncomingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentManagementController>();

    return Obx(() {
      if (controller.isLoadingIncoming.value &&
          controller.documentsIncoming.isEmpty) {
        return const CommonLoadingIndicator(
          message: 'Đang tải văn bản...',
          isFullScreen: true,
        );
      }

      if (controller.filteredDocumentsIncoming.isEmpty) {
        return RefreshableEmptyState(
          icon: Icons.inbox_outlined,
          title: 'Không có văn bản đến',
          subtitle: 'Chưa có văn bản nào được gửi đến bạn',
          onRefresh: controller.refresh,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200 &&
                !controller.isLoadingIncoming.value &&
                controller.documentsIncoming.length <
                    controller.totalRecordIncoming.value) {
              controller.loadMore();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                controller.filteredDocumentsIncoming.length +
                (controller.isLoadingIncoming.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.filteredDocumentsIncoming.length) {
                return const CommonLoadingIndicator();
              }

              final document = controller.filteredDocumentsIncoming[index];
              return DocumentCardWidget(
                document: document,
                tabType: 'incoming',
              );
            },
          ),
        ),
      );
    });
  }
}
