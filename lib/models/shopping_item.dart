class ShoppingItem {
  final int? id;
  final String name;
  final String quantity;

  ShoppingItem({this.id, required this.name, required this.quantity});

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['title'],
      quantity: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': name, 'body': quantity};
  }
}