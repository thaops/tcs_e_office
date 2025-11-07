class IssueUnitModel {
  final String value;
  final String label;

  IssueUnitModel({required this.value, required this.label});

  factory IssueUnitModel.fromJson(Map<String, dynamic> json) {
    return IssueUnitModel(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'label': label};
  }
}
