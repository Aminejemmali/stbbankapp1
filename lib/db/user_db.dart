import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stbbankapplication1/models/utilisateur.dart';

class UserDB {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> addUser(Utilisateur user) async {
    try {
      await _usersCollection.doc(user.uid).set({
        'uid': user.uid,
        'nom': user.nom,
        'prenom': user.prenom,
        'role': user.role,
      });
    } catch (e) {
      print("Error adding user: $e");
    }
  }

  Future<void> updateUser(Utilisateur user) async {
    try {
      await _usersCollection.doc(user.uid).update({
        'uid': user.uid,
        'nom': user.nom,
        'prenom': user.prenom,
        'role': user.role,
      });
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  Future<List<Utilisateur>> getAllUsers() async {
    List<Utilisateur> usersList = [];
    try {
      QuerySnapshot querySnapshot = await _usersCollection.get();
      for (var doc in querySnapshot.docs) {
        usersList.add(Utilisateur.fromFirestore(doc));
      }
    } catch (e) {
      print("Error getting users: $e");
    }
    return usersList;
  }

  Future<Utilisateur?> getUserById(String userId) async {
    try {
      DocumentSnapshot docSnapshot = await _usersCollection.doc(userId).get();
      if (docSnapshot.exists) {
        return Utilisateur.fromFirestore(docSnapshot);
      } else {
        print('User with ID $userId does not exist');
      }
    } catch (e) {
      print("Error getting user by ID: $e");
    }
    return null;
  }
}
