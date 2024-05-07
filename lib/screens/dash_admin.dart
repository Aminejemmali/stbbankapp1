import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:badges/badges.dart' as BadgesPrefix;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stbbankapplication1/providers/current_user.dart';

import 'package:stbbankapplication1/screens/rendez-vous.dart';

import 'package:stbbankapplication1/screens/rendez-vous.dart';
import 'package:stbbankapplication1/services/auth/auth.dart';

class AdminDash extends StatefulWidget {
  const AdminDash({Key? key}) : super(key: key);

  @override
  _AdminDashState createState() => _AdminDashState();
}

class _AdminDashState extends State<AdminDash> {
  int _currentIndex = 0;

  final List<Widget> _screens = [RendezVous(), Placeholder()];
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(currentUser.currentuser!.nom),
        leading: GestureDetector(
            onTap: () async => await UserAuth().signOut(context),
            child: Icon(Icons.logout)),
        actions: [
          IconButton(
            icon: const BadgesPrefix.Badge(
              badgeContent: Text(
                "0",
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(Icons.notifications),
            ),
            onPressed: () {
              //Navigator.of(context).pushReplacementNamed('notificationsList');
            },
          )
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Liste des rendez-vous',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
