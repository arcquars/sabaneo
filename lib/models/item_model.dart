class Item {
  final String id;
  final String name;

  Item({required this.id, required this.name});

  @override
  String toString() {
    return 'Item(id: $id, name: $name)';
  }
}