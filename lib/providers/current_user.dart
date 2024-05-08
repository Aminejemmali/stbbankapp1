import 'package:flutter/material.dart';
import 'package:stbbankapplication1/models/utilisateur.dart';

class CurrentUserProvider extends ChangeNotifier {
  Utilisateur _currentuser =
      Utilisateur(uid: "uid", nom: "nom", prenom: "prenom", role: "role");
  Utilisateur get currentuser => _currentuser;
  void updateUser(Utilisateur user) {
    _currentuser = user;
    notifyListeners();
  }
}
