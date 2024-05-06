import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stbbankapplication1/providers/current_user.dart';
import 'package:stbbankapplication1/providers/user_list.dart';
import 'package:stbbankapplication1/screens/authentication/login.dart';
import 'package:stbbankapplication1/screens/splash-screen.dart';
import 'package:stbbankapplication1/wrapper.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserListProvider()),
        ChangeNotifierProvider(create: (_) => CurrentUserProvider())
      ],
      child: MaterialApp(
        title: 'RapidBankBooking',
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        home: //MapPage()
            FutureBuilder(
          future: Future.delayed(Duration(seconds: 2)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return FirebaseAuth.instance.currentUser == null
                  ? Login()
                  : Wrapper();
            } else {
              return SplashScreen(
                onInitializationComplete: () {},
              );
            }
          },
        ),
      ),
    );
  }
}
