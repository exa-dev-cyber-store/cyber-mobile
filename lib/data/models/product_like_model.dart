class ProductLikeModel {
  final String id;
  final String name;
  final int price;
  final String category;
  final String description;
  final String imageThumbnail;
  final List<String> imageDetails;

  ProductLikeModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.imageThumbnail,
    required this.imageDetails,
  });

  factory ProductLikeModel.fromJson(Map<String, dynamic> json) {
    String categoryName = '';
    if (json['category'] is Map) {
      categoryName = json['category']['name']?.toString() ?? '';
    } else if (json['category'] is String) {
      categoryName = json['category'];
    }

    List<String> details = [];
    if (json['image_details'] is List) {
      details = (json['image_details'] as List)
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return ProductLikeModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      category: categoryName,
      description: json['description']?.toString() ?? '',
      imageThumbnail: json['image_thumbnail']?.toString() ?? '',
      imageDetails: details,
    );
  }
}
