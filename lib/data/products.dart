import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductVariant {
  final String id;
  final String size;
  final String color;
  final int stock;

  const ProductVariant({
    required this.id,
    required this.size,
    required this.color,
    required this.stock,
  });

  factory ProductVariant.fromMap(Map<String, dynamic> m) => ProductVariant(
        id: m['id'].toString(),
        size: (m['size'] ?? '').toString(),
        color: (m['color'] ?? '').toString(),
        stock: (m['stock_quantity'] as num?)?.toInt() ?? 0,
      );
}

class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final double? oldPrice;
  final String image; // first image
  final List<String> images;
  final String color; // first variant color
  final String? badge;
  final double rating;
  final List<ProductVariant> variants;

  const Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    required this.price,
    this.oldPrice,
    required this.image,
    this.images = const [],
    this.color = '',
    this.badge,
    this.rating = 0,
    this.variants = const [],
  });

  /// Unique sizes from the variants (fallback if none).
  List<String> get sizes {
    final s = variants.map((v) => v.size).where((e) => e.isNotEmpty).toSet().toList();
    return s.isEmpty ? ['S', 'M', 'L', 'XL'] : s;
  }

  /// Unique colors from the variants.
  List<String> get colors =>
      variants.map((v) => v.color).where((e) => e.isNotEmpty).toSet().toList();

  factory Product.fromMap(Map<String, dynamic> m) {
    final imgs = ((m['product_images'] as List?) ?? [])
        .map((i) => (i as Map)['image_url']?.toString() ?? '')
        .where((u) => u.isNotEmpty)
        .toList();
    final vars = ((m['product_variants'] as List?) ?? [])
        .map((v) => ProductVariant.fromMap(v as Map<String, dynamic>))
        .toList();
    return Product(
      id: m['id'].toString(),
      name: (m['name'] ?? 'Unnamed').toString(),
      description: (m['description'] ?? '').toString(),
      category: ((m['categories'] as Map?)?['name'] ?? 'Other').toString(),
      price: ((m['price'] ?? 0) as num).toDouble(),
      image: imgs.isNotEmpty ? imgs.first : '',
      images: imgs,
      color: vars.isNotEmpty ? vars.first.color : '',
      variants: vars,
    );
  }
}

/// Loads products (with category, images and variants) from Supabase.
Future<List<Product>> fetchProducts() async {
  try {
    final rows = await Supabase.instance.client
        .from('products')
        .select(
          'id, name, description, price, category_id, '
          'categories(id, name), '
          'product_images(id, image_url), '
          'product_variants(id, size, color, stock_quantity)',
        )
        .order('created_at', ascending: false);
    final data = rows as List;
    debugPrint('Loaded ${data.length} products from Supabase');
    final list = data
        .map((r) => Product.fromMap(r as Map<String, dynamic>))
        .toList();
    if (list.isNotEmpty) return list;
    debugPrint('products table is empty - using local sample data');
  } catch (e) {
    debugPrint('Failed to load products from Supabase: $e');
  }
  return products;
}

/// Offline fallback only.
const List<Product> products = [
  Product(
    id: '1',
    name: 'The Linen Edit',
    category: 'Dresses',
    price: 128,
    image: 'https://images.pexels.com/photos/7588506/pexels-photo-7588506.jpeg?auto=compress&cs=tinysrgb&w=700',
    color: 'Natural',
    rating: 4.8,
  ),
  Product(
    id: '2',
    name: 'Soft Structure',
    category: 'Outerwear',
    price: 185,
    image: 'https://images.pexels.com/photos/8483832/pexels-photo-8483832.jpeg?auto=compress&cs=tinysrgb&w=700',
    color: 'Camel',
    rating: 4.9,
  ),
];