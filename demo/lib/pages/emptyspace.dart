import 'package:flutter/material.dart';
import '../model/product.dart';
import './productdetailspage.dart';

class RecommendationResultsPage extends StatefulWidget {
  final String roomType;
  final double measuredWidth;
  final double measuredDepth;

  // Later this will come from backend
  // For now we pass it in directly
  final List<Product> recommendations;

  const RecommendationResultsPage({
    super.key,
    required this.roomType,
    required this.measuredWidth,
    required this.measuredDepth,
    required this.recommendations,
  });

  @override
  State<RecommendationResultsPage> createState() =>
      _RecommendationResultsPageState();
}

class _RecommendationResultsPageState extends State<RecommendationResultsPage> {
  final Color backgroundColor = const Color(0xFF1E1E1E);
  final Color cardColor = const Color(0xFF2A2A2A);
  final Color accentColor = const Color(0xFFFDB04B);

  String _selectedFilter = 'Best Fit'; // default sort
  late List<Product> _filteredProducts;

  final List<String> _filters = [
    'Best Fit',
    'Price: Low to High',
    'Price: High to Low',
    'Top Rated',
  ];

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(widget.recommendations);
    _applyFilter('Best Fit');
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'Price: Low to High':
          _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'Price: High to Low':
          _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'Top Rated':
          _filteredProducts.sort(
            (a, b) => b.averageRating.compareTo(a.averageRating),
          );
          break;
        case 'Best Fit':
        default:
          // Sort by how well dimensions fit the space
          _filteredProducts.sort((a, b) {
            final aFit = _getFitScore(a);
            final bFit = _getFitScore(b);
            return bFit.compareTo(aFit);
          });
      }
    });
  }

  // Higher score = better fit for the space
  double _getFitScore(Product product) {
    if (product.dimensions == null) return 0;
    final d = product.dimensions!;

    // Does it fit at all?
    if (d.length > widget.measuredWidth || d.width > widget.measuredDepth)
      return 0;

    // How much space does it use? Closer to 50% is ideal
    final roomArea = widget.measuredWidth * widget.measuredDepth;
    final productArea = d.length * d.width;
    final ratio = productArea / roomArea;

    // Ideal ratio is 0.3 to 0.6
    if (ratio >= 0.3 && ratio <= 0.6) return 100;
    if (ratio < 0.3) return ratio * 200; // too small
    return (1 - ratio) * 100; // too large
  }

  // Does this product fit in the measured space?
  bool _doesFit(Product product) {
    if (product.dimensions == null) return true;
    final d = product.dimensions!;
    return d.length <= widget.measuredWidth && d.width <= widget.measuredDepth;
  }

  // How much space to spare
  String _getFitLabel(Product product) {
    if (product.dimensions == null) return 'Check dimensions';
    final d = product.dimensions!;

    if (!_doesFit(product)) {
      final overWidth = d.length - widget.measuredWidth;
      final overDepth = d.width - widget.measuredDepth;
      final maxOver = overWidth > overDepth ? overWidth : overDepth;
      return 'Too large by ${maxOver.toStringAsFixed(0)}cm';
    }

    final spareWidth = widget.measuredWidth - d.length;
    final spareDepth = widget.measuredDepth - d.width;
    final minSpare = spareWidth < spareDepth ? spareWidth : spareDepth;
    return '${minSpare.toStringAsFixed(0)}cm to spare';
  }

  String _getRoomTypeLabel() {
    const labels = {
      'bedroom': 'Bedroom',
      'living_room': 'Living Room',
      'dining': 'Dining Room',
      'office': 'Office',
      'general': 'Room',
    };
    return labels[widget.roomType] ?? 'Room';
  }

  String _getRoomTypeIcon() {
    const icons = {
      'bedroom': '🛏',
      'living_room': '🛋',
      'dining': '🍽',
      'office': '💼',
      'general': '🏠',
    };
    return icons[widget.roomType] ?? '🏠';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            backgroundColor: backgroundColor,
            expandedHeight: 140,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getRoomTypeIcon(),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_getRoomTypeLabel()} Recommendations',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.straighten, color: accentColor, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.measuredWidth.toStringAsFixed(0)}cm × '
                          '${widget.measuredDepth.toStringAsFixed(0)}cm · '
                          '${_filteredProducts.length} items found',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;
                  return GestureDetector(
                    onTap: () => _applyFilter(filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor : Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? accentColor : Colors.white24,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Empty state
          if (_filteredProducts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, color: Colors.white24, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'No furniture found\nfor this space',
                      style: TextStyle(color: Colors.white60, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // Product grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = _filteredProducts[index];
                return _buildProductCard(product);
              }, childCount: _filteredProducts.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final fits = _doesFit(product);
    final fitLabel = _getFitLabel(product);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailsPage(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: fits ? Colors.green.withOpacity(0.3) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images[0],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),

                  // Fit badge — top right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: fits
                            ? Colors.green.withOpacity(0.9)
                            : Colors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        fits ? '✅ Fits' : '❌ Large',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Dimensions
                  if (product.dimensions != null)
                    Text(
                      '${product.dimensions!.length.toStringAsFixed(0)}×'
                      '${product.dimensions!.width.toStringAsFixed(0)}cm',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  const SizedBox(height: 4),

                  // Fit label
                  Text(
                    fitLabel,
                    style: TextStyle(
                      color: fits ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.chair, color: Colors.white24, size: 40),
      ),
    );
  }
}
