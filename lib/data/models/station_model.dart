class StationModel {
  final String id;
  final String name;
  final String location;
  final int totalSlots;
  final DateTime? createdAt;

  const StationModel({
    required this.id,
    required this.name,
    required this.location,
    this.totalSlots = 10,
    this.createdAt,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      totalSlots: json['total_slots'] ?? 10,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'total_slots': totalSlots,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
