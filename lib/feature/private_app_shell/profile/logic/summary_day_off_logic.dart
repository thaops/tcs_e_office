import 'package:get/get.dart';
import 'package:tcs_e_office/feature/private_app_shell/profile/data/models/summary_day_off_model.dart';
import 'package:tcs_e_office/feature/private_app_shell/profile/data/services/summary_day_off_api_service.dart';

class SummaryDayOffLogic extends GetxController {
  // Dữ liệu summary
  final summaryData = Rx<SummaryDayOffModel?>(null);

  // Trạng thái loading
  final isLoading = false.obs;

  // API Service
  final SummaryDayOffApiService _apiService = SummaryDayOffApiService();

  // Năm hiện tại
  final currentYear = DateTime.now().year;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Load dữ liệu từ API
  Future<void> loadData() async {
    try {
      isLoading.value = true;

      final response = await _apiService.getMySummaryDayOff(year: currentYear);

      if (response.statusCode == 200 && response.data != null) {
        summaryData.value = response.data;
      } else {
        summaryData.value = null;
      }
    } catch (e) {
      summaryData.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh dữ liệu
  Future<void> refreshData() async {
    await loadData();
  }

  /// Lấy số ngày đã sử dụng
  num get usedDays {
    final data = summaryData.value;
    if (data == null || data.quota == null || data.leaveDaysLeft == null)
      return 0;
    return data.quota! - data.leaveDaysLeft!;
  }
}
