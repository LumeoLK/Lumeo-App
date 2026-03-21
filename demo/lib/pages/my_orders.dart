import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';
import '../model/order.dart' as order_model;

class MyOrders extends ConsumerStatefulWidget {
  const MyOrders({super.key});

  @override
  ConsumerState<MyOrders> createState() => MyOrdersState();
}

final TextStyle myOrderNormalStyle = const TextStyle(
  color: Colors.white,
  fontSize: 15,
  fontWeight: FontWeight.w300,
);

class MyOrdersState extends ConsumerState<MyOrders> {
  String selectedBtn = "Processing";

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(orderProvider.notifier).fetchMyOrders());
  }

  // Map tab names to backend status values
  List<order_model.Order> _getOrdersForTab(OrderState orderState) {
    switch (selectedBtn) {
      case "Delivered":
        return orderState.byStatus("delivered");
      case "Processing":
        // Show pending + processing + shipped all under "Processing"
        return orderState.orders.where((o) =>
          o.status == "pending" || o.status == "processing" || o.status == "shipped"
        ).toList();
      case "Cancelled":
        return orderState.byStatus("cancelled");
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Orders",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Tab buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ["Delivered", "Processing", "Cancelled"].map((
                orderStatus,
              ) {
                bool isSelected = selectedBtn == orderStatus;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 1),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedBtn = orderStatus;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isSelected ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        orderStatus,
                        style: isSelected
                            ? const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                              )
                            : myOrderNormalStyle,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Order list content
            Expanded(
              child: orderState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFFBB040)),
                    )
                  : orderState.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Something went wrong',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  orderState.error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => ref
                                    .read(orderProvider.notifier)
                                    .fetchMyOrders(),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFFBB040)),
                                child: const Text('Retry',
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                        )
                      : _buildOrderList(_getOrdersForTab(orderState)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<order_model.Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'No $selectedBtn orders',
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            '${orders.length} order(s) found',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(orders[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(order_model.Order order) {
    // Format date
    final dateStr = DateFormat('dd-MM-yyyy').format(order.createdAt);

    // Status color
    Color statusColor;
    switch (order.status) {
      case "delivered":
        statusColor = const Color.fromARGB(255, 123, 252, 128);
        break;
      case "cancelled":
        statusColor = Colors.redAccent;
        break;
      default:
        statusColor = const Color(0xFFFBB040); // amber for processing
    }

    // Status display text
    String statusText;
    switch (order.status) {
      case "pending":
        statusText = "Pending";
        break;
      case "processing":
        statusText = "Processing";
        break;
      case "shipped":
        statusText = "Shipped";
        break;
      case "delivered":
        statusText = "Delivered";
        break;
      case "cancelled":
        statusText = "Cancelled";
        break;
      default:
        statusText = order.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Order ID + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Order #${order.id.substring(order.id.length > 8 ? order.id.length - 8 : 0)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(dateStr, style: myOrderNormalStyle),
            ],
          ),
          const SizedBox(height: 16),

          // Quantity + Total
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("Quantity: ", style: myOrderNormalStyle),
                    Text(
                      "${order.totalQuantity}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text("Total: ", style: myOrderNormalStyle),
                    Text(
                      "\$.${order.totalAmount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Items preview (show product names)
          if (order.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  order.items
                      .map((item) =>
                          item.product?.title ?? 'Product')
                      .join(', '),
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Status badge
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
