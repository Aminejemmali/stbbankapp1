import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stbbankapplication1/db/user_db.dart';
import 'package:stbbankapplication1/models/Agence.dart';
import 'package:stbbankapplication1/models/utilisateur.dart';
import 'package:stbbankapplication1/providers/agence_list.dart';
import 'package:stbbankapplication1/providers/current_user.dart';
import 'package:stbbankapplication1/providers/user_list.dart';
import 'package:stbbankapplication1/screens/authentication/login.dart';
import 'package:stbbankapplication1/screens/splash-screen.dart';
import 'package:stbbankapplication1/utils/get_agence_data.dart';
import 'package:stbbankapplication1/utils/navigate_based_on_role.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  Future<void> _fetchData() async {
    String? currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final userListProvider =
        Provider.of<UserListProvider>(context, listen: false);
    final currentUserProvider =
        Provider.of<CurrentUserProvider>(context, listen: false);
    final agencesProvider =
        Provider.of<AgenceListProvider>(context, listen: false);

    List<dynamic> data = await Future.wait([
      UserDB().getAllUsers(),
      UserDB().getUserById(currentUserId),
      readJson()
    ]);
    List<Utilisateur> userList = data[0] as List<Utilisateur>;
    Utilisateur? currentUser = data[1] as Utilisateur?;
    List<Agence> listAgence = data[2] as List<Agence>;
    print(currentUser);
    currentUserProvider.updateUser(currentUser!);

    userListProvider.updateList(userList);
    agencesProvider.updateList(listAgence);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Login();
    }
    String? currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder(
        future: Future.wait(
            [UserDB().getAllUsers(), UserDB().getUserById(currentUserId)]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashView();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Object?>? data = snapshot.data;
            if (snapshot.data?[1] == null) {
              FirebaseAuth.instance.signOut();
              return const Login();
            }
            List<Utilisateur> userList = data![0] as List<Utilisateur>;
            Utilisateur? currentUser = data[1] as Utilisateur?;

            return widgetByRole(currentUser!.role);
          }
        });
  }
}
