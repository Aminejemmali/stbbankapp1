import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Importez la bibliothèque Google Fonts
import 'package:stbbankapplication1/screens/login.dart';

class SuccessScreen extends StatefulWidget {
  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialiser le contrôleur d'animation
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    // Définir les animations
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.7, 1.0)),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.7)),
    );

    // Démarrer l'animation
    _controller.forward();

    // Ajouter une action pour revenir à l'écran de connexion après l'animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: child,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Félicitations, votre compte a été créé avec succès!',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
          child: _buildHappyEmoji(),
        ),
      ),
    );
  }

  Widget _buildHappyEmoji() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.yellow, // Couleur du fond de l'emoji
      ),
      child: Center(
        child: Text(
          '😊', // Utilisez l'emoji souhaité ici
          style: GoogleFonts.notoColorEmoji(fontSize: 30),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
