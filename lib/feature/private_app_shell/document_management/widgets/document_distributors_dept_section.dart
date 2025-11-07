import 'package:flutter/material.dart';
import 'package:tcs_e_office/common/widgets/empty_state_widget.dart';
import '../models/document_detail_model.dart';
import 'section_header.dart';

/// Widget hiển thị danh sách distributors (departments) cho văn bản đi
class DocumentDistributorsDeptSection extends StatefulWidget {
  final List<DistributorDeptModel> distributors;

  const DocumentDistributorsDeptSection({
    super.key,
    required this.distributors,
  });

  @override
  State<DocumentDistributorsDeptSection> createState() =>
      _DocumentDistributorsDeptSectionState();
}

class _DocumentDistributorsDeptSectionState
    extends State<DocumentDistributorsDeptSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Các đơn vị liên quan (${widget.distributors.length})',
          icon: Icons.business,
          trailing: IconButton(
            icon: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xFF006884),
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
        ),
        const SizedBox(height: 6),
        if (_isExpanded)
          widget.distributors.isEmpty
              ? EmptyStatePresets.listEmpty(title: 'Chưa có đơn vị liên quan')
              : Column(
                  children: widget.distributors.map((distributor) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFE8E8E8),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  distributor.departmentCode,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        const SizedBox(height: 12),
      ],
    );
  }
}
