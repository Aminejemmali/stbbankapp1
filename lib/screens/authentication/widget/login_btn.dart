import 'package:flutter/material.dart';

class SignInButton extends StatefulWidget {
  final VoidCallback onClick;
  const SignInButton({super.key, required this.onClick});

  @override
  State<SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<SignInButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
        onPressed: widget.onClick,
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(49, 33, 182, 202),
          backgroundColor: const Color.fromARGB(6, 18, 60, 177),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Connexion",
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 253, 250, 250),
          ),
        ),
      ),
    );
  }
}
