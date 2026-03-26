import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/custom_request_provider.dart';
import '../providers/auth_provider.dart';
import '../model/custom_request.dart';
import 'proposal_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/login_required_dialog.dart';

class CustomRequestReviewPage extends ConsumerStatefulWidget {
  const CustomRequestReviewPage({super.key});

  @override
  ConsumerState<CustomRequestReviewPage> createState() =>
      _CustomRequestReviewPageState();
}

class _CustomRequestReviewPageState extends ConsumerState<CustomRequestReviewPage> {
  bool isProcessing = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _checkLoginStatus();
      if (_isLoggedIn) {
        ref.read(customRequestProvider.notifier).fetchMyRequests();
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    final user = ref.read(currentUserProvider);
    if (user != null && user.id.isNotEmpty) {
      if (mounted) setState(() => _isLoggedIn = true);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token') ?? '';
    if (token.isNotEmpty) {
      if (mounted) setState(() => _isLoggedIn = true);
      return;
    }

    if (mounted) setState(() => _isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F14),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long, color: Colors.grey, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Login to view your Custom Requests',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBB040),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => LoginRequiredDialog.show(context),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    final state = ref.watch(customRequestProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              const Text(
                "Custom Furniture",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// Tabs
              _buildTabs(),

              const SizedBox(height: 20),

              /// Request List
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.myRequests.isEmpty
                        ? const Center(
                            child: Text(
                              "No requests found",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.myRequests.length,
                            itemBuilder: (context, index) {
                              final request = state.myRequests[index];
                              // Filter by tab status (Simplified: all in processing for now unless logic added)
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildRequestCard(request),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _tab("Processing", true),
        const SizedBox(width: 20),
        _tab("Completed", false),
      ],
    );
  }

  Widget _tab(String text, bool value) {
    final selected = isProcessing == value;

    return GestureDetector(
      onTap: () => setState(() => isProcessing = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(CustomRequest request) {
    final dateStr =
        "${request.createdAt.day}-${request.createdAt.month}-${request.createdAt.year}";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// Budget
          Text(
            "Budget: \$${request.budget.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 15),

          /// Button
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RequestDetailPage(request: request),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFF5A623)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "View Proposals",
              style: TextStyle(color: Color(0xFFF5A623)),
            ),
          ),
        ],
      ),
    );
  }
}
