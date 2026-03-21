import 'package:flutter/material.dart';
import 'seller_verification_page.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Title
            const Text(
              "Terms and Conditions",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Scrollable Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          "1. Seller Responsibilities",
                          [
                            "Provide accurate product details and AR models.",
                            "Reply to buyers on time.",
                            "Maintain professional communication.",
                          ],
                        ),
                        _buildSection(
                          "2. Product Quality",
                          [
                            "Products must match photos, descriptions, and AR previews.",
                            "No misleading info or fake listings.",
                            "Update details if materials, size, or availability change.",
                          ],
                        ),
                        _buildSection(
                          "3. Custom Requests",
                          [
                            "Respond within 48 hours.",
                            "Give clear, realistic quotes (price + timeline).",
                            "Deliver exactly what was agreed.",
                          ],
                        ),
                        _buildSection(
                          "4. AR Model Accuracy",
                          [
                            "AR models must match real product size, color, and finish.",
                            "Update AR files if product design changes.",
                          ],
                        ),
                        _buildSection(
                          "5. Payouts",
                          [
                            "Payouts are processed weekly.",
                          ],
                        ),
                        _buildSection(
                          "6. Shipping & Delivery",
                          [
                            "Ship or deliver on time.",
                            "Inform the buyer if delays occur.",
                          ],
                        ),
                        _buildSection(
                          "7. Policy Violations",
                          [
                            "May result in warnings, listing removal, payment holds, or account suspension.",
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Agreement
                        const Text(
                          "Agreement",
                          style: TextStyle(
                            color: Color(0xFFE09D3B),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "By registering, you agree to follow all seller rules and maintain quality standards.",
                          style: TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 20),

                        // Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: isAccepted,
                              onChanged: (value) {
                                setState(() {
                                  isAccepted = value!;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                "I agree to all terms and conditions",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isAccepted ? Color(0xFFE09D3B) : Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: isAccepted
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SellerVerificationPage(),
                                      ),
                                    );
                                  }
                                : null,
                            child: const Text(
                              "ACCEPT & CONTINUE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE09D3B),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                "• $point",
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}