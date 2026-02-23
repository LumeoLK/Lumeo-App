import '../model/user.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(id: '', name: '', email: '', token: '',profilePicture: '');
  User get user => _user;

  void setUser(String user) {
    _user = User.fromJson(jsonDecode(user));
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }
}
