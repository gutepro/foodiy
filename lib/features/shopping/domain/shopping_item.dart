class ShoppingItem {
  final String id;
  final String name;
  final String quantityText;
  final bool isChecked;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.quantityText,
    this.isChecked = false,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? quantityText,
    bool? isChecked,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantityText: quantityText ?? this.quantityText,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
