class Product {
  final String id;
  final String barcode;
  final String name;
  final String category;
  final double price;
  final String imageEmoji;

  const Product({
    required this.id,
    required this.barcode,
    required this.name,
    required this.category,
    required this.price,
    required this.imageEmoji,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

// Mock product database — replace with your real data source / DB later
const List<Product> mockProducts = [
  Product(
    id: '1',
    barcode: '012345678901',
    name: 'Mineral Water 1.5L',
    category: 'Beverages',
    price: 1.20,
    imageEmoji: '💧',
  ),
  Product(
    id: '2',
    barcode: '012345678902',
    name: 'Whole Milk 1L',
    category: 'Dairy',
    price: 2.50,
    imageEmoji: '🥛',
  ),
  Product(
    id: '3',
    barcode: '012345678903',
    name: 'White Bread',
    category: 'Bakery',
    price: 1.80,
    imageEmoji: '🍞',
  ),
  Product(
    id: '4',
    barcode: '012345678904',
    name: 'Orange Juice 1L',
    category: 'Beverages',
    price: 3.00,
    imageEmoji: '🍊',
  ),
  Product(
    id: '5',
    barcode: '012345678905',
    name: 'Cheddar Cheese 200g',
    category: 'Dairy',
    price: 4.50,
    imageEmoji: '🧀',
  ),
  Product(
    id: '6',
    barcode: '012345678906',
    name: 'Free Range Eggs x6',
    category: 'Dairy',
    price: 3.20,
    imageEmoji: '🥚',
  ),
];

Product? findProductByBarcode(String barcode) {
  try {
    return mockProducts.firstWhere((p) => p.barcode == barcode);
  } catch (_) {
    return null;
  }
}