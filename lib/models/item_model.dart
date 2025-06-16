class Item {
  final int id;
  final String name;
  final int stok;
  final String categoryId;
  final String foto;

  Item({
    required this.id,
    required this.name,
    required this.stok,
    required this.categoryId,
    required this.foto,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      stok: json['stok'],
      categoryId: json['category_id'],
      foto: json['foto'],
    );
  }
}
