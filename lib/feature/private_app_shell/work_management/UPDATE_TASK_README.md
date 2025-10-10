# Update Task Feature

## Tổng quan
Màn hình cập nhật task được tạo dựa trên cấu trúc của màn hình tạo task, sử dụng cùng các widget section nhưng với controller riêng biệt.

## Cấu trúc files

### Controllers
- `update_task_controller.dart` - Controller chính cho update task
- Kế thừa logic từ `create_task_controller.dart`
- Thêm method `loadTaskData()` để load dữ liệu task hiện có
- Thêm method `_populateFormFromTaskData()` để populate form

### Views
- `update_task_view.dart` - Màn hình chính cho update task
- `update_task_example.dart` - Example usage

### Widgets
- `update_task_submit_button.dart` - Nút submit cho update
- `update_task_title_section.dart` - Section tên và nội dung
- `update_task_due_date_section.dart` - Section ngày tháng
- `update_task_priority_section.dart` - Section ưu tiên
- `update_task_attachment_section.dart` - Section đính kèm
- `update_task_assignee_section.dart` - Section phân công

## API Endpoints

### Update Task
```dart
static String updateTask(String taskId) =>
    "${Config.baseUrl}/documenttask/update-task/$taskId"; // POST
```

### Request Format
```
POST /api/documenttask/update-task/{taskId}
Content-Type: application/json

{
  "DocumentId": "string",
  "AssignerCode": "9999",
  "TaskName": "ssTsesst",
  "StartDate": "2025-10-06T17:00:00.000Z",
  "DueDate": "2025-10-09T16:59:59.000Z",
  "Priority": 0,
  "Note": "",
  "Content": "<p>aaaa</p>",
  "Primary": {
    "DepartmentCodes": ["CNTT"],
    "EmployeeCodes": []
  },
  "Collab": {
    "DepartmentCodes": ["CNTT-DCDS"],
    "EmployeeCodes": []
  },
  "Follow": {
    "DepartmentCodes": [],
    "EmployeeCodes": []
  }
}
```

### Response Format
```json
{
  "statusCode": 200,
  "message": "Successful.",
  "totalRecord": 0,
  "data": true
}
```

## Cách sử dụng

### 1. Navigate to Update Task Screen
```dart
Get.to(() => UpdateTaskView(
  assignerCode: '9999', // Mã người giao việc
  taskId: '1bf3c7b2-47a2-4656-9465-a8e8e4ea24b8', // ID task cần update
  documentId: 'optional-document-id', // Optional
));
```

### 2. Handle Success Callback
```dart
Get.to(() => UpdateTaskView(
  assignerCode: '9999',
  taskId: 'task-id',
  documentId: 'doc-id',
))?.then((result) {
  if (result == true) {
    // Task updated successfully
    // Refresh task list or navigate back
  }
});
```

## Tính năng chính

### 1. Load Task Data
- Tự động load dữ liệu task hiện có khi mở màn hình
- Populate form với dữ liệu từ API
- Hiển thị loading state trong quá trình load

### 2. Form Validation
- Validation tên công việc (bắt buộc)
- Validation nội dung công việc (bắt buộc)
- Sanitize HTML content để tránh lỗi database

### 3. Date Handling
- Chọn ngày bắt đầu và ngày hết hạn
- Tự động format theo timezone local
- Validation ngày hợp lệ

### 4. Priority Selection
- Load danh sách priority từ API
- Chọn mức độ ưu tiên
- Default priority nếu không chọn

### 5. Attachment Management
- Chọn file đính kèm
- Hiển thị danh sách file đã chọn
- Xóa file đính kèm
- Support multiple file types

### 6. Assignee Management
- Chọn người thực hiện chính
- Chọn người phối hợp
- Chọn người theo dõi
- Support cả employee và department

## Error Handling

### 1. Network Errors
- Hiển thị thông báo lỗi khi không thể kết nối API
- Retry mechanism cho failed requests

### 2. Validation Errors
- Hiển thị lỗi validation ngay trên form
- Highlight các field có lỗi
- Prevent submit khi có lỗi validation

### 3. Server Errors
- Parse error message từ server response
- Hiển thị thông báo lỗi user-friendly
- Log chi tiết lỗi cho debugging

## Dependencies

### Required Packages
- `get` - State management và navigation
- `dio` - HTTP client
- `file_picker` - File selection
- `flutter/material` - UI components

### Internal Dependencies
- `DioApi` - HTTP client wrapper
- `ApiEndpoints` - API endpoint definitions
- `TaskDetailModel` - Data models
- `AppDialog` - Dialog components

## Notes

### 1. Controller Lifecycle
- Controller được khởi tạo khi mở màn hình
- Tự động load metadata (priorities, employees, departments)
- Load task data sau khi metadata load xong

### 2. Form State Management
- Sử dụng reactive programming với GetX
- Auto-save form state
- Reset form khi cần thiết

### 3. Performance
- Lazy loading cho large datasets
- Debounce cho user input
- Optimize API calls

### 4. Security
- Sanitize HTML content
- Validate file types
- Secure API communication
