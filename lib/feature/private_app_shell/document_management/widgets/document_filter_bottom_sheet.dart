import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../models/document_filter_model.dart';

class DocumentFilterBottomSheet extends StatefulWidget {
  final DocumentFilterModel currentFilter;
  final Function(DocumentFilterModel) onApplyFilter;
  final VoidCallback onResetFilter;
  final int currentTab;

  const DocumentFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onApplyFilter,
    required this.onResetFilter,
    required this.currentTab,
  });

  @override
  State<DocumentFilterBottomSheet> createState() =>
      _DocumentFilterBottomSheetState();
}

class _DocumentFilterBottomSheetState extends State<DocumentFilterBottomSheet> {
  late DocumentFilterModel _filter;

  final List<Map<String, dynamic>> statusOptions = [
    {'value': null, 'label': 'Tất cả trạng thái', 'color': Colors.grey},
    {'value': '1', 'label': 'Chờ duyệt', 'color': Colors.orange},
    {'value': '2', 'label': 'Đang xử lý', 'color': Colors.blue},
    {'value': '3', 'label': 'Hoàn thành', 'color': Colors.green},
    {'value': '4', 'label': 'Từ chối', 'color': Colors.red},
  ];

  final List<Map<String, dynamic>> documentTypeOptions = [
    {'value': null, 'label': 'Tất cả loại văn bản', 'color': Colors.grey},
    {'value': 'Hợp đồng', 'label': 'Hợp đồng', 'color': Colors.blue},
    {'value': 'Quyết định', 'label': 'Quyết định', 'color': Colors.green},
    {'value': 'Thông báo', 'label': 'Thông báo', 'color': Colors.orange},
    {'value': 'Báo cáo', 'label': 'Báo cáo', 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _filter = DocumentFilterModel(
      status: widget.currentFilter.status,
      documentType: widget.currentFilter.documentType,
      fromDate: widget.currentFilter.fromDate,
      toDate: widget.currentFilter.toDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bộ lọc văn bản',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: widget.onResetFilter,
                      child: Text(
                        'Đặt lại',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter options
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status filter
                  Text(
                    'Trạng thái',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...statusOptions.map(
                    (option) => _buildFilterOption(
                      option,
                      _filter.status,
                      (value) => setState(
                        () =>
                            _filter = DocumentFilterModel(
                              status: value,
                              documentType: _filter.documentType,
                              fromDate: _filter.fromDate,
                              toDate: _filter.toDate,
                            ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Document type filter
                  Text(
                    'Loại văn bản',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...documentTypeOptions.map(
                    (option) => _buildFilterOption(
                      option,
                      _filter.documentType,
                      (value) => setState(
                        () =>
                            _filter = DocumentFilterModel(
                              status: _filter.status,
                              documentType: value,
                              fromDate: _filter.fromDate,
                              toDate: _filter.toDate,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apply button
          Padding(
            padding: EdgeInsets.all(20.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilter(_filter);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Áp dụng bộ lọc',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    Map<String, dynamic> option,
    String? currentValue,
    Function(String?) onChanged,
  ) {
    final isSelected = currentValue == option['value'];

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: () => onChanged(option['value']),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: option['color'],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                option['label'],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check, color: AppColors.primary, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
