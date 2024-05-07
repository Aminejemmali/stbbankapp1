import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stbbankapplication1/screens/authentication/login.dart';

class SplashScreen extends StatefulWidget {
  final void Function() onInitializationComplete;

  SplashScreen({Key? key, required this.onInitializationComplete})
      : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _imageOpacity;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    );

    // Use Tween to animate image opacity
    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Start the animation when the screen is built
    _controller.forward();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SplashView();
  }
}

class SplashView extends StatelessWidget {
  const SplashView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Image.asset(
              'img/logo_stb.png',
              height: 100,
            ),
            // ),
          const  SizedBox(height: 20),
            // FadeTransition(
            //opacity: _controller,
        const    Text(
              'RapidBankBooking',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Color.fromARGB(255, 3, 49, 87),
                fontSize: 25,
              ),
            ),
            // ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RapidBankBooking',
      home: FutureBuilder(
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

void main() {
  runApp(MyApp());
}
