import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/filter_model.dart';
import '../services/filter_options_service.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterModel currentFilter;
  final Function(FilterModel) onApplyFilter;
  final Function() onResetFilter;
  final int currentTab; // 0: Việc tôi giao, 1: Việc giao đến tôi

  const FilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onApplyFilter,
    required this.onResetFilter,
    required this.currentTab,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late FilterModel _tempFilter;

  final FilterOptionsService _filterOptionsService = FilterOptionsService();

  // Cache options để không tải lại mỗi lần
  static List<FilterOption>? _cachedStatusOptions;
  static List<FilterOption>? _cachedPriorityOptions;
  static List<FilterOption>? _cachedRoleOptions;
  static bool _isOptionsLoaded = false;

  List<FilterOption> _statusOptions = [];
  List<FilterOption> _priorityOptions = [];
  List<FilterOption> _roleOptions = [];
  bool _isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _tempFilter = FilterModel.fromFilterModel(widget.currentFilter);

    // Nếu đã có cache, không cần loading
    if (_isOptionsLoaded &&
        _cachedStatusOptions != null &&
        _cachedPriorityOptions != null &&
        (widget.currentTab == 0 || _cachedRoleOptions != null)) {
      _isLoading = false;
      _statusOptions = _cachedStatusOptions!;
      _priorityOptions = _cachedPriorityOptions!;
      if (widget.currentTab == 1) {
        _roleOptions = _cachedRoleOptions!;
      }
    } else {
      _loadFilterOptions();
    }
  }

  Future<void> _loadFilterOptions() async {
    // Nếu đã có cache, sử dụng ngay
    if (_isOptionsLoaded &&
        _cachedStatusOptions != null &&
        _cachedPriorityOptions != null &&
        (widget.currentTab == 0 || _cachedRoleOptions != null)) {
      if (mounted && !_isDisposed) {
        setState(() {
          _statusOptions = _cachedStatusOptions!;
          _priorityOptions = _cachedPriorityOptions!;
          if (widget.currentTab == 1) {
            _roleOptions = _cachedRoleOptions!;
          }
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final statusOptions = await _filterOptionsService.getStatusOptions();
      final priorityOptions = await _filterOptionsService.getPriorityOptions();

      // Chỉ load role options nếu đang ở tab 1 (Việc giao đến tôi)
      List<FilterOption>? roleOptions;
      if (widget.currentTab == 1) {
        roleOptions = await _filterOptionsService.getRoleOptions();
      }

      // Cache options
      _cachedStatusOptions = [
        FilterOption(value: 0, label: 'Tất cả'),
        ...statusOptions,
      ];
      _cachedPriorityOptions = [
        FilterOption(value: 0, label: 'Tất cả'),
        ...priorityOptions,
      ];

      if (widget.currentTab == 1 && roleOptions != null) {
        _cachedRoleOptions = [
          FilterOption(value: 0, label: 'Tất cả'),
          ...roleOptions,
        ];
      }

      _isOptionsLoaded = true;

      if (mounted && !_isDisposed) {
        setState(() {
          _statusOptions = _cachedStatusOptions!;
          _priorityOptions = _cachedPriorityOptions!;
          if (widget.currentTab == 1) {
            _roleOptions = _cachedRoleOptions!;
          }
          _isLoading = false;
        });
        // Debug log để kiểm tra options
        print(
          'Status options loaded: ${_statusOptions.map((e) => '${e.label}:${e.value}').join(', ')}',
        );
        print(
          'Priority options loaded: ${_priorityOptions.map((e) => '${e.label}:${e.value}').join(', ')}',
        );
      }
    } catch (e) {
      // Fallback về options mặc định nếu có lỗi
      _cachedStatusOptions = [
        FilterOption(value: 0, label: 'Tất cả'),
        FilterOption(value: 1, label: 'Đang thực hiện'),
        FilterOption(value: 2, label: 'Hoàn thành'),
        FilterOption(value: 3, label: 'Quá hạn'),
      ];
      _cachedPriorityOptions = [
        FilterOption(value: 0, label: 'Tất cả'),
        FilterOption(value: 1, label: 'Khẩn cấp'),
        FilterOption(value: 2, label: 'Ưu tiên cao'),
        FilterOption(value: 3, label: 'Trung bình'),
        FilterOption(value: 4, label: 'Bình thường'),
        FilterOption(value: 5, label: 'Thấp'),
      ];

      if (widget.currentTab == 1) {
        _cachedRoleOptions = [
          FilterOption(value: 0, label: 'Tất cả'),
          FilterOption(value: 1, label: 'Xử lý chính'),
          FilterOption(value: 2, label: 'Phối hợp'),
          FilterOption(value: 3, label: 'Theo dõi'),
        ];
      }

      _isOptionsLoaded = true;

      if (mounted && !_isDisposed) {
        setState(() {
          _statusOptions = _cachedStatusOptions!;
          _priorityOptions = _cachedPriorityOptions!;
          if (widget.currentTab == 1) {
            _roleOptions = _cachedRoleOptions!;
          }
          _isLoading = false;
        });
        // Debug log cho fallback options
        print(
          'Fallback Status options loaded: ${_statusOptions.map((e) => '${e.label}:${e.value}').join(', ')}',
        );
        print(
          'Fallback Priority options loaded: ${_priorityOptions.map((e) => '${e.label}:${e.value}').join(', ')}',
        );
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
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
      child: _isLoading
          ? _buildLoadingState()
          : Column(
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
                      // Trường 1: Trạng thái công việc
                      _buildFilterField(
                        label: 'Trạng thái công việc',
                        value: _getStatusDisplayValue(),
                        onTap: () => _showStatusPicker(),
                      ),

                      SizedBox(height: 12.h),

                      // Trường 2: Mức độ ưu tiên
                      _buildFilterField(
                        label: 'Mức độ ưu tiên',
                        value: _getPriorityDisplayValue(),
                        onTap: () => _showPriorityPicker(),
                      ),

                      // Trường 3: Vai trò (chỉ hiển thị ở tab "Việc giao đến tôi")
                      if (widget.currentTab == 1) ...[
                        SizedBox(height: 12.h),
                        _buildFilterField(
                          label: 'Vai trò',
                          value: _getRoleDisplayValue(),
                          onTap: () => _showRolePicker(),
                        ),
                      ],

                      SizedBox(height: 24.h),

                      // Nút hành động
                      Row(
                        children: [
                          // Nút Thiết lập lại
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _resetFilter,
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
                              onPressed: _applyFilter,
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

  void _showStatusPicker() {
    final currentValue = _tempFilter.status ?? 0;
    print(
      'Opening status picker, current status: ${_tempFilter.status}, using: $currentValue',
    );
    print(
      'Available options: ${_statusOptions.map((e) => '${e.label}:${e.value}').join(', ')}',
    );
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Chọn trạng thái',
        options: _statusOptions,
        currentValue: currentValue,
        onSelected: (value) {
          if (mounted && !_isDisposed) {
            setState(() {
              if (value == 0) {
                // Chọn "Tất cả" - tạo filter mới với status = null
                _tempFilter = FilterModel(
                  status: null,
                  priority: _tempFilter.priority,
                  role: _tempFilter.role,
                  dueDate: _tempFilter.dueDate,
                );
              } else {
                // Chọn giá trị cụ thể - dùng copyWith
                _tempFilter = _tempFilter.copyWith(status: value);
              }
            });
          }
        },
      ),
    );
  }

  void _showPriorityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Chọn mức độ ưu tiên',
        options: _priorityOptions,
        currentValue: _tempFilter.priority ?? 0,
        onSelected: (value) {
          if (mounted && !_isDisposed) {
            setState(() {
              if (value == 0) {
                // Chọn "Tất cả" - tạo filter mới với priority = null
                _tempFilter = FilterModel(
                  status: _tempFilter.status,
                  priority: null,
                  role: _tempFilter.role,
                  dueDate: _tempFilter.dueDate,
                );
              } else {
                // Chọn giá trị cụ thể - dùng copyWith
                _tempFilter = _tempFilter.copyWith(priority: value);
              }
            });
          }
        },
      ),
    );
  }

  void _showRolePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Chọn vai trò',
        options: _roleOptions,
        currentValue: _tempFilter.role ?? 0,
        onSelected: (value) {
          if (mounted && !_isDisposed) {
            setState(() {
              if (value == 0) {
                // Chọn "Tất cả" - tạo filter mới với role = null
                _tempFilter = FilterModel(
                  status: _tempFilter.status,
                  priority: _tempFilter.priority,
                  role: null,
                  dueDate: _tempFilter.dueDate,
                );
              } else {
                // Chọn giá trị cụ thể - dùng copyWith
                _tempFilter = _tempFilter.copyWith(role: value);
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildPickerSheet({
    required String title,
    required List<FilterOption> options,
    required int? currentValue,
    required Function(int?) onSelected,
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

          // Danh sách options - FIX: Sử dụng Flexible để tránh overflow
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height *
                    0.4, // Giảm từ 0.5 xuống 0.4
              ),
              child: ListView.builder(
                shrinkWrap: true, // Thêm lại shrinkWrap để tránh overflow
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  // Sửa logic so sánh để xử lý value = 0 cho "Tất cả"
                  final isSelected = option.value == (currentValue ?? 0);

                  // Debug log để kiểm tra logic so sánh
                  if (option.label == "Tất cả") {
                    print(
                      'DEBUG "Tất cả": option.value=${option.value} (${option.value.runtimeType}), currentValue=$currentValue (${currentValue.runtimeType}), isSelected=$isSelected',
                    );
                  }

                  // Debug log để kiểm tra logic
                  print(
                    'Building option: ${option.label}, value: ${option.value}, currentValue: $currentValue, isSelected: $isSelected',
                  );

                  return ListTile(
                    title: Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
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
                      // Debug log để kiểm tra
                      print(
                        'Tapped option: ${option.label}, value: ${option.value}',
                      );
                      print('Option type: ${option.value.runtimeType}');
                      print('Current value type: ${currentValue.runtimeType}');
                      print('Is "Tất cả" option: ${option.label == "Tất cả"}');

                      // Test case đặc biệt cho "Tất cả"
                      if (option.label == "Tất cả") {
                        print('SPECIAL DEBUG: Clicking "Tất cả" option');
                        print(
                          'Before onSelected: option.value = ${option.value}',
                        );
                      }

                      onSelected(option.value);

                      // Test case đặc biệt cho "Tất cả"
                      if (option.label == "Tất cả") {
                        print('SPECIAL DEBUG: After onSelected called');
                      }

                      // Delay việc đóng bottom sheet để đảm bảo setState được thực hiện
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

  void _resetFilter() {
    if (mounted && !_isDisposed) {
      setState(() {
        _tempFilter = FilterModel.empty();
      });
    }
    widget.onResetFilter();
    Navigator.of(context).pop();
  }

  void _applyFilter() {
    widget.onApplyFilter(_tempFilter);
    Navigator.of(context).pop();
  }

  String _getStatusDisplayValue() {
    print(
      '_getStatusDisplayValue called, _tempFilter.status: ${_tempFilter.status}',
    );
    if (_tempFilter.status == null) {
      print('Status is null, returning: Tất cả');
      return 'Tất cả';
    }
    try {
      final result = _statusOptions
          .firstWhere((option) => option.value == _tempFilter.status)
          .label;
      print('Found status option: $result');
      return result;
    } catch (e) {
      print('Error finding status option: $e, returning: Tất cả');
      return 'Tất cả';
    }
  }

  String _getPriorityDisplayValue() {
    if (_tempFilter.priority == null) {
      return 'Tất cả';
    }
    try {
      return _priorityOptions
          .firstWhere((option) => option.value == _tempFilter.priority)
          .label;
    } catch (e) {
      return 'Tất cả';
    }
  }

  String _getRoleDisplayValue() {
    if (_tempFilter.role == null) {
      return 'Tất cả';
    }
    try {
      return _roleOptions
          .firstWhere((option) => option.value == _tempFilter.role)
          .label;
    } catch (e) {
      return 'Tất cả';
    }
  }

  Widget _buildLoadingState() {
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

          // Loading content với skeleton
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Skeleton cho trường trạng thái
                _buildSkeletonField('Trạng thái công việc'),
                SizedBox(height: 12.h),

                // Skeleton cho trường mức độ
                _buildSkeletonField('Mức độ ưu tiên'),

                // Skeleton cho trường vai trò (chỉ hiển thị ở tab "Việc giao đến tôi")
                if (widget.currentTab == 1) ...[
                  SizedBox(height: 12.h),
                  _buildSkeletonField('Vai trò'),
                ],

                SizedBox(height: 24.h),

                // Skeleton cho nút
                Row(
                  children: [
                    Expanded(child: _buildSkeletonButton()),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildSkeletonButton()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 120.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonButton() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
