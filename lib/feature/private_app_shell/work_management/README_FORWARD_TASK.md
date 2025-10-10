# Hướng dẫn sử dụng Forward Task API

## Tổng quan

Chức năng Forward Task cho phép chuyển tiếp công việc cho người khác với title "Chọn người chuyển giao".

## Cấu trúc API

### Endpoint
```
POST /api/documenttask/forward-task
```

### Request Body
```json
{
  "id": "e07fe725-c675-499c-96b7-7db9043d7c35",
  "dueDate": "2025-10-09",
  "primary": {
    "departmentCodes": [],
    "employeeCodes": ["0491", "1026", "9997", "9998", "9999", "1273", "1235", "webmaster", "9996"]
  },
  "collab": {
    "departmentCodes": [],
    "employeeCodes": []
  },
  "follow": {
    "departmentCodes": [],
    "employeeCodes": []
  }
}
```

## Cách sử dụng

### 1. Sử dụng TaskDetailController

```dart
// Trong view hoặc widget
final controller = Get.find<TaskDetailController>();

// Gọi forward task
final success = await controller.forwardTask(
  selectedEmployeeCodes: ['0491', '1026', '9997'],
  dueDate: '2025-10-09',
);

if (success) {
  // Xử lý thành công
  print('Forward task thành công');
} else {
  // Xử lý lỗi
  print('Forward task thất bại: ${controller.error.value}');
}
```

### 2. Sử dụng AssigneeSelectorBottomSheet

```dart
// Hiển thị bottom sheet để chọn người chuyển giao
showAssigneeSelectorBottomSheet(
  context,
  controller: yourController, // Controller có departmentTree
  title: 'Chọn người chuyển giao', // Title cho forward task
  onConfirm: (selectedEmployeeCodes) async {
    if (selectedEmployeeCodes.isEmpty) {
      // Hiển thị thông báo lỗi
      return;
    }

    // Gọi API forward task
    final success = await controller.forwardTask(
      selectedEmployeeCodes: selectedEmployeeCodes,
      dueDate: dueDate,
    );

    // Xử lý kết quả
  },
);
```

### 3. Sử dụng trực tiếp TaskApiService

```dart
final taskApiService = TaskApiService();

// Tạo request
final request = ForwardTaskRequest(
  id: taskId,
  dueDate: '2025-10-09',
  primary: AssigneeGroup(
    departmentCodes: [],
    employeeCodes: ['0491', '1026', '9997'],
  ),
  collab: AssigneeGroup(
    departmentCodes: [],
    employeeCodes: [],
  ),
  follow: AssigneeGroup(
    departmentCodes: [],
    employeeCodes: [],
  ),
);

// Gọi API
final success = await taskApiService.forwardTask(request);
```

### 4. Sử dụng helper method

```dart
final taskApiService = TaskApiService();

// Sử dụng helper method đơn giản hơn
final success = await taskApiService.forwardTaskWithEmployees(
  taskId: 'e07fe725-c675-499c-96b7-7db9043d7c35',
  dueDate: '2025-10-09',
  selectedEmployeeCodes: ['0491', '1026', '9997'],
);
```

## Models

### ForwardTaskRequest
```dart
class ForwardTaskRequest {
  final String id;           // Task ID
  final String dueDate;      // Ngày hết hạn (format: YYYY-MM-DD)
  final AssigneeGroup primary;   // Nhóm thực hiện chính
  final AssigneeGroup collab;    // Nhóm cộng tác
  final AssigneeGroup follow;    // Nhóm theo dõi
}
```

### AssigneeGroup
```dart
class AssigneeGroup {
  final List<String> departmentCodes;  // Danh sách mã phòng ban
  final List<String> employeeCodes;    // Danh sách mã nhân viên
}
```

## Error Handling

API sử dụng `ApiResponseHandler` để xử lý response một cách thống nhất:

- **HTTP 200**: API thành công
- **HTTP 400**: Dữ liệu không hợp lệ
- **HTTP 404**: Không tìm thấy task
- **HTTP 500**: Lỗi server

## Trạng thái Loading

Controller cung cấp các trạng thái loading:

```dart
// Kiểm tra trạng thái forwarding
Obx(() {
  if (controller.isForwarding.value) {
    return const CircularProgressIndicator();
  }
  return const SizedBox.shrink();
});

// Hiển thị lỗi
Obx(() {
  if (controller.error.value.isNotEmpty) {
    return Text(controller.error.value);
  }
  return const SizedBox.shrink();
});
```

## Lưu ý

1. **Due Date Format**: Sử dụng format `YYYY-MM-DD` cho dueDate
2. **Employee Codes**: Đảm bảo employee codes hợp lệ
3. **Error Handling**: Luôn kiểm tra kết quả và hiển thị lỗi cho user
4. **Loading State**: Sử dụng loading state để cải thiện UX
5. **Validation**: Kiểm tra selectedEmployeeCodes không rỗng trước khi gọi API

## Example Files

Xem file `examples/forward_task_example.dart` để có ví dụ chi tiết về cách implement.
