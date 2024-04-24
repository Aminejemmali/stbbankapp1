// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stbbankapplication1/screens/admin.dart';
import 'package:stbbankapplication1/screens/login.dart';
import 'package:stbbankapplication1/screens/splash-screen.dart';
import 'package:stbbankapplication1/screens/user.dart';

class Auth extends StatelessWidget {
  const Auth({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(
        onInitializationComplete: () {
          checkAuthenticationState(context);
        },
      ),
    );
  }

  void checkAuthenticationState(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        navigateToNextScreen(user, context);
      } else {
        navigateToLoginScreen(context);
      }
    });
  }

  void navigateToNextScreen(User user, BuildContext context) {
    FirebaseFirestore.instance.collection('users').doc(user.uid).get().then(
      (userSnapshot) {
        if (userSnapshot.exists) {
          final userData = userSnapshot.data();
          final userRole = userData?['role'] as String?;

          if (userRole != null) {
            navigateBasedOnRole(userRole, context);
          } else {
            print('Error: User role not available');
          }
        } else {
          print('Error: User data not available');
        }
      },
    );
  }

  void navigateBasedOnRole(String userRole, BuildContext context) {
    if (userRole == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => admin()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserScreen()),
      );
    }
  }

  void navigateToLoginScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }
}
