import 'package:flutter/material.dart';
import '../data/products.dart';
import '../theme/app_theme.dart';

/// Product detail screen — image, options, add to bag.
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool saved;
  final VoidCallback onBack;
  final VoidCallback onToggleSaved;
  final VoidCallback onAdd;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.saved,
    required this.onBack,
    required this.onToggleSaved,
    required this.onAdd,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _size;
  String? _color;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final sizes = p.sizes;
    final colors = p.colors;
    final size = _size ?? sizes.first;
    final color = _color ?? (colors.isNotEmpty ? colors.first : '');
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top bar ──
          SizedBox(
            height: 66,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _IconButton(
                  icon: Icons.arrow_back,
                  onTap: widget.onBack,
                ),
                Text('Product details', style: TextStyle(fontSize: 12, color: context.mc.textMid)),
                _IconButton(
                  icon: widget.saved ? Icons.favorite : Icons.favorite_border,
                  saved: widget.saved,
                  onTap: widget.onToggleSaved,
                ),
              ],
            ),
          ),
          // ── Image ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  p.image,
                  height: 390,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : Container(height: 390, color: context.mc.placeholder),
                  errorBuilder: (context, error, stack) =>
                      Container(height: 390, color: context.mc.placeholder),
                ),
              ),
              Positioned(
                bottom: 13,
                left: 13,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'NEW ARRIVAL',
                    style: TextStyle(
                      fontSize: 8,
                      letterSpacing: 0.88,
                      color: Color(0xFF76523D),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // ── Copy ──
          Padding(
            padding: EdgeInsets.fromLTRB(2, 23, 2, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.category.toUpperCase(), style: context.mc.eyebrow),
                SizedBox(height: 8),
                Text(
                  p.name,
                  style: TextStyle(
                    fontFamily: MuseTheme.serif,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1.28,
                    color: context.mc.textStrong,
                  ),
                ),
                SizedBox(height: 13),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: context.mc.brandAccent),
                        SizedBox(width: 4),
                        Text(
                          p.rating > 0 ? '${p.rating.toStringAsFixed(1)} rating' : 'No reviews yet',
                          style: TextStyle(fontSize: 10, color: context.mc.brandAccent),
                        ),
                      ],
                    ),
                    Text(
                      'EGP ${p.price.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.mc.textStrong),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Text(
                  p.description.isNotEmpty
                      ? p.description
                      : 'A considered everyday piece with an easy silhouette.',
                  style: TextStyle(fontSize: 11, height: 1.7, color: context.mc.textMuted),
                ),
              ],
            ),
          ),
          // ── Color option ──
          if (colors.isNotEmpty)
            _OptionBlock(
              label: 'Color',
              value: color,
              child: Row(
                children: colors
                    .map((c) => Padding(
                          padding: EdgeInsets.only(right: 9),
                          child: GestureDetector(
                            onTap: () => setState(() => _color = c),
                            child: _ColorDot(
                              color: _colorFromName(c),
                              selected: c == color,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          // ── Size option ──
          _OptionBlock(
            label: 'Size',
            child: Row(
              children: sizes.map((s) {
                final isSelected = size == s;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: s != sizes.last ? 9 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _size = s),
                      child: Container(
                        height: 39,
                        decoration: BoxDecoration(
                          color: isSelected ? context.mc.brand : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? context.mc.brand : context.mc.outline,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Center(
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white : context.mc.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 19),
          // ── CTA ──
          GestureDetector(
            onTap: widget.onAdd,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: context.mc.primaryButton,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.add, size: 17, color: Colors.white),
                  SizedBox(width: 9),
                  Text(
                    'Add $size to bag',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  Spacer(),
                  Text(
                    'EGP ${p.price.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final bool saved;
  final VoidCallback onTap;

  const _IconButton({required this.icon, this.saved = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: context.mc.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 19,
          color: saved ? context.mc.brand : context.mc.textMid,
        ),
      ),
    );
  }
}

class _OptionBlock extends StatelessWidget {
  final String label;
  final String? value;
  final Widget child;

  const _OptionBlock({required this.label, this.value, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.mc.hairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: context.mc.textStrong)),
                if (value != null)
                  Text(value!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: context.mc.textMid)),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;

  const _ColorDot({required this.color, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: context.mc.frame, width: 4),
        boxShadow: selected
            ? [BoxShadow(color: context.mc.brand.withOpacity(0.5), blurRadius: 0, spreadRadius: 1)]
            : null,
      ),
    );
  }
}

Color _colorFromName(String name) {
  switch (name.trim().toLowerCase()) {
    case 'black': return const Color(0xFF363330);
    case 'white': return const Color(0xFFF5F2EE);
    case 'red': return const Color(0xFFC0392B);
    case 'blue': return const Color(0xFF2F5D8A);
    case 'navy': return const Color(0xFF1F2A44);
    case 'green': return const Color(0xFF4F7A4F);
    case 'beige': return const Color(0xFFE7DED0);
    case 'brown': return const Color(0xFF7A5238);
    case 'grey':
    case 'gray': return const Color(0xFF9A9A9A);
    case 'pink': return const Color(0xFFE5A8B8);
    case 'yellow': return const Color(0xFFE4C85A);
    default: return const Color(0xFFC9B6A3);
  }
}