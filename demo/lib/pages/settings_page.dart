import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'password_change_sheeet.dart';
import '../Constants.dart';
import '../widgets/secondary_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _fullNameController;
  late TextEditingController _dobController;
  DateTime? _selectedDob;
  bool _isEditMode = false;
  final bool _notificationsEnabled = true;
  final bool _darkModeEnabled = true;
  bool _isLoading = false;
  String? _userEmail;
  String? _userId;
  String _searchQuery = '';
  
  bool _matchesSearch(String input) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    return input.toLowerCase().contains(query);
  }

  @override
  void initState() {
    super.initState();
    print('[SettingsPage] Initializing Settings Page');
    _fullNameController = TextEditingController();
    _dobController = TextEditingController();
    _fetchUserDetails();
    print('[SettingsPage] Controllers initialized');
  }

  Future<void> _fetchUserDetails() async {
    print('[SettingsPage] Fetching user details from backend...');
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('x-auth-token') ?? '';

      if (token.isEmpty) {
        print('[SettingsPage] ERROR: No authentication token found');
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first')),
        );
        return;
      }

      print('[SettingsPage] Token found, making API request...');
      final response = await http.get(
        Uri.parse('${Constants.authUri}/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      print('[SettingsPage] API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        DateTime? parsedDob;

        if (user['dob'] != null && user['dob'].toString().isNotEmpty) {
          parsedDob = DateTime.tryParse(user['dob'].toString());
        }

        print('[SettingsPage] User data received:');
        print('[SettingsPage] - Name: ${user['name']}');
      
        setState(() {
          _fullNameController.text = user['name'] ?? '';
          _userEmail = user['email'] ?? '';
          _userId = user['id'] ?? '';
          _selectedDob = parsedDob;
          _dobController.text = parsedDob != null ? _formatDate(parsedDob) : '';
          _isLoading = false;
        });

        print('[SettingsPage] User details loaded successfully');
      } else {
        print('[SettingsPage] ERROR: Failed to fetch user - Status ${response.statusCode}');
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['msg'] ?? 'Failed to load user details');
      }
    } catch (e) {
      print('[SettingsPage] ERROR fetching user details: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    print('[SettingsPage] Disposing controllers');
    _fullNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _openPasswordSheet(BuildContext context) {
    print('[SettingsPage] Opening password change sheet');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PasswordChangeSheet(),
    );
  }

  void _saveSettings() {
    print('[SettingsPage] Save Settings button tapped');
    print('[SettingsPage] Full Name: ${_fullNameController.text}');
    print('[SettingsPage] Date of Birth: ${_dobController.text}');
    print('[SettingsPage] Notifications Enabled: $_notificationsEnabled');
    print('[SettingsPage] Dark Mode Enabled: $_darkModeEnabled');
    print('[SettingsPage] User ID: $_userId');
    print('[SettingsPage] User Email: $_userEmail');

    // Validate inputs
    if (_fullNameController.text.isEmpty) {
      print('[SettingsPage] ERROR: Full name is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full name cannot be empty')),
      );
      return;
    }

    print('[SettingsPage] Validation passed - saving settings...');
    setState(() {
      _isEditMode = false;
    });

    print('[SettingsPage] Settings saved successfully');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }

  void _toggleEditMode() {
    print('[SettingsPage] Toggling edit mode from $_isEditMode to ${!_isEditMode}');
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initialDate = _selectedDob ?? DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF5A623),
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A22),
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF1A1A22)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = _formatDate(picked);
      });
    }
  }

  void _logout() {
    print('[SettingsPage] Logout button tapped');
    print('[SettingsPage] User ID: $_userId');
    print('[SettingsPage] Clearing user session...');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A22),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('[SettingsPage] Logout cancelled');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              print('[SettingsPage] Logout confirmed - clearing tokens');
              _performLogout();
              Navigator.pop(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    print('[SettingsPage] Performing logout...');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('x-auth-token', '');
      await prefs.setString('userId', '');
      print('[SettingsPage] Tokens cleared successfully');
      
      if (mounted) {
        print('[SettingsPage] Navigating to login page');
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      print('[SettingsPage] Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[SettingsPage] Building UI - Loading: $_isLoading');
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F14),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF5A623)),
          ),
        ),
      );
    }

    print('[SettingsPage] Building UI');
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: SecondaryAppTopBar(
        searchHintText: 'Search settings',
        onSearchChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                /// Title
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                /// Personal Info Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Personal Information",
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    GestureDetector(
                      onTap: _toggleEditMode,
                      child: Text(
                        _isEditMode ? "Cancel" : "Edit",
                        style: const TextStyle(
                          color: Color(0xFFF5A623),
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),


                /// Editable Full Name
                if (_matchesSearch("full name") || _matchesSearch(_fullNameController.text))
                  _isEditMode
                      ? _buildEditableField("Full name", _fullNameController)
                      : _infoCard("Full name", _fullNameController.text),

                /// Editable DOB
                if (_matchesSearch("date of birth") || _matchesSearch("dob") || _matchesSearch(_dobController.text))
                  _isEditMode
                      ? _buildEditableField(
                          "Date of Birth",
                          _dobController,
                          hintText: "Tap to select date",
                          readOnly: true,
                          onTap: _pickDob,
                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.white54,
                            size: 20,
                          ),
                        )
                      : _infoCard(
                          "Date of Birth",
                          _dobController.text.isEmpty ? "Not set" : _dobController.text,
                        ),

                const SizedBox(height: 30),

                /// Password Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Password",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    GestureDetector(
                      onTap: () => _openPasswordSheet(context),
                      child: const Text(
                        "Change",
                        style: TextStyle(color: Color(0xFFF5A623)),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "*****",
                  style: TextStyle(color: Colors.white54),
                ),

                const SizedBox(height: 30),               

                /// Save Button (only in edit mode)
                if (_isEditMode)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5A623),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "SAVE CHANGES",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                if (_isEditMode) const SizedBox(height: 15),

               
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    String? hintText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white38),
          suffixIcon: suffixIcon,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF2A2A35),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF5A623)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF5A623)),
          ),
        ),
      ),
    );
  }

}