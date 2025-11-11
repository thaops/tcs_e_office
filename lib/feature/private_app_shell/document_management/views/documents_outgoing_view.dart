import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/document_management_controller.dart';
import '../widgets/document_card_widget.dart';
import '../widgets/refreshable_empty_state.dart';
import '../../../../common/widgets/common_loading_indicator.dart';
import 'package:tcs_e_office/common/constants/app_tab_types.dart';

class DocumentsOutgoingView extends StatelessWidget {
  final int? status;
  const DocumentsOutgoingView({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentManagementController>();

    return Obx(() {
      if (controller.isLoadingOutgoing.value &&
          controller.documentsOutgoing.isEmpty) {
        return const CommonLoadingIndicator(
          message: 'Đang tải văn bản...',
          isFullScreen: true,
        );
      }

      if (controller.filteredDocumentsOutgoing.isEmpty) {
        return RefreshableEmptyState(
          icon: Icons.outbox_outlined,
          title: 'Không có văn bản đi',
          subtitle: 'Chưa có văn bản nào được gửi đi',
          onRefresh: () => controller.refreshWithStatus(status),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshWithStatus(status),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200 &&
                !controller.isLoadingOutgoing.value &&
                controller.documentsOutgoing.length <
                    controller.totalRecordOutgoing.value) {
              controller.loadMoreWithStatus(status);
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                controller.filteredDocumentsOutgoing.length +
                (controller.isLoadingOutgoing.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.filteredDocumentsOutgoing.length) {
                return const CommonLoadingIndicator();
              }

              final document = controller.filteredDocumentsOutgoing[index];
              return DocumentCardWidget(
                document: document,
                tabType: AppTabTypes.DOCUMENT_OUT,
              );
            },
          ),
        ),
      );
    });
  }
}
