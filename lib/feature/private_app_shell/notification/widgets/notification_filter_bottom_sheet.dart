import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/notification_filter_model.dart';
import 'package:tcs_e_office/common/constants/app_tab_types.dart';

class NotificationFilterOption {
  final String value;
  final String label;

  NotificationFilterOption({
    required this.value,
    required this.label,
  });
}

class NotificationFilterBottomSheet extends StatefulWidget {
  final NotificationFilterModel currentFilter;
  final Function(NotificationFilterModel) onApplyFilter;
  final Function() onResetFilter;

  const NotificationFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onApplyFilter,
    required this.onResetFilter,
  });

  @override
  State<NotificationFilterBottomSheet> createState() =>
      _NotificationFilterBottomSheetState();
}

class _NotificationFilterBottomSheetState
    extends State<NotificationFilterBottomSheet> {
  late NotificationFilterModel _tempFilter;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _tempFilter = NotificationFilterModel.fromFilterModel(
      widget.currentFilter,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Lấy danh sách loại thông báo từ local
  List<NotificationFilterOption> _getNotificationTypeOptions() {
    return [
      NotificationFilterOption(
        value: AppTabTypes.DOCUMENT_IN,
        label: AppTabTypes.documentIncomingLabel,
      ),
      NotificationFilterOption(
        value: AppTabTypes.DOCUMENT_OUT,
        label: AppTabTypes.documentOutgoingLabel,
      ),
      NotificationFilterOption(
        value: AppTabTypes.TASK_ASSIGN,
        label: AppTabTypes.taskAssignedByMeLabel,
      ),
      NotificationFilterOption(
        value: AppTabTypes.TASK_RECEIVED,
        label: AppTabTypes.taskAssignedToMeLabel,
      ),
    ];
  }

  // Lấy danh sách trạng thái đọc từ local
  List<NotificationFilterOption> _getReadStatusOptions() {
    return [
      NotificationFilterOption(value: 'true', label: 'Đã đọc'),
      NotificationFilterOption(value: 'false', label: 'Chưa đọc'),
    ];
  }

  // Hiển thị picker cho loại thông báo
  void _showNotificationTypePicker() {
    final options = _getNotificationTypeOptions();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Chọn loại thông báo',
        options: options,
        currentValue: _tempFilter.notificationType,
        onSelected: (value) {
          if (mounted && !_isDisposed) {
            setState(() {
              _tempFilter = _tempFilter.copyWith(notificationType: value);
            });
          }
        },
      ),
    );
  }

  // Hiển thị picker cho trạng thái đọc
  void _showReadStatusPicker() {
    final options = _getReadStatusOptions();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Chọn trạng thái',
        options: options,
        currentValue: _tempFilter.readStatus == null
            ? null
            : (_tempFilter.readStatus! ? 'true' : 'false'),
        onSelected: (value) {
          if (mounted && !_isDisposed) {
            setState(() {
              if (value == null) {
                _tempFilter = _tempFilter.copyWith(readStatus: null);
              } else {
                _tempFilter = _tempFilter.copyWith(
                  readStatus: value == 'true',
                );
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildPickerSheet({
    required String title,
    required List<NotificationFilterOption> options,
    required String? currentValue,
    required Function(String?) onSelected,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF757575),
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),

          // Danh sách options
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length + 1, // +1 for "Tất cả" option
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // "Tất cả" option
                    final isSelected = currentValue == null;
                    return ListTile(
                      title: Text(
                        'Tất cả',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? const Color(0xFFF8A401)
                              : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Color(0xFFF8A401),
                              size: 20,
                            )
                          : null,
                      selected: isSelected,
                      selectedTileColor: const Color(0xFFF8A401)
                          .withOpacity(0.1),
                      onTap: () {
                        onSelected(null);
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        });
                      },
                    );
                  }

                  final option = options[index - 1];
                  final isSelected = currentValue == option.value;
                  return ListTile(
                    title: Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? const Color(0xFFF8A401)
                            : Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Color(0xFFF8A401),
                            size: 20,
                          )
                        : null,
                    selected: isSelected,
                    selectedTileColor: const Color(0xFFF8A401).withOpacity(0.1),
                    onTap: () {
                      onSelected(option.value);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget field filter
  Widget _buildFilterField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF424242),
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF212121),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF757575),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Lấy giá trị hiển thị cho loại thông báo
  String _getNotificationTypeDisplayValue() {
    if (_tempFilter.notificationType == null) return 'Tất cả';
    return _tempFilter.getNotificationTypeName();
  }

  // Lấy giá trị hiển thị cho trạng thái đọc
  String _getReadStatusDisplayValue() {
    return _tempFilter.getReadStatusName();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header với tiêu đề và nút đóng
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Bộ lọc',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF757575),
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),

          // Nội dung filter
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trường 1: Loại thông báo
                _buildFilterField(
                  label: 'Loại',
                  value: _getNotificationTypeDisplayValue(),
                  onTap: _showNotificationTypePicker,
                ),

                SizedBox(height: 12.h),

                // Trường 2: Trạng thái đọc
                _buildFilterField(
                  label: 'Trạng thái',
                  value: _getReadStatusDisplayValue(),
                  onTap: _showReadStatusPicker,
                ),

                SizedBox(height: 24.h),

                // Nút hành động
                Row(
                  children: [
                    // Nút Thiết lập lại
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          widget.onResetFilter();
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: const BorderSide(
                            color: Color(0xFFE0E0E0),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Thiết lập lại',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Nút Áp dụng
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApplyFilter(_tempFilter);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF8A401),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Áp dụng',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

