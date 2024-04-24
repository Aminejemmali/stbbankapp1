import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';

import 'package:mailer/smtp_server.dart';
import 'package:stbbankapplication1/screens/login.dart';
import 'package:stbbankapplication1/screens/success_screen.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
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

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'role': _roleController.text.trim(),
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      });

      // Envoi de l'e-mail avec les informations de l'utilisateur
      await _sendWelcomeEmail(
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

  Future<void> _sendWelcomeEmail(
      String email, String password, String nom, String prenom) async {
    final smtpServer = gmail('houilinour@gmail.com', 'jhcb srfj lqva gmaq');

    final message = Message()
      ..from = Address('STB-email@gmail.com', 'RapidBankBooking')
      ..recipients.add(email)
      ..subject = 'Bienvenue sur RapidBankBooking'
      ..text = 'Bienvenue sur RapidBankBooking!\n\n'
          'Nom: $nom\n'
          'Prénom: $prenom\n'
          'Votre adresse e-mail: $email\n'
          'Votre mot de passe: $password\n\n'
          'Merci de vous être inscrit sur RapidBankBooking.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Error sending welcome email: $e');
      // Gérer les erreurs d'envoi d'e-mail ici
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
    _roleController.dispose();
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
                  'Bienvenue! Ravi de vous voir',
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
                _buildTextField(_roleController, 'Rôle'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    //primary: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Créer',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'serif',
                      fontWeight:
                          FontWeight.bold, // Example: Add bold font weight
                      color: const Color.fromARGB(255, 229, 235,
                          240), // Example: Set text color to blue
                      // You can add more styles based on your requirements
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
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
