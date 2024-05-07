import 'package:flutter/material.dart';
import 'package:stbbankapplication1/db/user_db.dart';
import 'package:stbbankapplication1/models/utilisateur.dart';

class UserListProvider extends ChangeNotifier {
  List<Utilisateur> _users = [];

  List<Utilisateur> get users => _users;

  UserListProvider() {
    fetchUsers();
  }

  void updateList(List<Utilisateur> list) {
    _users = list;
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    try {
      List<Utilisateur> fetchedUsers = await UserDB().getAllUsers();
      _users = fetchedUsers;
    } catch (e) {
      
      print('Error fetching users: $e');
    }

    notifyListeners();
  }
}
