import 'package:fireprime/model/user.dart';
import 'package:flutter/material.dart';

class UserController with ChangeNotifier {
  User? _user;

  User? get user => _user;

  UserController();

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  String getUserName() {
    return _user!.name;
  }

  void addHouse(String name) {
    _user!.houses.add(name);
    notifyListeners();
  }
}
