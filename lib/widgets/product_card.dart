import 'package:flutter/material.dart';
import '../data/products.dart';
import '../theme/app_theme.dart';

/// A single product card for grid layouts.
class ProductCard extends StatelessWidget {
  final Product product;
  final bool saved;
  final ValueChanged<String> onToggleSaved;
  final ValueChanged<Product> onOpen;

  const ProductCard({
    super.key,
    required this.product,
    required this.saved,
    required this.onToggleSaved,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Image ──
        GestureDetector(
          onTap: () => onOpen(product),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.image,
                  height: 232,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : Container(height: 232, color: context.mc.placeholder),
                  errorBuilder: (context, error, stack) {
                    debugPrint('Image failed: ${product.image} -> $error');
                    return Container(
                      height: 232,
                      color: context.mc.placeholder,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_not_supported_outlined,
                              color: context.mc.textFaint),
                          SizedBox(height: 8),
                          Text(
                            product.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12, color: context.mc.accentText),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (product.badge != null)
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.86),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.badge!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        letterSpacing: 0.64,
                        color: Color(0xFF684735),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 10,
                top: 10,
                child: GestureDetector(
                  onTap: () => onToggleSaved(product.id),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.88),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      saved ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: saved ? context.mc.brand : Color(0xFF755846),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Info ──
        Padding(
          padding: EdgeInsets.fromLTRB(3, 11, 3, 0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontFamily: MuseTheme.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.26,
                      color: context.mc.textStrong,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    product.category,
                    style: TextStyle(
                      fontSize: 10,
                      color: context.mc.textMuted,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'EGP ${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.mc.textStrong,
                        ),
                      ),
                      if (product.oldPrice != null) ...[
                        SizedBox(width: 7),
                        Text(
                          'EGP ${product.oldPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: context.mc.textFaint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              Positioned(
                right: 2,
                top: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: context.mc.brandAccent),
                    SizedBox(width: 3),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 9,
                        color: context.mc.brandAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}