import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_otp_module/screens/home_screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../interfaceT.dart';
import '../login_screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  final String restaurantName;
  final String inChargeName;
  final String email;
  final String address;
  final String district;
  final String state;
  final String phoneNumber;
  final List<String> foodDescriptions;

  const SplashScreen({
    Key? key,
    required this.restaurantName,
    required this.inChargeName,
    required this.email,
    required this.address,
    required this.district,
    required this.state,
    required this.foodDescriptions,
    required this.phoneNumber,
  }) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  void _checkRegistrationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isRegistered = prefs.getBool('isRegistered') ?? false;

    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 800),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0, end: 1).animate(animation),
                child: child,
              ),
            );
          },
          pageBuilder: (_, __, ___) => isRegistered
              ? InterfaceT(
                  restaurantName: widget.restaurantName, // Load saved data here
                  inChargeName: widget.inChargeName,
                  email: widget.email,
                  address: widget.address,
                  district: widget.district,
                  state: widget.state,
                  phoneNumber: widget.phoneNumber,
                  foodDescriptions: widget.foodDescriptions,
                )
              : HomeScreen(phoneNumber: widget.phoneNumber),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/WhatsApp Image 2024-05-18 at 21.21.16_890788e2.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
