import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stbbankapplication1/screens/login.dart';
import 'package:stbbankapplication1/screens/splash-screen.dart';

import 'firebase_options.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
);
  runApp( MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RapidBankBooking',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: //MapPage() 
      FutureBuilder(
        future: Future.delayed(Duration(seconds: 2)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Login();
          } else {
            return SplashScreen(
              onInitializationComplete: () {},
            );
          }
        },
      ),
    );
  }
}
