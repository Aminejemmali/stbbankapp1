import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:badges/badges.dart' as BadgesPrefix;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stbbankapplication1/screens/login.dart';
import 'package:stbbankapplication1/screens/rendez-vous.dart';

class NotificationData {
  final int id;
  final String title;
  final String body;

  NotificationData({required this.id, required this.title, required this.body});
}

class admin_dash extends StatefulWidget {
  const admin_dash({Key? key}) : super(key: key);

  @override
  _admin_dashState createState() => _admin_dashState();
}

class _admin_dashState extends State<admin_dash> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  int _notificationCount = 0;
  List<Map<String, dynamic>> data = [];
  List<dynamic> agenciesData = [];

  Future<void> _getCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      print('Current user: ${_currentUser!.displayName}');
    }
  }

  Future<void> _initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'basic_notifications',
          channelDescription: 'Test notification channel',
        ),
      ],
      debug: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Data length: ${data.length}");

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Mon Profil'),
        actions: [
          IconButton(
            icon: BadgesPrefix.Badge(
              badgeContent: Text(
                _notificationCount.toString(),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: w,
            height: h * 0.4,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("img/gestion5.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 20),
          _buildButton(context, text: "Liste des rendez-vous", onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => RendezVous()));
          }),
          SizedBox(height: 20),
          _buildButton(context, text: "Paramètres", onPressed: () {
            // Naviguer vers la page des paramètres
          }),
          SizedBox(height: 20),
          _buildButton(context, text: "Déconnexion", onPressed: () async {
            // Se déconnecter
            await FirebaseAuth.instance.signOut();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Login()));
          }),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Color.fromARGB(187, 243, 178, 92), backgroundColor: Color.fromARGB(218, 252, 162, 60),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: admin_dash(),
  ));
}
