import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/custom_request.dart';
import '../model/bid.dart';
import '../providers/custom_request_provider.dart';

class RequestDetailPage extends ConsumerStatefulWidget {
  final CustomRequest request;
  const RequestDetailPage({super.key, required this.request});

  @override
  ConsumerState<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends ConsumerState<RequestDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(customRequestProvider.notifier).fetchBidsForRequest(widget.request.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customRequestProvider);
    final bids = state.bidsByRequest[widget.request.id] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(
                widget.request.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "${bids.length} proposals received for this request",
                style: const TextStyle(color: Colors.white54),
              ),

              const SizedBox(height: 20),

              /// List
              Expanded(
                child: bids.isEmpty
                    ? const Center(
                        child: Text(
                          "No proposals yet",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: bids.length,
                        itemBuilder: (context, index) {
                          return _proposalCard(bids[index]);
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _proposalCard(Bid bid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Name + Price
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white12,
                backgroundImage: bid.sellerLogo.isNotEmpty ? NetworkImage(bid.sellerLogo) : null,
                child: bid.sellerLogo.isEmpty ? const Icon(Icons.person, color: Color(0xFFF5A623)) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(bid.sellerName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
              Text("\$${bid.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            bid.message,
            style: const TextStyle(color: Colors.white70),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            "Estimated days: ${bid.estimatedDays}",
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),

          const SizedBox(height: 15),

          /// Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Chat logic
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF5A623)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Chat",
                    style: TextStyle(color: Color(0xFFF5A623)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // View bid details/Accept logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Accept",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}