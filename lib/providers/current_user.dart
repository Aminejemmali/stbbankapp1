import 'package:flutter/material.dart';
import 'package:stbbankapplication1/models/utilisateur.dart';


class CurrentUserProvider extends ChangeNotifier {
  Utilisateur? currentuser;

  void updateUser(Utilisateur user) {
    currentuser = user;
    notifyListeners();
  }


  
}


