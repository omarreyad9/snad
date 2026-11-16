import 'package:flutter/material.dart';
import '../data/products.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

enum SortOption { recommended, priceLow, priceHigh, rating }

/// Discover screen — search, filter, categories, product grid.
class DiscoverScreen extends StatefulWidget {
  final List<Product> products;
  final List<String> savedIds;
  final ValueChanged<String> onToggleSaved;
  final ValueChanged<Product> onOpen;

  const DiscoverScreen({
    super.key,
    required this.products,
    required this.savedIds,
    required this.onToggleSaved,
    required this.onOpen,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _query = '';
  String _activeCategory = 'All pieces';
  SortOption _sort = SortOption.recommended;
  bool _filterOpen = false;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _categories =>
      ['All pieces', ...{...widget.products.map((p) => p.category)}];

  List<Product> get _visibleProducts {
    final q = _query.trim().toLowerCase();
    final matches = widget.products.where((p) {
      final matchCat = _activeCategory == 'All pieces' ||
          (_activeCategory == 'New in' ? p.badge != null : p.category == _activeCategory);
      final matchSearch = q.isEmpty ||
          '${p.name} ${p.category} ${p.color}'.toLowerCase().contains(q);
      return matchCat && matchSearch;
    }).toList();

    matches.sort((a, b) {
      switch (_sort) {
        case SortOption.priceLow:
          return a.price.compareTo(b.price);
        case SortOption.priceHigh:
          return b.price.compareTo(a.price);
        case SortOption.rating:
          return b.rating.compareTo(a.rating);
        case SortOption.recommended:
          final aHas = a.badge != null ? 1 : 0;
          final bHas = b.badge != null ? 1 : 0;
          return bHas.compareTo(aHas);
      }
    });
    return matches;
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _reset() {
    _searchController.clear();
    setState(() {
      _query = '';
      _activeCategory = 'All pieces';
      _sort = SortOption.recommended;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleProducts;
    final hasFilter = _query.isNotEmpty || _activeCategory != 'All pieces';

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero copy ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CURATED FOR YOU', style: context.mc.eyebrow),
                SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: context.mc.heroTitle.copyWith(fontSize: 48),
                    children: [
                      TextSpan(text: 'Find your\n'),
                      TextSpan(
                        text: 'everyday',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: context.mc.brandLight,
                        ),
                      ),
                      TextSpan(text: ' icon.'),
                    ],
                  ),
                ),
                SizedBox(height: 17),
                Text(
                  'Thoughtful pieces, made to stay in your wardrobe.',
                  style: context.mc.body,
                ),
              ],
            ),
          ),
          SizedBox(height: 26),
          // ── Search + filter ──
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: context.mc.card,
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 17, color: context.mc.textMuted),
                      SizedBox(width: 9),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _query = v),
                          controller: _searchController,
                          style: TextStyle(fontSize: 12, color: context.mc.textStrong),
                          decoration: InputDecoration(
                            hintText: 'Search pieces',
                            hintStyle: TextStyle(fontSize: 12, color: context.mc.textMuted),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          onTap: _clearSearch,
                          child: Icon(Icons.close, size: 14, color: context.mc.textMuted),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 9),
              GestureDetector(
                onTap: () => setState(() => _filterOpen = !_filterOpen),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: _filterOpen ? context.mc.brand : context.mc.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune,
                    size: 18,
                    color: _filterOpen ? Colors.white : context.mc.textMid,
                  ),
                ),
              ),
            ],
          ),
          // ── Filter panel ──
          if (_filterOpen) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: context.mc.panel,
                border: Border.all(color: context.mc.outline),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF503928).withOpacity(0.08),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sort collection',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.mc.textStrong),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _filterOpen = false),
                        child: Icon(Icons.close, size: 15, color: context.mc.textMuted),
                      ),
                    ],
                  ),
                  ...[
                    (SortOption.recommended, 'Recommended'),
                    (SortOption.priceLow, 'Price: low to high'),
                    (SortOption.priceHigh, 'Price: high to low'),
                    (SortOption.rating, 'Highest rated'),
                  ].map((e) {
                    final (value, label) = e;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _sort = value;
                        _filterOpen = false;
                      }),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: context.mc.hairline)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(label, style: TextStyle(fontSize: 11, color: context.mc.textMid)),
                            if (_sort == value)
                              Icon(Icons.check, size: 15, color: context.mc.brand),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          SizedBox(height: 27),
          // ── Section heading ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EXPLORE COLLECTION', style: context.mc.eyebrow),
                  SizedBox(height: 6),
                  Text(
                    hasFilter ? 'Your results' : 'New & notable',
                    style: context.mc.sectionTitle,
                  ),
                ],
              ),
              GestureDetector(
                onTap: _reset,
                child: Text(
                  'View all',
                  style: TextStyle(fontSize: 11, color: context.mc.accentText),
                ),
              ),
            ],
          ),
          // ── Categories ──
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: 10),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isActive = _activeCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _activeCategory = cat),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: isActive ? context.mc.pillActive : context.mc.pill,
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive ? Colors.white : context.mc.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // ── Grid ──
          if (visible.isEmpty)
            SizedBox(
              height: 280,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 25, color: context.mc.brandSoft),
                  SizedBox(height: 16),
                  Text('No pieces found', style: TextStyle(fontFamily: MuseTheme.serif, fontSize: 24, color: context.mc.textStrong)),
                  SizedBox(height: 7),
                  Text('Try another search or browse all pieces.', style: TextStyle(fontSize: 12, color: context.mc.textMuted)),
                  SizedBox(height: 18),
                  OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.mc.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Reset filters', style: TextStyle(fontSize: 11, color: context.mc.accentText)),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 13,
                childAspectRatio: 0.58,
              ),
              itemCount: visible.length,
              itemBuilder: (_, i) {
                final p = visible[i];
                return ProductCard(
                  product: p,
                  saved: widget.savedIds.contains(p.id),
                  onToggleSaved: widget.onToggleSaved,
                  onOpen: widget.onOpen,
                );
              },
            ),
        ],
      ),
    );
  }
}