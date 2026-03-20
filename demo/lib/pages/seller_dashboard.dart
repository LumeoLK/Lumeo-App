import '../services/seller_dashboard_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  final SellerDashboardService _dashboardService = const SellerDashboardService();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _dashboard = const {};

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

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

  Map<String, dynamic> get _profile => _asMap(_dashboard['profile']);
  Map<String, dynamic> get _summary => _asMap(_dashboard['summary']);
  Map<String, dynamic> get _performance => _asMap(_dashboard['performance']);
  List<Map<String, dynamic>> get _activeListings =>
      _asMapList(_dashboard['activeListings']);
  List<Map<String, dynamic>> get _newOrders =>
      _asMapList(_dashboard['newOrders']);

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((key, item) => MapEntry('$key', item));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text('Seller Dashboard'),
        actions: [
          IconButton(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: const Color(0xFFFBB040),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 220),
          Center(
            child: CircularProgressIndicator(color: Color(0xFFFBB040)),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          const Icon(
            Icons.storefront_outlined,
            color: Color(0xFFFBB040),
            size: 60,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to load dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadDashboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFBB040),
              foregroundColor: Colors.black,
            ),
            child: const Text('Try again'),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileCard(),
        const SizedBox(height: 16),
        _buildSummaryCard(),
        const SizedBox(height: 16),
        _buildPerformanceCard(),
        const SizedBox(height: 16),
        _buildListingsSection(),
        const SizedBox(height: 16),
        _buildOrdersSection(),
      ],
    );
  }

  Widget _buildProfileCard() {
    final logo = _text(_profile['logo']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF2D2D2D),
            backgroundImage: logo.isNotEmpty ? NetworkImage(logo) : null,
            child: logo.isEmpty
                ? const Icon(
                    Icons.storefront,
                    color: Color(0xFFFBB040),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(_profile['displayName'], fallback: 'Seller profile'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _text(_profile['shopName'], fallback: 'Shop name unavailable'),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _text(_profile['handle'], fallback: '@seller'),
                  style: const TextStyle(
                    color: Color(0xFFFBB040),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(
            'Earnings this week',
            _text(_summary['earningsThisWeekFormatted'], fallback: '0'),
          ),
          _infoRow(
            'Active listings',
            _text(_summary['activeListings'], fallback: '0'),
          ),
          _infoRow(
            'Average rating',
            _text(_summary['averageRating'], fallback: '0'),
          ),
          _infoRow(
            'Total revenue',
            _text(_summary['totalRevenueFormatted'], fallback: '0'),
          ),
          _infoRow(
            'Total orders',
            _text(_summary['totalOrders'], fallback: '0'),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    final days = _asStringList(_performance['days']);
    final thisWeek = _asStringList(_performance['thisWeek']);
    final lastWeek = _asStringList(_performance['lastWeek']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (days.isEmpty)
            const Text(
              'No performance data yet.',
              style: TextStyle(color: Colors.grey),
            )
          else
            Column(
              children: List.generate(days.length, (index) {
                final day = days[index];
                final current = index < thisWeek.length ? thisWeek[index] : '0';
                final previous = index < lastWeek.length ? lastWeek[index] : '0';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          day,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'This week: $current   Last week: $previous',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildListingsSection() {
    return _sectionCard(
      title: 'Active Listings',
      child: _activeListings.isEmpty
          ? const Text(
              'No active listings found.',
              style: TextStyle(color: Colors.grey),
            )
          : Column(
              children: _activeListings
                  .map((item) => _listingTile(item))
                  .toList(),
            ),
    );
  }

  Widget _buildOrdersSection() {
    return _sectionCard(
      title: 'New Orders',
      child: _newOrders.isEmpty
          ? const Text(
              'No new orders found.',
              style: TextStyle(color: Colors.grey),
            )
          : Column(
              children: _newOrders.map((item) => _orderTile(item)).toList(),
            ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _listingTile(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _thumbnail(_text(item['image'])),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(item['name'], fallback: 'Untitled product'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Price: ${_text(item['formattedPrice'], fallback: _text(item['price'], fallback: '0'))}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stock: ${_text(item['stock'], fallback: '0')}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderTile(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _thumbnail(_text(item['image'])),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(item['name'], fallback: 'Order item'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _text(item['orderNumber'], fallback: 'Order'),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${_text(item['formattedTotalPrice'], fallback: _text(item['formattedPrice'], fallback: '0'))}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbnail(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.chair, color: Color(0xFFFBB040)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chair, color: Color(0xFFFBB040)),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
