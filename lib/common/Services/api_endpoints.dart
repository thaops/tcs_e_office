import 'package:tcs_e_office/common/Services/config.dart';

class ApiEndpoints {
  static String get notification => "${Config.baseUrl}/user/onesignal-register";
  static String get unregisterNotification =>
      "${Config.baseUrl}/user/onesignal-unregister";
  static String getNotificationList({int pageIndex = 1, int pageSize = 20}) =>
      "${Config.baseUrl}/notification/getlistnotify?pageIndex=$pageIndex&pageSize=$pageSize";
  static String getNotificationDetail(String notificationId) =>
      "${Config.baseUrl}/notification/getnotifydetail/$notificationId";
  static String markNotificationAsRead(String notificationId) =>
      "${Config.baseUrl}/notification/markasread/$notificationId";
  static String get readNotifications =>
      "${Config.baseUrl}/notification/readnotifications";
  static String get readAllNotifications =>
      "${Config.baseUrl}/notification/readallnotifications";

  static String get login => "${Config.baseUrl}/users/oauth2-google";
  static String loginUrlMicrosoft(int platform, int type) =>
      "${Config.baseUrl}/login/get-redirect-url?platform=$platform&type=$type";
  static String get loginMicrosoft =>
      "${Config.baseUrl}/login/login-with-ms-token";

  static String get loginFrame => "${Config.baseUrl}/users/login";

  static String get getTasks => "${Config.baseUrl}/documenttask/get-tasks";
  static String getTaskById(String taskId) =>
      "${Config.baseUrl}/documenttask/get-task-by-id/$taskId";
  static String get createTask => "${Config.baseUrl}/documenttask/create-task";
  static String updateTask(String taskId) =>
      "${Config.baseUrl}/documenttask/update-task/$taskId";
  static String completeTask(String taskId) =>
      "${Config.baseUrl}/documenttask/complete-task/$taskId";
  static String get forwardTask =>
      "${Config.baseUrl}/documenttask/forward-task";
  static String get reprocessTask =>
      "${Config.baseUrl}/documenttask/reprocess-task";
  static String get getPriorityOptions =>
      "${Config.baseUrl}/documenttask/get-priority-options";
  static String get getStatusOptions =>
      "${Config.baseUrl}/documenttask/get-status-options";
  static String get getRoleOptions =>
      "${Config.baseUrl}/documenttask/get-role-options";
  static String get getTaskCount =>
      "${Config.baseUrl}/documenttask/get-count-response";

  static String get getDocuments => "${Config.baseUrl}/document/get-documents";
  static String getDocumentById(String documentId) =>
      "${Config.baseUrl}/document/get-document-by-id/$documentId";
  static String getDocumentById4Mobile(String documentId) =>
      "${Config.baseUrl}/document/get-document-by-id-4-mobile/$documentId";
  static String get getDocumentStatusOptions =>
      "${Config.baseUrl}/document/get-status-options";
  static String get getDocumentTypeOptions =>
      "${Config.baseUrl}/document/get-document-type-options";
  static String get getDocumentCountByStatus =>
      "${Config.baseUrl}/document/get-count-by-status";

  static String get addComment => "${Config.baseUrl}/document/comment-document";
  static String getComments(String documentId) =>
      "${Config.baseUrl}/document/comments/$documentId";

  static String previewDocument(String documentId) =>
      "${Config.baseUrl}/document/preview-document/$documentId";

  static String exportDocument(String documentId) =>
      "${Config.baseUrl}/document/export-document/$documentId";

  static String get finishDocuments =>
      "${Config.baseUrl}/document/finish-documents";
  static String get getIssueUnitOptions =>
      "${Config.baseUrl}/document/get-issue-unit-options";
  static String get getEmployeesByDepartment =>
      "${Config.baseUrl}/employee/get-list-employee-of-department";
  static String get forwardDocument =>
      "${Config.baseUrl}/document/forward-document";
  static String get approveDocuments =>
      "${Config.baseUrl}/document/approve-documents";

  static String get profile => "${Config.baseUrl}/user/get-info-mine";

  static String get role => "${Config.baseUrl}/tasks/get-role-for-task";

  static String get users =>
      "${Config.baseUrl}/users?userStatus=1&page=1&pageSize=9999";

  static String usersWith({
    int? userStatus,
    int page = 1,
    int pageSize = 99999,
    bool? isAll,
    String? keyword,
  }) {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (userStatus != null) params['userStatus'] = userStatus.toString();
    if (isAll != null) params['isAll'] = isAll.toString();
    if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;
    final query = params.entries.map((e) => "${e.key}=${e.value}").join('&');
    return "${Config.baseUrl}/users?$query";
  }

  static String get employees =>
      "${Config.baseUrl}/employee/get-list-employee?pageIndex=1&pageSize=9999";

  static String get employeesByDepartment =>
      "${Config.baseUrl}/document/get-employee-by-department";

  static String searchEmployeesByDepartment(String keyword) =>
      "${Config.baseUrl}/document/get-employee-by-department?keyword=${Uri.encodeComponent(keyword)}";

  static String get departments =>
      "${Config.baseUrl}/employee/get-list-employee-of-department";

  static String listoff(DateTime firstDayOfMonth, DateTime lastDayOfMonth) {
    final from = Uri.encodeComponent(firstDayOfMonth.toIso8601String());
    final to = Uri.encodeComponent(lastDayOfMonth.toIso8601String());
    return "${Config.baseUrl}/dayoff/get-list-day-off?pageIndex=1&pageSize=9999&fromDate=$from&toDate=$to&keyword=";
  }

