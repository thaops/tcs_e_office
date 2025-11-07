import 'package:flutter/material.dart';

class DocumentContainer extends StatelessWidget {
  final Widget child;
  const DocumentContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ), // Giảm từ 16 xuống 12
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), // Giảm opacity shadow
            blurRadius: 3, // Giảm blur radius
            offset: const Offset(0, 1), // Giảm offset
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE8E8E8), // Border nhẹ hơn
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}
