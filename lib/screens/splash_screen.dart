import 'package:expense_tracker/screens/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    navigateToHomeScreen();
  }

  Future<void> navigateToHomeScreen() async {
    await Future.delayed(Duration(seconds: 3));

    if(mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.lightBlue.shade200, Colors.lightBlue.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
            )
          ),
          child: Center(
            child: Column(
              children: [
                Spacer(flex: 2,),
                Image.asset('assets/images/splash_screen_img.jpg'),
                Spacer(flex: 2,),
                Padding(padding: EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      Text('Expense Tracker',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      Text('Track your daily spending easily')
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
