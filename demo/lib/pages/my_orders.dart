import 'package:flutter/material.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => MyOrdersState();
}

final TextStyle myOrderNormalStyle = const TextStyle(
  color: Colors.white,
  fontSize: 15,

  fontWeight: FontWeight.w300,
);

class MyOrdersState extends State<MyOrders> {
  bool isClicked = false;
  String selectedBtn = "Delivered";

  Widget orderProgress() {
    switch (selectedBtn) {
      case "Delivered":
        return deliveredOrders();
      case "Processing":
        return inProgressOrders();
      case "Cancelled":
        return cancelledOrders();
      default:
        return SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Navbar')),
      backgroundColor: Colors.black,
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Orders",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
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
                        backgroundColor: isSelected
                            ? Colors.white
                            : Colors.black,
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
            orderProgress(),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget deliveredOrders() {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                "Order N.1947034",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("05-12-2025", style: myOrderNormalStyle),
            ],
          ),
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Row(
                  children: [
                    Text("Quantity: ", style: myOrderNormalStyle),
                    Text(
                      "3",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text("Total Amount: ", style: myOrderNormalStyle),
                    Text(
                      "112",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.attach_money, color: Colors.white, size: 25),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text("Details ", style: myOrderNormalStyle),
                ),

                Text(
                  "Delivered ",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 123, 252, 128),
                    fontSize: 20,

                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget inProgressOrders() {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                "Order N.1947034",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("05-12-2025", style: myOrderNormalStyle),
            ],
          ),
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Row(
                  children: [
                    Text("Quantity: ", style: myOrderNormalStyle),
                    Text(
                      "3",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text("Total Amount: ", style: myOrderNormalStyle),
                    Text(
                      "112",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.attach_money, color: Colors.white, size: 25),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text("Details ", style: myOrderNormalStyle),
                ),

                Text(
                  "In Progress ",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 123, 252, 128),
                    fontSize: 20,

                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget cancelledOrders() {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                "Order N.1947034",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("05-12-2025", style: myOrderNormalStyle),
            ],
          ),
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Row(
                  children: [
                    Text("Quantity: ", style: myOrderNormalStyle),
                    Text(
                      "3",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text("Total Amount: ", style: myOrderNormalStyle),
                    Text(
                      "112",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.attach_money, color: Colors.white, size: 25),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text("Details ", style: myOrderNormalStyle),
                ),

                Text(
                  "Cancelled ",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 123, 252, 128),
                    fontSize: 20,

                    fontWeight: FontWeight.w300,
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
