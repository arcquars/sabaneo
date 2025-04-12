  class ProductoCar {
    final String id;
    final String name;
    final double price;
    int quantity;

    ProductoCar({
      required this.id,
      required this.name,
      required this.price,
      this.quantity = 1,
    });
  }
