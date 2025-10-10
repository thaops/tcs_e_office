import 'package:flutter/material.dart';

/// Widget tái sử dụng cho các section form
class TaskFormSection extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const TaskFormSection({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
