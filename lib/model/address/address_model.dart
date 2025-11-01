class AddressModel {
  final int? id;
  final String name;
  final String? homeNo;
  final String? street;
  final String? district;
  final String? province;
  final double latitude;
  final double longitude;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    this.id,
    required this.name,
    this.homeNo,
    this.street,
    this.district,
    this.province,
    required this.latitude,
    required this.longitude,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // From JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      name: json['name'],
      homeNo: json['home_no'],
      street: json['street'],
      district: json['district'],
      province: json['province'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      userId: json['user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (homeNo != null) 'home_no': homeNo,
      if (street != null) 'street': street,
      if (district != null) 'district': district,
      if (province != null) 'province': province,
      'latitude': latitude,
      'longitude': longitude,
      if (userId != null) 'user_id': userId,
    };
  }

  // Copy with
  AddressModel copyWith({
    int? id,
    String? name,
    String? homeNo,
    String? street,
    String? district,
    String? province,
    double? latitude,
    double? longitude,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      homeNo: homeNo ?? this.homeNo,
      street: street ?? this.street,
      district: district ?? this.district,
      province: province ?? this.province,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get full address string
  String get fullAddress {
    List<String> parts = [];
    if (homeNo != null && homeNo!.isNotEmpty) parts.add(homeNo!);
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (province != null && province!.isNotEmpty) parts.add(province!);
    return parts.join(', ');
  }
}
