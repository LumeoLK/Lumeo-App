import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/message.dart';
import '../model/conversation.dart';
import '../Constants.dart';

class ChatService {
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('x-auth-token') ?? '';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Conversation> startConversation({
    required String sellerId,
    required String productId,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${Constants.chatUri}/conversations'),
      headers: headers,
      body: jsonEncode({
        'sellerId': sellerId,
        'productId': productId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Conversation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to start conversation: ${response.body}');
    }
  }

  Future<List<Conversation>> getConversations() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${Constants.chatUri}/conversations'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load conversations: ${response.body}');
    }
  }

  Future<List<Message>> getMessages(String conversationId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${Constants.chatUri}/messages/$conversationId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Message.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load messages: ${response.body}');
    }
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${Constants.chatUri}/messages'),
      headers: headers,
      body: jsonEncode({
        'conversationId': conversationId,
        'text': text,
      }),
    );

    if (response.statusCode == 201) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }
}