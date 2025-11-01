class AdvertisingModel {
  final int id;
  final String imageUrl;
  final DateTime createDate;
  final bool isActive;

  AdvertisingModel({
    required this.id,
    required this.imageUrl,
    required this.createDate,
    required this.isActive,
  });

  factory AdvertisingModel.fromJson(Map<String, dynamic> json) {
    return AdvertisingModel(
      id: json['id'],
      imageUrl: json['imageUrl'],
      createDate: DateTime.parse(json['createDate']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'createDate': createDate.toIso8601String(),
      'isActive': isActive,
    };
  }
}
