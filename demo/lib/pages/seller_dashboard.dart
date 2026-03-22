import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/seller_dashboard_service.dart';
import '../pages/productpage.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  final SellerDashboardService _dashboardService =
      const SellerDashboardService();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _dashboard = const {};

  // ── Fallback chart data ───────────────────────────────────
  final List<double> thisWeek = [15, 19, 14, 22, 18, 26, 20];
  final List<double> lastWeek = [10, 13, 11, 16, 13, 18, 13];
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // ── Data loading ──────────────────────────────────────────
  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('x-auth-token')?.trim() ?? '';

      if (token.isEmpty) {
        throw const SellerDashboardException(
          'Please log in with a seller account first.',
        );
      }

      final dashboard = await _dashboardService.fetchDashboard(token);
      if (!mounted) return;

      setState(() {
        _dashboard = dashboard;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ── Dashboard data getters ────────────────────────────────
  Map<String, dynamic> get _profile => _asMap(_dashboard['profile']);
  Map<String, dynamic> get _summary => _asMap(_dashboard['summary']);
  Map<String, dynamic> get _performance => _asMap(_dashboard['performance']);
  List<Map<String, dynamic>> get _activeListings =>
      _asMapList(_dashboard['activeListings']);
  List<Map<String, dynamic>> get _newOrders =>
      _asMapList(_dashboard['newOrders']);

  // ── Data helpers ──────────────────────────────────────────
  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry('$k', v));
    return const {};
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => _asMap(item)).toList();
  }

  List<String> _asStringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }

  String _text(dynamic value, {String fallback = ''}) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1a1a1a),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SingleChildScrollView(
        // Extra bottom padding so content clears the shell's nav bar
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
    );
  }

  // ─────────────────────────────────────────────────────────
  //  COVER + PROFILE
  // ─────────────────────────────────────────────────────────
  Widget _buildCoverAndProfile() {
    final logo = _text(_profile['logo']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover photo placeholder
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
                  child: logo.isNotEmpty
                      ? ClipOval(child: Image.network(logo, fit: BoxFit.cover))
                      : const Center(
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

              // Name + verified badge + handle
              Transform.translate(
                offset: const Offset(0, -26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _text(
                              _profile['displayName'],
                              fallback: 'Display Name',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        CustomPaint(
                          size: const Size(22, 22),
                          painter: _MetaVerifiedPainter(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _text(_profile['handle'], fallback: '@shopname'),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
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
  //  SELLER SUMMARY
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
                _text(_summary['earningsThisWeekFormatted'], fallback: '₦0'),
                'Earnings\nthis week',
                Icons.credit_card_rounded,
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                _text(_summary['activeListings'], fallback: '0'),
                'Active\nListings',
                Icons.bookmark_border_rounded,
              ),
              const SizedBox(width: 8),
              _buildSummaryCard(
                _text(_summary['averageRating'], fallback: '0'),
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
    final perfDays = _asStringList(_performance['days']);
    final perfThisWeek = _asStringList(_performance['thisWeek']);
    final perfLastWeek = _asStringList(_performance['lastWeek']);

    final chartThisWeek = perfThisWeek.isNotEmpty
        ? perfThisWeek.map((v) => double.tryParse(v) ?? 0.0).toList()
        : thisWeek;
    final chartLastWeek = perfLastWeek.isNotEmpty
        ? perfLastWeek.map((v) => double.tryParse(v) ?? 0.0).toList()
        : lastWeek;
    final chartDays = perfDays.isNotEmpty ? perfDays : days;

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
                painter: _ChartPainter(
                  thisWeek: chartThisWeek,
                  lastWeek: chartLastWeek,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: chartDays
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
    final items = _activeListings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () {
                  final productId = item['id']?.toString() ?? '';
                  if (productId.isNotEmpty) {
                    Get.to(() => ProductDetailPage(productId: productId));
                  }
                },
                child: _buildListingCard(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListingCard(Map<String, dynamic> item) {
    final images = item['images'];
    final imageUrl = (images is List && images.isNotEmpty)
        ? _text(images[0])
        : '';
    final isAsset = imageUrl.startsWith('assets/');

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
          // Image + status header
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF3a3a3a),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Column(
              children: [
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: imageUrl.isNotEmpty
                      ? (isAsset
                            ? Image.asset(
                                imageUrl,
                                height: 80,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _placeholderImage(),
                              )
                            : Image.network(
                                imageUrl,
                                height: 80,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _placeholderImage(),
                              ))
                      : _placeholderImage(),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(item['name'], fallback: 'Untitled product'),
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
                  _text(item['brand'], fallback: ''),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  _text(
                    item['formattedPrice'] ?? item['price'],
                    fallback: '₦0',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildStat(
                      Icons.visibility_outlined,
                      item['views'] is int ? item['views'] : 0,
                      Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    _buildStat(
                      Icons.favorite,
                      item['likes'] is int ? item['likes'] : 0,
                      const Color(0xFFFBB040),
                    ),
                    const SizedBox(width: 8),
                    _buildStat(
                      Icons.chat_bubble_outline,
                      item['comments'] is int ? item['comments'] : 0,
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

  Widget _placeholderImage() {
    return Container(
      height: 80,
      color: const Color(0xFF3a3a3a),
      child: const Icon(
        Icons.chair_rounded,
        color: Color(0xFF8A5C2A),
        size: 40,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  NEW ORDERS
  // ─────────────────────────────────────────────────────────
  Widget _buildNewOrders() {
    final items = _newOrders.isNotEmpty
        ? _newOrders
        : [
            {
              'id': 'order1',
              'productName': 'Modern Chair',
              'customerName': 'John Doe',
              'status': 'Processing',
              'image': 'assets/chair.jpg',
            },
            {
              'id': 'order2',
              'productName': 'Wooden Table',
              'customerName': 'Jane Smith',
              'status': 'Shipped',
              'image': 'assets/chair.jpg',
            },
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildOrderCard(items[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final imageUrl = _text(order['image']);
    final isAsset = imageUrl.startsWith('assets/');

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
          // Thumbnail
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF3a3a3a),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? (isAsset
                        ? Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.chair_rounded,
                              color: Color(0xFF8A5C2A),
                              size: 26,
                            ),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.chair_rounded,
                              color: Color(0xFF8A5C2A),
                              size: 26,
                            ),
                          ))
                  : const Icon(
                      Icons.chair_rounded,
                      color: Color(0xFF8A5C2A),
                      size: 26,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          // Order info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _text(order['name'], fallback: 'Order item'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _text(
                    order['orderId'] ?? order['orderNumber'],
                    fallback: 'Order',
                  ),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 5),
                Text(
                  _text(
                    order['formattedTotalPrice'] ??
                        order['formattedPrice'] ??
                        order['price'],
                    fallback: '₦0',
                  ),
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
}

// ─────────────────────────────────────────────────────────
//  PAINTERS
// ─────────────────────────────────────────────────────────

class _MetaVerifiedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = const Color(0xFFFBB040);
    final cx = size.width / 2;

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

class _ChartPainter extends CustomPainter {
  final List<double> thisWeek;
  final List<double> lastWeek;

  _ChartPainter({required this.thisWeek, required this.lastWeek});

  @override
  void paint(Canvas canvas, Size size) {
    if (thisWeek.length < 2) return;

    const maxV = 28.0;
    const padL = 24.0, padR = 6.0, padT = 4.0, padB = 4.0;
    final drawW = size.width - padL - padR;
    final drawH = size.height - padT - padB;

    Offset pt(int i, double v) => Offset(
      padL + (i / (thisWeek.length - 1)) * drawW,
      padT + drawH - (v / maxV) * drawH,
    );

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

    Path buildPath(List<double> data) {
      final p = Path();
      for (int i = 0; i < data.length; i++) {
        final o = pt(i, data[i]);
        i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
      }
      return p;
    }

    // Last week — dashed grey
    _drawDashed(
      canvas,
      buildPath(lastWeek),
      Paint()
        ..color = const Color(0xFF3a3a3a)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // This week — solid amber
    canvas.drawPath(
      buildPath(thisWeek),
      Paint()
        ..color = const Color(0xFFFBB040)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Data point dots
    for (int i = 0; i < thisWeek.length; i++) {
      canvas.drawCircle(
        pt(i, thisWeek[i]),
        3,
        Paint()..color = const Color(0xFFFBB040),
      );
      if (i < lastWeek.length) {
        canvas.drawCircle(
          pt(i, lastWeek[i]),
          2,
          Paint()..color = const Color(0xFF555555),
        );
      }
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
