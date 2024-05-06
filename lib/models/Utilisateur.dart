import 'package:cloud_firestore/cloud_firestore.dart';

class Utilisateur {
  final String uid;
  String nom;
  String prenom;
  String role;

  Utilisateur(
      {required this.uid,
      required this.nom,
      required this.prenom,
      required this.role});

  factory Utilisateur.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Utilisateur(
      uid: doc.id,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      role: data['role'] ?? '',
    );
  }
}
