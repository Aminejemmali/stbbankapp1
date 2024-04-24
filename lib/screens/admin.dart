// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class admin extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  admin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 252, 253),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 58, 107, 170),
        title: Text('Admin Dashboard'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDashboardButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'users');
                },
                icon: Icons.supervised_user_circle,
                label: 'Gérer les Utilisateurs',
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 20),
              _buildDashboardButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('NewUser');
                },
                icon: Icons.person_add,
                label: 'Ajouter un Utilisateur',
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: 20),
              _buildDashboardButton(
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.of(context).pushReplacementNamed('LoginScreen');
                },
                icon: Icons.logout,
                label: 'Déconnexion',
                color: Colors.red,
              ),
              // Ajouter d'autres fonctionnalités à gérer ici
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: color,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
