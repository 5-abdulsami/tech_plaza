class PlazaModel {
  final String id;
  final String name;
  final String city;
  final String address;
  final String? description;
  final DateTime createdAt;

  PlazaModel({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    this.description,
    required this.createdAt,
  });

  factory PlazaModel.fromJson(Map<String, dynamic> json) {
    return PlazaModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      description: json['description'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'address': address,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
