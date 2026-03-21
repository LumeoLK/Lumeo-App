import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/order.dart';
import '../services/order_service.dart';

class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Filter orders by status for the My Orders tabs
  List<Order> byStatus(String status) {
    return orders.where((o) => o.status.toLowerCase() == status.toLowerCase()).toList();
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(const OrderState());

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('x-auth-token') ?? '';
  }

  Future<void> fetchMyOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _getToken();
      final orders = await OrderService.getMyOrders(token);
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<Order?> placeOrder({
    required Map<String, dynamic> shippingAddress,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _getToken();
      final order = await OrderService.placeOrder(
        token,
        shippingAddress: shippingAddress,
      );
      // Add the new order to the front of the list
      state = state.copyWith(
        orders: [order, ...state.orders],
        isLoading: false,
      );
      return order;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return null;
    }
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});
