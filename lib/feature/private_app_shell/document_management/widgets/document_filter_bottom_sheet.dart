import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/document_filter_model.dart';
import '../services/document_filter_options_service.dart';
import '../models/document_filter_option_model.dart';

class DocumentFilterBottomSheet extends StatefulWidget {
  final DocumentFilterModel currentFilter;
  final Function(DocumentFilterModel) onApplyFilter;
  final Function() onResetFilter;
  final int currentTab; // 0: Văn bản đến, 1: Văn bản đi

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
  late DocumentFilterModel _tempFilter;

  final DocumentFilterOptionsService _filterOptionsService =
      DocumentFilterOptionsService();

  static List<DocumentFilterOption>? _cachedStatusOptions;
  static bool _isStatusOptionsLoaded = false;

  List<DocumentFilterOption> _statusOptions = [];
  List<DocumentFilterOption> _documentTypeOptions = [];
  bool _isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _tempFilter = DocumentFilterModel.fromFilterModel(widget.currentFilter);

    // Khởi tạo document type options từ local (không cần API)
    _documentTypeOptions = _getLocalDocumentTypeOptions();

    // Load status options từ API
    if (_isStatusOptionsLoaded && _cachedStatusOptions != null) {
      _isLoading = false;
      _statusOptions = _cachedStatusOptions!;
    } else {
      _loadStatusOptions();
    }
  }

  // Lấy danh sách loại văn bản từ local (không cần API)
  List<DocumentFilterOption> _getLocalDocumentTypeOptions() {
    return [
      DocumentFilterOption(value: '1', label: 'Tài liệu bên ngoài'),
      DocumentFilterOption(value: '2', label: 'Tài liệu nội bộ'),
      DocumentFilterOption(
        value: '3',
        label: 'Phiếu triển khai tài liệu phục vụ hàng hoá',
      ),
    ];
  }

  // Load status options từ API
  Future<void> _loadStatusOptions() async {
    if (_isDisposed) return;

    try {
      setState(() {
        _isLoading = true;
      });

      _statusOptions = await _filterOptionsService.getStatusOptions();

      if (_isDisposed) return;

      _cachedStatusOptions = _statusOptions;
      _isStatusOptionsLoaded = true;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (_isDisposed) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Hiển thị picker cho trạng thái
  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Chọn trạng thái',
        options: _statusOptions,
        currentValue: _tempFilter.status,
        onSelected: (value) {
          if (mounted && !_isDisposed) {
            setState(() {
              if (value == null) {
                // Tạo filter mới với status = null, giữ nguyên các field khác
                _tempFilter = DocumentFilterModel(
                  status: null,
                  documentType: _tempFilter.documentType,
                  isRead: _tempFilter.isRead,
                  fromDate: _tempFilter.fromDate,
                  toDate: _tempFilter.toDate,
                );
              } else {
                // Sử dụng copyWith để update status
                _tempFilter = _tempFilter.copyWith(status: value);
              }
            });
          }
        },
      ),
    );
  }

  // Hiển thị picker cho loại văn bản
  void _showDocumentTypePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Chọn loại văn bản',
        options: _documentTypeOptions,
        currentValue: _tempFilter.documentType,
        onSelected: (value) {
          if (mounted && !_isDisposed) {
            setState(() {
              if (value == null) {
                // Tạo filter mới với documentType = null, giữ nguyên các field khác
                _tempFilter = DocumentFilterModel(
                  status: _tempFilter.status,
                  documentType: null,
                  isRead: _tempFilter.isRead,
                  fromDate: _tempFilter.fromDate,
                  toDate: _tempFilter.toDate,
                );
              } else {
                // Sử dụng copyWith để update documentType
                _tempFilter = _tempFilter.copyWith(documentType: value);
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildPickerSheet({
    required String title,
    required List<DocumentFilterOption> options,
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
                      selectedTileColor: const Color(
                        0xFFF8A401,
                      ).withOpacity(0.1),
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
                  // Translate label nếu là status picker hoặc document type picker
                  final displayLabel = title == 'Chọn trạng thái'
                      ? _translateStatusLabel(option.label)
                      : title == 'Chọn loại văn bản'
                      ? _translateDocumentTypeLabel(option.label)
                      : option.label;
                  return ListTile(
                    title: Text(
                      displayLabel,
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

  // Map label từ tiếng Anh sang tiếng Việt cho status
  String _translateStatusLabel(String label) {
    const Map<String, String> statusTranslations = {
      'Draft': 'Dự thảo',
      'Submitted': 'Chờ duyệt',
      'Approved': 'Đã duyệt',
      'Published': 'Ban hành',
      'Rejected': 'Từ chối',
    };
    return statusTranslations[label] ?? label;
  }

  // Map label cho loại văn bản (categoryName)
  String _translateDocumentTypeLabel(String label) {
    final labelLower = label.toLowerCase().trim();

    // Xử lý các categoryName phổ biến
    if (labelLower.contains('tài liệu bên ngoài') ||
        labelLower.contains('tai lieu ben ngoai') ||
        labelLower.contains('bên ngoài') ||
        labelLower.contains('ben ngoai')) {
      return 'Bên ngoài';
    } else if (labelLower.contains('tài liệu nội bộ') ||
        labelLower.contains('tai lieu noi bo') ||
        labelLower.contains('nội bộ') ||
        labelLower.contains('noi bo')) {
      return 'Nội bộ';
    } else if (labelLower.contains(
          'phiếu triển khai tài liệu phục vụ hàng hoá',
        ) ||
        labelLower.contains('phieu trien khai tai lieu phuc vu hang hoa')) {
      return 'Phiếu triển khai tài liệu phục vụ hàng hoá';
    }

    // Fallback to original value
    return label;
  }

  // Lấy giá trị hiển thị cho trạng thái
  String _getStatusDisplayValue() {
    if (_tempFilter.status == null) return 'Tất cả';
    final option = _statusOptions.firstWhere(
      (opt) => opt.value == _tempFilter.status,
      orElse: () => DocumentFilterOption(value: '', label: 'Không xác định'),
    );
    return _translateStatusLabel(option.label);
  }

  // Lấy giá trị hiển thị cho loại văn bản
  String _getDocumentTypeDisplayValue() {
    if (_tempFilter.documentType == null) return 'Tất cả';
    final option = _documentTypeOptions.firstWhere(
      (opt) => opt.value == _tempFilter.documentType,
      orElse: () => DocumentFilterOption(value: '', label: 'Không xác định'),
    );
    return _translateDocumentTypeLabel(option.label);
  }

  // Lấy giá trị hiển thị cho trạng thái đọc (cho văn bản đến)
  String _getReadStatusDisplayValue() {
    if (_tempFilter.isRead == null) return 'Tất cả';
    return _tempFilter.isRead! ? 'Đã đọc' : 'Chưa đọc';
  }

  // Hiển thị picker cho trạng thái đọc (cho văn bản đến)
  void _showReadStatusPicker() {
    final readStatusOptions = [
      DocumentFilterOption(value: 'true', label: 'Đã đọc'),
      DocumentFilterOption(value: 'false', label: 'Chưa đọc'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Chọn trạng thái đọc',
        options: readStatusOptions,
        currentValue: _tempFilter.isRead == null
            ? null
            : (_tempFilter.isRead! ? 'true' : 'false'),
        onSelected: (value) {
          if (mounted && !_isDisposed) {
            setState(() {
              if (value == null) {
                _tempFilter = DocumentFilterModel(
                  status: _tempFilter.status,
                  documentType: _tempFilter.documentType,
                  isRead: null,
                  fromDate: _tempFilter.fromDate,
                  toDate: _tempFilter.toDate,
                );
              } else {
                _tempFilter = _tempFilter.copyWith(isRead: value == 'true');
              }
            });
          }
        },
      ),
    );
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
                      // Trường 1: Trạng thái (khác nhau cho incoming và outgoing)
                      if (widget.currentTab == 0)
                        // Văn bản đến: Hiển thị trạng thái đọc
                        _buildFilterField(
                          label: 'Trạng thái đọc',
                          value: _getReadStatusDisplayValue(),
                          onTap: _showReadStatusPicker,
                        )
                      else
                        // Văn bản đi: Hiển thị trạng thái văn bản
                        _buildFilterField(
                          label: 'Trạng thái văn bản',
                          value: _getStatusDisplayValue(),
                          onTap: _showStatusPicker,
                        ),

                      SizedBox(height: 12.h),

                      // Trường 2: Loại văn bản
                      _buildFilterField(
                        label: 'Loại văn bản',
                        value: _getDocumentTypeDisplayValue(),
                        onTap: _showDocumentTypePicker,
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
                // Skeleton cho trường trạng thái (khác nhau cho incoming và outgoing)
                _buildSkeletonField(
                  widget.currentTab == 0
                      ? 'Trạng thái đọc'
                      : 'Trạng thái văn bản',
                ),
                SizedBox(height: 12.h),

                // Skeleton cho trường loại văn bản
                _buildSkeletonField('Loại văn bản'),

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
        // Skeleton cho label
        Container(
          height: 14.h,
          width: 120.w,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: 8.h),
        // Skeleton cho field
        Container(
          height: 48.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
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
