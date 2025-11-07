class EmployeeForwardModel {
  final int id;
  final String employeeCode;
  final String employeeName;
  final String employeeEmail;
  final String departmentCode;
  final String departmentName;
  final String unitCode;
  final String unitName;
  final bool acceptUpdate;
  final dynamic accountId;

  EmployeeForwardModel({
    required this.id,
    required this.employeeCode,
    required this.employeeName,
    required this.employeeEmail,
    required this.departmentCode,
    required this.departmentName,
    required this.unitCode,
    required this.unitName,
    required this.acceptUpdate,
    this.accountId,
  });

  factory EmployeeForwardModel.fromJson(Map<String, dynamic> json) {
    return EmployeeForwardModel(
      id: json['id'] ?? 0,
      employeeCode: json['employeeCode'] ?? '',
      employeeName: json['employeeName'] ?? '',
      employeeEmail: json['employeeEmail'] ?? '',
      departmentCode: json['departmentCode'] ?? '',
      departmentName: json['departmentName'] ?? '',
      unitCode: json['unitCode'] ?? '',
      unitName: json['unitName'] ?? '',
      acceptUpdate: json['acceptUpdate'] ?? false,
      accountId: json['accountId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeCode': employeeCode,
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,
      'departmentCode': departmentCode,
      'departmentName': departmentName,
      'unitCode': unitCode,
      'unitName': unitName,
      'acceptUpdate': acceptUpdate,
      'accountId': accountId,
    };
  }
}
