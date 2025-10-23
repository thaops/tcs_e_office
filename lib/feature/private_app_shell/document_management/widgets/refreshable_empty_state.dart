import 'package:flutter/material.dart';
import '../../../../common/widgets/common_empty_state.dart';

class RefreshableEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRefresh;

  const RefreshableEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: CommonEmptyState(
            icon: icon,
            title: title,
            subtitle: '$subtitle\nKéo xuống để làm mới',
            // Không có onRetry button, chỉ có pull-to-refresh
          ),
        ),
      ),
    );
  }
}
