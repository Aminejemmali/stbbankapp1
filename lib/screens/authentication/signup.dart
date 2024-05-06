import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stbbankapplication1/screens/authentication/login.dart';
import 'package:stbbankapplication1/screens/success_screen.dart';
import 'package:stbbankapplication1/services/mail/send_email.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();

  Future<void> _createAccount() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid;
      String userRole = 'user';

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'role': userRole,
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      });

      // Envoi de l'e-mail avec les informations de l'utilisateur
      await sendWelcomeEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nomController.text.trim(),
        _prenomController.text.trim(),
      );

      // Naviguer vers l'écran de succès après la création réussie du compte
      _navigateToSuccessScreen();
    } on FirebaseAuthException catch (e) {
      print('Error creating user: $e');
      // Gérer les erreurs d'authentification ici
    }
  }



  void _navigateToSuccessScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SuccessScreen()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Inscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'img/stb.png',
                  width: 200,
                  height: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bienvenue! Ravi de vous voir!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildTextField(_nomController, 'Nom'),
                const SizedBox(height: 12),
                _buildTextField(_prenomController, 'Prénom'),
                const SizedBox(height: 12),
                _buildTextField(_emailController, 'Email'),
                const SizedBox(height: 12),
                _buildTextField(_passwordController, 'Mot de passe',
                    isPassword: true),
                const SizedBox(height: 12),
                _buildSignInButton(),
                const SizedBox(height: 20),
        
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      decoration: BoxDecoration(
        gradient:const LinearGradient(
          colors: [
            Colors.white,
            Colors.lightBlue,
            Color.fromARGB(255, 8, 57, 143),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: _createAccount,
        style: ElevatedButton.styleFrom(
          foregroundColor: Color.fromARGB(49, 33, 182, 202), backgroundColor: Color.fromARGB(6, 18, 60, 177),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "valider",
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 253, 250, 250),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
          ),
        ),
      ),
    );
  }
}
