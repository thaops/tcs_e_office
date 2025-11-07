class DocumentFilterOption {
  final String value;
  final String label;
  final String? color;

  DocumentFilterOption({required this.value, required this.label, this.color});

  factory DocumentFilterOption.fromJson(Map<String, dynamic> json) {
    return DocumentFilterOption(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      color: json['color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'label': label, 'color': color};
  }

  @override
  String toString() {
    return 'DocumentFilterOption(value: $value, label: $label, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentFilterOption &&
        other.value == value &&
        other.label == label &&
        other.color == color;
  }

  @override
  int get hashCode {
    return value.hashCode ^ label.hashCode ^ color.hashCode;
  }
}
