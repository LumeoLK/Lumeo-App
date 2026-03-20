import 'package:flutter/material.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({Key? key}) : super(key: key);

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  int _activeNav = 0;

  // ── Sample listings data ──────────────────────────────────
  final List<Map<String, dynamic>> listings = [
    {
      'name': '4 Chair Dinning Set',
      'brand': 'RusticEdge Wooden Collection',
      'price': '₦250,000',
      'views': 312,
      'likes': 41,
      'comments': 7,
      'active': true,
      'image': 'assets/images/chair1.avif',
    },
    {
      'name': '4 Chair Dinning Set',
      'brand': 'RusticEdge Wooden Collection',
      'price': '₦250,000',
      'views': 312,
      'likes': 41,
      'comments': 7,
      'active': true,
      'image': 'assets/images/chair2.avif',
    },
    {
      'name': '4 Chair Dinning Set',
      'brand': 'RusticEdge Wooden Collection',
      'price': '₦250,000',
      'views': 312,
      'likes': 41,
      'comments': 7,
      'active': true,
      'image': 'assets/images/chair1.avif',
    },
  ];

  // ── Sample orders data ────────────────────────────────────
  final List<Map<String, dynamic>> orders = [
    {
      'name': 'Zenfold Chair',
      'orderId': 'Order #VM03458',
      'price': '₦250,000',
      'image': 'assets/images/chair1.avif',
    },
    {
      'name': 'Zenfold Chair',
      'orderId': 'Order #VM03459',
      'price': '₦250,000',
      'image': 'assets/images/chair2.avif',
    },
  ];

  // ── Chart data ────────────────────────────────────────────
  final List<double> thisWeek = [15, 19, 14, 22, 18, 26, 20];
  final List<double> lastWeek = [10, 13, 11, 16, 13, 18, 13];
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Stack(
        children: [
          // ── Scrollable body ──
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCoverAndProfile(),
                const SizedBox(height: 16),
                _buildSellerSummary(),
                const SizedBox(height: 16),
                _buildPerformanceOverview(),
                const SizedBox(height: 20),
                _buildActiveListings(),
                const SizedBox(height: 20),
                _buildNewOrders(),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Fixed bottom nav ──
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNav()),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  COVER + PROFILE  (Facebook-style)
  // ─────────────────────────────────────────────────────────
  Widget _buildCoverAndProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover photo
        Container(
          height: 160,
          width: double.infinity,
          color: const Color(0xFF2a2a2a),
          child: const Center(
            child: Text(
              'Add cover photo',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar overlapping cover
              Transform.translate(
                offset: const Offset(0, -36),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a2a),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1a1a1a),
                      width: 3.5,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Add Profile\nphoto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // Name + handle (pulled up under avatar)
              Transform.translate(
                offset: const Offset(0, -26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Display Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Meta-style amber verified badge
                        CustomPaint(
                          size: const Size(22, 22),
                          painter: _MetaVerifiedPainter(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '@shopname',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    // Divider line like Facebook
                    Container(height: 1, color: const Color(0xFF2a2a2a)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  SELLER SUMMARY CARDS
  // ─────────────────────────────────────────────────────────
  Widget _buildSellerSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seller Summary',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildSummaryCard(
                '₦23,500',
                'Earnings\nthis week',
                Icons.credit_card_rounded,
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                '12',
                'Active\nListings',
                Icons.bookmark_border_rounded,
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                '4.2 ★',
                'Average\nRating',
                Icons.star_border_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFBB040),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(icon, color: Colors.white54, size: 18),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  PERFORMANCE OVERVIEW
  // ─────────────────────────────────────────────────────────
  Widget _buildPerformanceOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'This week vs last week',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 100,
              child: CustomPaint(
                painter: _ChartPainter(thisWeek: thisWeek, lastWeek: lastWeek),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days
                  .map(
                    (d) => Text(
                      d,
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  ACTIVE LISTINGS
  // ─────────────────────────────────────────────────────────
  Widget _buildActiveListings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Listings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See All >',
                  style: TextStyle(color: Color(0xFFFBB040), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal scroll
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              return _buildListingCard(listings[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListingCard(Map<String, dynamic> item, int index) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF3a3a3a),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Column(
              children: [
                // Active badge + menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C3D27),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Color(0xFF4BC87A),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.more_horiz, color: Colors.grey, size: 18),
                  ],
                ),
                const SizedBox(height: 8),

                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    item['image'],
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 80,
                      color: const Color(0xFF3a3a3a),
                      child: const Icon(
                        Icons.chair_rounded,
                        color: Color(0xFF8A5C2A),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item['brand'],
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  item['price'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Stats row
                Row(
                  children: [
                    _buildStat(
                      Icons.visibility_outlined,
                      item['views'],
                      Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    _buildStat(
                      Icons.favorite,
                      item['likes'],
                      const Color(0xFFFBB040),
                    ),
                    const SizedBox(width: 8),
                    _buildStat(
                      Icons.chat_bubble_outline,
                      item['comments'],
                      Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, int value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Text(
          '$value',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  NEW ORDERS
  // ─────────────────────────────────────────────────────────
  Widget _buildNewOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See All >',
                  style: TextStyle(color: Color(0xFFFBB040), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal scroll
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(orders[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Chair thumbnail
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3a3a3a),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                order['image'],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.chair_rounded,
                  color: Color(0xFF8A5C2A),
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Order details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  order['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  order['orderId'],
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 5),
                Text(
                  order['price'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  BOTTOM NAV
  // ─────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final navItems = [
      {'label': 'Overview', 'icon': Icons.grid_view_rounded},
      {'label': 'Listings', 'icon': Icons.format_list_bulleted_rounded},
      {'label': 'Orders', 'icon': Icons.shopping_bag_outlined},
      {'label': 'BluePrint 3D', 'icon': Icons.view_in_ar_rounded},
      {'label': 'Custom', 'icon': Icons.tune_rounded},
      {'label': 'Profile', 'icon': Icons.person_outline_rounded},
    ];

    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF2a2a2a))),
      ),
      child: Row(
        children: List.generate(navItems.length, (i) {
          final active = i == _activeNav;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeNav = i),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Active indicator bar
                  if (active)
                    Container(
                      height: 2.5,
                      width: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBB040),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(3),
                        ),
                      ),
                    ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        navItems[i]['icon'] as IconData,
                        size: 20,
                        color: active
                            ? const Color(0xFFFBB040)
                            : const Color(0xFF555555),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        navItems[i]['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: active
                              ? const Color(0xFFFBB040)
                              : const Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  META VERIFIED BADGE PAINTER
// ─────────────────────────────────────────────────────────────
class _MetaVerifiedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = const Color(0xFFFBB040);
    final cx = size.width / 2;

    // Shield shape
    final path = Path()
      ..moveTo(cx, 0)
      ..cubicTo(cx + 2, 0, size.width, 2, size.width, size.height * 0.35)
      ..cubicTo(
        size.width,
        size.height * 0.72,
        cx + 2,
        size.height * 0.95,
        cx,
        size.height,
      )
      ..cubicTo(
        cx - 2,
        size.height * 0.95,
        0,
        size.height * 0.72,
        0,
        size.height * 0.35,
      )
      ..cubicTo(0, 2, cx - 2, 0, cx, 0)
      ..close();

    canvas.drawPath(path, fillPaint);

    // White checkmark
    final checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final check = Path()
      ..moveTo(size.width * 0.27, size.height * 0.52)
      ..lineTo(size.width * 0.45, size.height * 0.70)
      ..lineTo(size.width * 0.73, size.height * 0.34);

    canvas.drawPath(check, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────
//  PERFORMANCE CHART PAINTER
// ─────────────────────────────────────────────────────────────
class _ChartPainter extends CustomPainter {
  final List<double> thisWeek;
  final List<double> lastWeek;

  _ChartPainter({required this.thisWeek, required this.lastWeek});

  @override
  void paint(Canvas canvas, Size size) {
    const maxV = 28.0;
    const padL = 24.0, padR = 6.0, padT = 4.0, padB = 4.0;
    final drawW = size.width - padL - padR;
    final drawH = size.height - padT - padB;

    Offset pt(int i, double v) => Offset(
      padL + (i / (thisWeek.length - 1)) * drawW,
      padT + drawH - (v / maxV) * drawH,
    );

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF3a3a3a)
      ..strokeWidth = 0.8;

    for (final v in [7.0, 14.0, 21.0, 28.0]) {
      final y = padT + drawH - (v / maxV) * drawH;
      canvas.drawLine(Offset(padL, y), Offset(size.width - padR, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(
          text: v.toInt().toString(),
          style: const TextStyle(fontSize: 8, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Build line path
    Path buildPath(List<double> data) {
      final p = Path();
      for (int i = 0; i < data.length; i++) {
        final o = pt(i, data[i]);
        i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
      }
      return p;
    }

    // Last week dashed grey
    _drawDashed(
      canvas,
      buildPath(lastWeek),
      Paint()
        ..color = const Color(0xFF3a3a3a)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // This week solid amber
    canvas.drawPath(
      buildPath(thisWeek),
      Paint()
        ..color = const Color(0xFFFBB040)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots
    for (int i = 0; i < thisWeek.length; i++) {
      canvas.drawCircle(
        pt(i, thisWeek[i]),
        3,
        Paint()..color = const Color(0xFFFBB040),
      );
      canvas.drawCircle(
        pt(i, lastWeek[i]),
        2,
        Paint()..color = const Color(0xFF555555),
      );
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      double d = 0;
      bool draw = true;
      while (d < metric.length) {
        final len = draw ? 4.0 : 3.0;
        if (draw) canvas.drawPath(metric.extractPath(d, d + len), paint);
        d += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
