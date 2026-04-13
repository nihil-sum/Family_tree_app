class Person {
  final int? id;
  final String uuid;
  final String familyName;
  final String givenName;
  final String? generationName;
  final String? courtesyName;
  final String? artName;
  final String? englishName;
  final String gender;
  final String? birthDate;
  final String? birthDateLunar;
  final String? birthPlace;
  final String? deathDate;
  final String? deathPlace;
  final String? burialPlace;
  final bool isDeceased;
  final bool isAdopted;
  final String? biography;
  final String? achievements;
  final String? occupation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Person({
    this.id,
    required this.uuid,
    required this.familyName,
    required this.givenName,
    this.generationName,
    this.courtesyName,
    this.artName,
    this.englishName,
    required this.gender,
    this.birthDate,
    this.birthDateLunar,
    this.birthPlace,
    this.deathDate,
    this.deathPlace,
    this.burialPlace,
    this.isDeceased = false,
    this.isAdopted = false,
    this.biography,
    this.achievements,
    this.occupation,
    this.createdAt,
    this.updatedAt,
  });

  /// Full Chinese name (姓 + 名)
  String get fullName => '$familyName$givenName';

  /// Display name with generation name if available
  String get displayName {
    if (generationName != null && generationName!.isNotEmpty) {
      return '$familyName$generationName$givenName';
    }
    return fullName;
  }

  /// Formatted gender in Chinese
  String get genderChinese => gender == 'M' ? '男' : gender == 'F' ? '女' : '未知';

  /// Age calculation (approximate)
  int? get age {
    if (birthDate == null) return null;
    try {
      final birth = DateTime.parse(birthDate!);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  /// Whether the person is alive
  bool get isAlive => !isDeceased;

  /// Whether the person is the heir (eldest son)
  bool get isHeir => false; // Default to false, can be extended later

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int?,
      uuid: json['uuid'] as String,
      familyName: json['family_name'] as String,
      givenName: json['given_name'] as String,
      generationName: json['generation_name'] as String?,
      courtesyName: json['courtesy_name'] as String?,
      artName: json['art_name'] as String?,
      englishName: json['english_name'] as String?,
      gender: json['gender'] as String,
      birthDate: json['birth_date'] as String?,
      birthDateLunar: json['birth_date_lunar'] as String?,
      birthPlace: json['birth_place'] as String?,
      deathDate: json['death_date'] as String?,
      deathPlace: json['death_place'] as String?,
      burialPlace: json['burial_place'] as String?,
      isDeceased: json['is_deceased'] as bool? ?? false,
      isAdopted: json['is_adopted'] as bool? ?? false,
      biography: json['biography'] as String?,
      achievements: json['achievements'] as String?,
      occupation: json['occupation'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'family_name': familyName,
      'given_name': givenName,
      if (generationName != null) 'generation_name': generationName,
      if (courtesyName != null) 'courtesy_name': courtesyName,
      if (artName != null) 'art_name': artName,
      if (englishName != null) 'english_name': englishName,
      'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (birthDateLunar != null) 'birth_date_lunar': birthDateLunar,
      if (birthPlace != null) 'birth_place': birthPlace,
      if (deathDate != null) 'death_date': deathDate,
      if (deathPlace != null) 'death_place': deathPlace,
      if (burialPlace != null) 'burial_place': burialPlace,
      'is_deceased': isDeceased,
      'is_adopted': isAdopted,
      if (biography != null) 'biography': biography,
      if (achievements != null) 'achievements': achievements,
      if (occupation != null) 'occupation': occupation,
    };
  }

  Person copyWith({
    int? id,
    String? uuid,
    String? familyName,
    String? givenName,
    String? generationName,
    String? courtesyName,
    String? artName,
    String? englishName,
    String? gender,
    String? birthDate,
    String? birthDateLunar,
    String? birthPlace,
    String? deathDate,
    String? deathPlace,
    String? burialPlace,
    bool? isDeceased,
    bool? isAdopted,
    String? biography,
    String? achievements,
    String? occupation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Person(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      familyName: familyName ?? this.familyName,
      givenName: givenName ?? this.givenName,
      generationName: generationName ?? this.generationName,
      courtesyName: courtesyName ?? this.courtesyName,
      artName: artName ?? this.artName,
      englishName: englishName ?? this.englishName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      birthDateLunar: birthDateLunar ?? this.birthDateLunar,
      birthPlace: birthPlace ?? this.birthPlace,
      deathDate: deathDate ?? this.deathDate,
      deathPlace: deathPlace ?? this.deathPlace,
      burialPlace: burialPlace ?? this.burialPlace,
      isDeceased: isDeceased ?? this.isDeceased,
      isAdopted: isAdopted ?? this.isAdopted,
      biography: biography ?? this.biography,
      achievements: achievements ?? this.achievements,
      occupation: occupation ?? this.occupation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
