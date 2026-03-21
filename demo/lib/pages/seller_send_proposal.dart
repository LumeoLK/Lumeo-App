import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'seller_upload_success.dart';

const bgColor = Color(0xFF000000);
const cardColor = Color(0xFF1a1a1a);
const kOrange = Color(0xFFfbb040);
const textColor = Colors.white;
const hintText = Color(0xFF888888);

void main() => runApp(const MaterialApp(home: SendProposalPage(), debugShowCheckedModeBanner: false));

class SendProposalPage extends StatefulWidget {
  const SendProposalPage({super.key});
  @override
  State<SendProposalPage> createState() => _SendProposalPageState();
}

class _SendProposalPageState extends State<SendProposalPage> {
  int _navIndex = 4;

  final _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Overview'),
    BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Listings'),
    BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
    BottomNavigationBarItem(icon: Icon(Icons.view_in_ar), label: 'Blueprint 3D'),
    BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Custom'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: const SendProposalBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardColor,
        selectedItemColor: kOrange,
        unselectedItemColor: hintText,
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: _navItems,
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: bgColor,
        leading: const BackButton(color: textColor),
        title: const Column(
          children: [
            Text('Send Proposal',
                style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Reply to :',
                style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
            Text('Need Custom Wooden Bed Frame — Namal P.',
                style: TextStyle(color: hintText, fontSize: 13)),
          ],
        ),
        centerTitle: true,
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.notifications_none, color: textColor)),
        ],
      );
}

class SendProposalBody extends StatefulWidget {
  const SendProposalBody({super.key});
  @override
  State<SendProposalBody> createState() => _SendProposalBodyState();
}

class _SendProposalBodyState extends State<SendProposalBody> {

  //stores the selected images
  final List<File?> _attachments = [null, null, null];

  //opens gallery and save selected image
  Future<void> _pickAttachment(int index) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _attachments[index] = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 12),

          // your price field
          const Text('Your Price ( LKR )',
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _inputField(hint: ''),
          const SizedBox(height: 20),

          // delivery time field + chat icon
          const Text('Delivery Time ( Days )',
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _inputField(hint: '')),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: kOrange, shape: BoxShape.circle),
                child: const Icon(Icons.chat_bubble_outline, color: Colors.black, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // proposal message field
          const Text('Proposal Message',
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            maxLines: 6,
            style: const TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Write a personalized message outlining\nscope, materials, and timeline...',
              hintStyle: const TextStyle(color: hintText, fontSize: 13),
              filled: true,
              fillColor: cardColor,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // attachments section
          const Text('Attachments',
              style: TextStyle(color: kOrange, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Attach images / blueprints / 3D (.glb)',
              style: TextStyle(color: hintText, fontSize: 13)),
          const SizedBox(height: 12),

          // attachment boxes
          Row(
            children: List.generate(3, (i) => Expanded(
              child: GestureDetector(
                onTap: () => _pickAttachment(i),
                child: Container(
                  margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                  height: 80,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: hintText.withOpacity(0.3)),
                  ),
                  child: _attachments[i] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_attachments[i]!, fit: BoxFit.cover),
                        )
                      : const Icon(Icons.add, color: hintText, size: 28),
                ),
              ),
            )),
          ),
          const SizedBox(height: 36),

          // preview + submit buttons
          Row(
            children: [
              // preview button 
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kOrange, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('PREVIEW',
                      style: TextStyle(color: kOrange, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                ),
              ),
              const SizedBox(width: 12),

              // submit button 
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UploadSuccessPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('SUBMIT PROPOSAL',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // note below buttons
          const Center(
            child: Text(
              'You can edit or withdraw proposals until buyer accepts.',
              style: TextStyle(color: hintText, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // reusable input field
  Widget _inputField({required String hint, String? prefixText}) => TextField(
        style: const TextStyle(color: textColor, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: hintText),
          prefixText: prefixText,
          prefixStyle: const TextStyle(color: textColor, fontSize: 16),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      );
}