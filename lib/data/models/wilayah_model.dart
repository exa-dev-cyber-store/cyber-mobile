class WilayahModel {
  final String id;
  final String name;

  WilayahModel({
    required this.id,
    required this.name,
  });

  factory WilayahModel.fromJson(Map<String, dynamic> json) {
    return WilayahModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
