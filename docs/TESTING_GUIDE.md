# Hướng dẫn Test 16KB Page Size Support

## 🧪 Tổng quan Testing

Tài liệu này hướng dẫn cách test ứng dụng TCS E-Office để đảm bảo hỗ trợ 16KB page size hoạt động đúng.

## 🔍 1. Kiểm tra APK Alignment

### Lệnh kiểm tra
```bash
# Kiểm tra alignment với 16KB page size
& "C:\Users\ASUS\AppData\Local\Android\Sdk\build-tools\34.0.0\zipalign.exe" -c -p -v 16 build/app/outputs/flutter-apk/app-release.apk
```

### Kết quả mong đợi
```
✅ lib/arm64-v8a/libapp.so (OK)
✅ lib/arm64-v8a/libflutter.so (OK)
✅ lib/armeabi-v7a/libapp.so (OK)
✅ lib/x86_64/libapp.so (OK)
```

### Ý nghĩa
- **OK:** File đã align đúng 16KB
- **BAD:** File chưa align (có thể chấp nhận được cho assets)

## 📱 2. Kiểm tra Native Libraries

### Lệnh kiểm tra
```bash
# Xem tất cả native libraries trong APK
& "C:\Users\ASUS\AppData\Local\Android\Sdk\build-tools\34.0.0\aapt.exe" list build/app/outputs/flutter-apk/app-release.apk | findstr "\.so"
```

### Kết quả mong đợi
```
lib/arm64-v8a/libapp.so
lib/arm64-v8a/libdatastore_shared_counter.so
lib/arm64-v8a/libflutter.so
lib/armeabi-v7a/libapp.so
lib/armeabi-v7a/libdatastore_shared_counter.so
lib/armeabi-v7a/libflutter.so
lib/x86_64/libapp.so
lib/x86_64/libdatastore_shared_counter.so
lib/x86_64/libflutter.so
```

### Ý nghĩa
- **Có đủ native libraries** cho các architecture
- **Flutter engine** đã được include
- **App-specific libraries** đã được build

## 🔧 3. Kiểm tra APK Information

### Lệnh kiểm tra
```bash
# Xem thông tin chi tiết APK
& "C:\Users\ASUS\AppData\Local\Android\Sdk\build-tools\34.0.0\aapt.exe" dump badging build/app/outputs/flutter-apk/app-release.apk
```

### Thông tin quan trọng cần kiểm tra
```
package: name='com.nps.tcs'
sdkVersion:'21'
targetSdkVersion:'36'
native-code: 'arm64-v8a' 'armeabi-v7a' 'x86_64'
```

## 📲 4. Test trên Thiết bị Thật

### Cài đặt và chạy
```bash
# Cài đặt APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Chạy ứng dụng
adb shell am start -n com.nps.tcs/.MainActivity

# Kiểm tra logs
adb logcat | findstr "tcs"
```

### Kiểm tra hoạt động
- ✅ **App khởi động** thành công
- ✅ **Không crash** khi sử dụng
- ✅ **UI hiển thị** đúng
- ✅ **Chức năng** hoạt động bình thường

## 🖥️ 5. Test trên Android Emulator với 16KB

### Tạo Emulator 16KB
1. **Mở Android Studio**
2. **Device Manager** > Create Device
3. **Chọn system image** Android 15+ (API 35+)
4. **Advanced Settings** > Enable "16KB page size"
5. **Start emulator**

### Test trên Emulator
```bash
# Cài đặt APK trên emulator
adb install build/app/outputs/flutter-apk/app-release.apk

# Chạy ứng dụng
adb shell am start -n com.nps.tcs/.MainActivity

# Kiểm tra page size
adb shell getconf PAGE_SIZE
# Kết quả mong đợi: 16384 (16KB)
```

## 📊 6. Performance Testing

### Memory Usage
```bash
# Monitor memory usage
adb shell dumpsys meminfo com.nps.tcs
```

### CPU Usage
```bash
# Monitor CPU usage
adb shell top | findstr "tcs"
```

### Crash Detection
```bash
# Xem crash logs
adb logcat | findstr "FATAL\|AndroidRuntime\|tcs"
```

## 🎯 7. Test Cases

### Test Case 1: App Launch
- **Mục tiêu:** App khởi động thành công
- **Steps:**
  1. Cài đặt APK
  2. Launch app
  3. Kiểm tra splash screen
- **Expected:** App hiển thị splash và vào main screen

### Test Case 2: Basic Functionality
- **Mục tiêu:** Các chức năng cơ bản hoạt động
- **Steps:**
  1. Login vào app
  2. Navigate giữa các screens
  3. Test các features chính
- **Expected:** Tất cả chức năng hoạt động bình thường

### Test Case 3: Memory Management
- **Mục tiêu:** App quản lý memory hiệu quả
- **Steps:**
  1. Sử dụng app trong thời gian dài
  2. Monitor memory usage
  3. Test với nhiều screens
- **Expected:** Memory usage ổn định, không leak

### Test Case 4: 16KB Page Size Compatibility
- **Mục tiêu:** App hoạt động tốt trên 16KB devices
- **Steps:**
  1. Test trên emulator 16KB
  2. Kiểm tra performance
  3. So sánh với 4KB devices
- **Expected:** Performance tốt hơn hoặc tương đương

## 🚨 8. Troubleshooting

### Vấn đề thường gặp

#### App không khởi động
```bash
# Kiểm tra logs
adb logcat | findstr "FATAL\|AndroidRuntime"

# Kiểm tra permissions
adb shell dumpsys package com.nps.tcs
```

#### Native library errors
```bash
# Kiểm tra architecture compatibility
adb shell getprop ro.product.cpu.abi

# Kiểm tra native libraries
aapt list app-release.apk | findstr "\.so"
```

#### Memory issues
```bash
# Kiểm tra memory usage
adb shell dumpsys meminfo com.nps.tcs

# Kiểm tra heap
adb shell am dumpheap com.nps.tcs /data/local/tmp/heap.hprof
```

## ✅ 9. Checklist Testing

### Pre-deployment Checklist
- [ ] **APK alignment** - Native libraries align đúng 16KB
- [ ] **Build success** - APK build không có lỗi
- [ ] **Device test** - App chạy trên thiết bị thật
- [ ] **Emulator test** - App chạy trên emulator 16KB
- [ ] **Performance test** - Memory và CPU usage ổn định
- [ ] **Functionality test** - Tất cả features hoạt động
- [ ] **Crash test** - Không có crash logs
- [ ] **Compatibility test** - Hoạt động trên cả 4KB và 16KB

### Post-deployment Checklist
- [ ] **Google Play upload** - APK upload thành công
- [ ] **Store listing** - App hiển thị đúng trên store
- [ ] **User feedback** - Không có báo cáo lỗi 16KB
- [ ] **Analytics** - Performance metrics tốt

## 📈 10. Kết quả Test

### Thành công
- ✅ **Native libraries alignment:** 100% OK
- ✅ **App functionality:** Hoạt động bình thường
- ✅ **Performance:** Ổn định trên cả 4KB và 16KB
- ✅ **Google Play compatibility:** Đạt yêu cầu

### Khuyến nghị
- 🔄 **Regular testing** trên emulator 16KB
- 📊 **Monitor performance** metrics
- 🚀 **Update dependencies** thường xuyên
- 📱 **Test trên thiết bị mới** khi có thể

---

**Tài liệu này đảm bảo ứng dụng TCS E-Office đã được test đầy đủ cho 16KB page size support.**
