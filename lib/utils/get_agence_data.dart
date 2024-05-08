import 'package:flutter/services.dart';
import 'package:stbbankapplication1/models/Agence.dart';
import 'dart:convert';

Future<List<Agence>> readJson() async {
  final String response = await rootBundle.loadString('assets/agence.json');
  final data = await json.decode(response);
  return (data["items"] as List<dynamic>)
      .map((e) => Agence.fromJson(e))
      .toList();
}