  static String get listoffV2 =>
      "${Config.baseUrl}/dayoff/get-list-day-off-schedule";
  static String get listoffListView =>
      "${Config.baseUrl}/dayoff/get-list-day-off-list-view";

  static String getLeaveIDV2(String leaveId) =>
      "${Config.baseUrl}/dayoffv2/get-detail-day-off-v2/$leaveId";
  static String updateLeaveIDV2(String leaveId) =>
      "${Config.baseUrl}/dayoffv2/update-day-off-v2/$leaveId";
  static String deleteLeaveIDV2(String leaveId) =>
      "${Config.baseUrl}/dayoffv2/delete-day-off-v2/$leaveId";
  static String cancelLeaveIDV2(String leaveId) =>
      "${Config.baseUrl}/dayoffv2/cancel-day-off-v2";
  static String get createLeaveIDV2 =>
      "${Config.baseUrl}/dayoffv2/add-day-off-v2";
  static String get getLeaveV2 =>
      "${Config.baseUrl}/dayoffv2/get-list-category-v2";
  static String approveLeaveV2(String approveId) =>
      "${Config.baseUrl}/dayoffv2/approve-day-off-v2/$approveId";
  static String getListApproverV2(int? step, String? keyword) =>
      "${Config.baseUrl}/dayoffv2/get-list-approval-orders-v2";
  static String getListApprovalByUserV2(String leaveOffId) =>
      "${Config.baseUrl}/dayoffv2/get-list-approval-by-v2/$leaveOffId";

  static String getLeaveCommentsV2(String dayOffId) =>
      "${Config.baseUrl}/dayoffv2/get-list-day-off-comments-v2/$dayOffId";
  static String get addLeaveCommentV2 =>
      "${Config.baseUrl}/dayoffv2/add-day-off-comment-v2";

  static String fetchListOff(
    DateTime firstDayOfMonth,
    DateTime lastDayOfMonth,
  ) {
    final from = Uri.encodeComponent(firstDayOfMonth.toIso8601String());
    final to = Uri.encodeComponent(lastDayOfMonth.toIso8601String());
    return "${Config.baseUrl}/dayoff/get-list-day-off?pageIndex=1&pageSize=9999&fromDate=$from&toDate=$to&keyword=";
  }

  static String supportcenterDetail(String supportId) =>
      "${Config.baseUrl}/supportcenter/get-detail-request?id=$supportId";

  static String get messageSupport =>
      "${Config.baseUrl}/supportcenter/create-message";

  static String get leavePagination =>
      "${Config.baseUrl}/dayoff/list-category?pageIndex=1&pageSize=9999";
  static String get careateleave => "${Config.baseUrl}/dayoff/add-day-off";
  static String updateleave(String leaveId) =>
      "${Config.baseUrl}/dayoff/update-day-off/$leaveId";

  static String get projectSupport =>
      "${Config.baseUrl}/supportcenter/get-list-project?page=1&pageSize=9999";

  static String get typeSupport =>
      "${Config.baseUrl}/supportcenter/get-type-support";

  static String getMyAnnualLeave(int year) =>
      "${Config.baseUrl}/dayoff/get-my-register-annual-day-off/$year";
  static String get saveAnnualLeave =>
      "${Config.baseUrl}/dayoff/save-register-annual-day-off";
  static String get updateAnnualLeave =>
      "${Config.baseUrl}/dayoff/update-year-register-annual-day-off";
  static String getMySummaryDayOff(int year) =>
      "${Config.baseUrl}/dayoff/get-my-summary-day-off/$year";

  static String get listEmailContact =>
      "${Config.baseUrl}/supportcenter/get-list-email-contact?projectId=&keyword=&isAll=true";

  static String updateTypeSupport(String supportTypeId) =>
      "${Config.baseUrl}/supportcenter/update-type-support/$supportTypeId";

  static String transferHandler(String supportTransferId) =>
      "${Config.baseUrl}/supportcenter/transfer-handler/$supportTransferId";

  static String updateSupport(String supportId) =>
      "${Config.baseUrl}/supportcenter/update-request/$supportId";

  static String updateStatusSupport(String supportId) =>
      "${Config.baseUrl}/supportcenter/update-status-request/$supportId";

  static String get createSupport =>
      "${Config.baseUrl}/supportcenter/create-request";

  static String get usersProfileApple => "${Config.baseUrl}/users/profile";

  static String listoffApple(
    DateTime firstDayOfMonth,
    DateTime lastDayOfMonth,
  ) {
    final from = Uri.encodeComponent(firstDayOfMonth.toIso8601String());
    final to = Uri.encodeComponent(lastDayOfMonth.toIso8601String());
    return "${Config.baseUrl}/dayoff/list-day-off?pageIndex=1&pageSize=9999&fromDate=$from&toDate=$to&keyword=";
  }

  static String get getListNews => "${Config.baseUrl}/news/getnews";
  static String get getNewsDetail => "${Config.baseUrl}/news/getdetail";
  static String get getNewsComments => "${Config.baseUrl}/news/commentgetlist";
  static String get addNewsComment => "${Config.baseUrl}/news/addcomment";
  static String get doReaction => "${Config.baseUrl}/news/doreaction";
}
