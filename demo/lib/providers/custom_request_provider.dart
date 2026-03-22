import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/custom_request.dart';
import '../model/bid.dart';
import '../services/custom_request_service.dart';

class CustomRequestState {
  final List<CustomRequest> myRequests;
  final List<CustomRequest> marketplaceRequests;
  final Map<String, List<Bid>> bidsByRequest; // requestId -> list of bids
  final bool isLoading;
  final String? error;
 [CustomRequestProvider] Error: Exception: Failed to load my requests
  CustomRequestState({
    this.myRequests = const [],
    this.marketplaceRequests = const [],
    this.bidsByRequest = const {},
    this.isLoading = false,
    this.error,
  });

  CustomRequestState copyWith({
    List<CustomRequest>? myRequests,
    List<CustomRequest>? marketplaceRequests,
    Map<String, List<Bid>>? bidsByRequest,
    bool? isLoading,
    String? error,
  }) {
    return CustomRequestState(
      myRequests: myRequests ?? this.myRequests,
      marketplaceRequests: marketplaceRequests ?? this.marketplaceRequests,
      bidsByRequest: bidsByRequest ?? this.bidsByRequest,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CustomRequestNotifier extends StateNotifier<CustomRequestState> {
  CustomRequestNotifier() : super(CustomRequestState());

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('x-auth-token') ?? '';
  }

  Future<CustomRequestService> _getService() async {
    final token = await _getToken();
    return CustomRequestService(token: token);
  }

  // Fetch requests created by the user
  Future<void> fetchMyRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = await _getService();
      final requests = await service.getMyRequests();
      print('[CustomRequestProvider] Fetched ${requests.length} requests');
      state = state.copyWith(myRequests: requests, isLoading: false);
    } catch (e) {
      print('[CustomRequestProvider] Error: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Fetch proposals for a specific request
  Future<void> fetchBidsForRequest(String requestId) async {
    try {
      final service = await _getService();
      final bids = await service.getBidsForRequest(requestId);
      
      final updatedBids = Map<String, List<Bid>>.from(state.bidsByRequest);
      updatedBids[requestId] = bids;
      
      state = state.copyWith(bidsByRequest: updatedBids);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Create new request
  Future<bool> submitRequest({
    required String title,
    required String description,
    required double budget,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = await _getService();
      final newRequest = await service.createCustomRequest(
        title: title,
        description: description,
        budget: budget,
      );
      
      state = state.copyWith(
        myRequests: [newRequest, ...state.myRequests],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }
}

final customRequestProvider =
    StateNotifierProvider<CustomRequestNotifier, CustomRequestState>((ref) {
  return CustomRequestNotifier();
});
