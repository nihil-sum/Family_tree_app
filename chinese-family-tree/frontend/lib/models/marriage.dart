class Marriage {
  final int? id;
  final String uuid;
  final int husbandId;
  final int wifeId;
  final String? marriageDate;
  final String? marriagePlace;
  final String marriageType; // primary, secondary, concubine
  final String? endDate;
  final String? endReason;
  final DateTime? createdAt;

  Marriage({
    this.id,
    required this.uuid,
    required this.husbandId,
    required this.wifeId,
    this.marriageDate,
    this.marriagePlace,
    this.marriageType = 'primary',
    this.endDate,
    this.endReason,
    this.createdAt,
  });

  /// Formatted marriage type in Chinese
  String get typeChinese {
    switch (marriageType) {
      case 'primary':
        return '正室';
      case 'secondary':
        return '侧室';
      case 'concubine':
        return '妾';
      default:
        return '其他';
    }
  }

  factory Marriage.fromJson(Map<String, dynamic> json) {
    return Marriage(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      husbandId: json['husband_id'] as int,
      wifeId: json['wife_id'] as int,
      marriageDate: json['marriage_date'] as String?,
      marriagePlace: json['marriage_place'] as String?,
      marriageType: json['marriage_type'] as String? ?? 'primary',
      endDate: json['end_date'] as String?,
      endReason: json['end_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'husband_id': husbandId,
      'wife_id': wifeId,
      if (marriageDate != null) 'marriage_date': marriageDate,
      if (marriagePlace != null) 'marriage_place': marriagePlace,
      'marriage_type': marriageType,
      if (endDate != null) 'end_date': endDate,
      if (endReason != null) 'end_reason': endReason,
    };
  }

  Marriage copyWith({
    int? id,
    String? uuid,
    int? husbandId,
    int? wifeId,
    String? marriageDate,
    String? marriagePlace,
    String? marriageType,
    String? endDate,
    String? endReason,
    DateTime? createdAt,
  }) {
    return Marriage(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      husbandId: husbandId ?? this.husbandId,
      wifeId: wifeId ?? this.wifeId,
      marriageDate: marriageDate ?? this.marriageDate,
      marriagePlace: marriagePlace ?? this.marriagePlace,
      marriageType: marriageType ?? this.marriageType,
      endDate: endDate ?? this.endDate,
      endReason: endReason ?? this.endReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}