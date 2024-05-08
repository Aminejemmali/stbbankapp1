import 'package:flutter/material.dart';
import 'package:stbbankapplication1/models/Agence.dart';

class AgenceListProvider extends ChangeNotifier {
  List<Agence> _agences = [];
  List<Agence> get agences => _agences;
  void updateList(List<Agence> list) {
    _agences = list;
    notifyListeners();
  }
}
