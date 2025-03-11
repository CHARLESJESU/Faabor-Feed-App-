import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Restaurant_reg.dart';
import 'interfaceT.dart';
import 'screens/home_screen/home_screen.dart';
import 'screens/otp_screen/otp_screen.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCfz2JhJw8iNB9ahTLQjBRj5gApV6HMkck',
        appId: '1:356479446244:android:cd515805b5087ab24a50f1',
        messagingSenderId: '356479446244',
        projectId: 'gitflutterpro',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool showInterfaceT = prefs.getBool('showInterfaceT') ?? false;
  String? restaurantName = prefs.getString('restaurantName');
  String? inChargeName = prefs.getString('inChargeName');
  String? email = prefs.getString('email');
  String? address = prefs.getString('address');
  String? district = prefs.getString('district');
  String? state = prefs.getString('state');
  String? phoneNumber = prefs.getString('phoneNumber');

  runApp(MyApp(
    showInterfaceT: showInterfaceT,
    restaurantName: restaurantName,
    inChargeName: inChargeName,
    email: email,
    address: address,
    district: district,
    state: state,
    phoneNumber: phoneNumber,
  ));
}

class MyApp extends StatelessWidget {
  final bool showInterfaceT;
  final String? restaurantName;
  final String? inChargeName;
  final String? email;
  final String? address;
  final String? district;
  final String? state;
  final String? phoneNumber;

  const MyApp({
    Key? key,
    required this.showInterfaceT,
    this.restaurantName,
    this.inChargeName,
    this.email,
    this.address,
    this.district,
    this.state,
    this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Faabor',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 253, 188, 51),
      ),
      home: showInterfaceT
          ? InterfaceT(
              restaurantName: restaurantName ?? '',
              inChargeName: inChargeName ?? '',
              email: email ?? '',
              address: address ?? '',
              district: district ?? '',
              state: state ?? '',
              phoneNumber: phoneNumber ?? '',
              foodDescriptions: [],
            )
          : SplashScreen(
              restaurantName: restaurantName ?? '',
              inChargeName: inChargeName ?? '',
              email: email ?? '',
              address: address ?? '',
              district: district ?? '',
              state: state ?? '',
              phoneNumber: phoneNumber ?? '',
              foodDescriptions: [],
            ),
      routes: <String, WidgetBuilder>{
       '/otpScreen': (BuildContext ctx) => OtpScreen(),
        '/homeScreen': (BuildContext ctx) => HomeScreen(
              phoneNumber: ModalRoute.of(ctx)?.settings.arguments as String,
            ),
        '/restaurantDetailsScreen': (BuildContext ctx) =>
            RestaurantDetailsScreen(
              phoneNumber: '', // Pass the phone number if needed
            ),
      },
    );
  }
}
