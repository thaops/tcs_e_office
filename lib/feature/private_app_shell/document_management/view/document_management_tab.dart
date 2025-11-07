import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/document_management_controller.dart';
import '../../../../common/widgets/common_app_bar.dart';
import '../../../../common/widgets/common_tab_bar.dart';
import '../../../../common/widgets/common_search_bar.dart';
import '../views/documents_incoming_view.dart';
import '../views/documents_outgoing_view.dart';
import '../widgets/document_filter_bottom_sheet.dart';

class DocumentManagementTab extends StatefulWidget {
  const DocumentManagementTab({super.key});

  @override
  State<DocumentManagementTab> createState() => _DocumentManagementTabState();
}

class _DocumentManagementTabState extends State<DocumentManagementTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late DocumentManagementController _controller;
  StreamSubscription? _tabSubscription;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(DocumentManagementController());
    _tabController = TabController(length: 2, vsync: this);

    _tabSubscription = _controller.currentTab.listen((index) {
      if (mounted && _tabController.index != index) {
        _tabController.animateTo(index);
      }
    });

    _tabController.addListener(() {
      if (mounted && _controller.currentTab.value != _tabController.index) {
        _controller.changeTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DocumentFilterBottomSheet(
        currentFilter: _controller.getCurrentFilter(),
        onApplyFilter: (filter) => _controller.applyFilter(filter),
        onResetFilter: () => _controller.resetFilter(),
        currentTab: _controller.currentTab.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: 'Quản lý văn bản'),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            CommonTabBar(
              controller: _tabController,
              tabs: const [
                CommonTabItem(icon: Icons.inbox_outlined, label: 'Văn bản đến'),
                CommonTabItem(icon: Icons.outbox_outlined, label: 'Văn bản đi'),
              ],
            ),

            Obx(() {
              final isTabIncoming = _controller.currentTab.value == 0;
              return CommonSearchBar(
                controller: isTabIncoming
                    ? _controller.searchControllerIncoming
                    : _controller.searchControllerOutgoing,
                hintText: 'Nhập trích yếu…',
                searchQuery: isTabIncoming
                    ? _controller.searchQueryIncoming.value
                    : _controller.searchQueryOutgoing.value,
                isLoading: isTabIncoming
                    ? _controller.isLoadingIncoming.value
                    : _controller.isLoadingOutgoing.value,
                onSearchChanged: isTabIncoming
                    ? _controller.onSearchChangedIncoming
                    : _controller.onSearchChangedOutgoing,
                onClearSearch: isTabIncoming
                    ? _controller.clearSearchIncoming
                    : _controller.clearSearchOutgoing,
                onFilterPressed: _showFilterBottomSheet,
                hasActiveFilter: _controller.getCurrentFilter().hasActiveFilter,
              );
            }),

            Expanded(
              child: Container(
                color: Colors.white,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    DocumentsIncomingView(),
                    DocumentsOutgoingView(status: null),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
