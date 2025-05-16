class House {
  final String id;
  final String title;
  final int price;
  final String layout;
  final String area;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> tags;
  final String? imageUrl;

  House({
    required this.id,
    required this.title,
    required this.price,
    required this.layout,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.tags,
    this.imageUrl,
  });

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'layout': layout,
      'area': area,
      'lat': latitude,
      'lng': longitude,
      'address': address,
      'tags': tags,
      'imageUrl': imageUrl,
    };
  }

  // 从JSON构造
  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      layout: json['layout'],
      area: json['area'],
      latitude: json['lat'],
      longitude: json['lng'],
      address: json['address'],
      tags: List<String>.from(json['tags']),
      imageUrl: json['imageUrl'],
    );
  }
}
