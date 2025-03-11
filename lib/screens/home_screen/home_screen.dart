import 'package:flutter/material.dart';
import 'package:flutter_otp_module/interfaceT.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Initial Button/Initial_buttons.dart';

class HomeScreen extends StatelessWidget {
  final String phoneNumber;

  const HomeScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100.0,
                ),
                SizedBox(height: 20.0),
                Text(
                  'Phone Verification successful!',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 10.0),
                Text(
                  'Your phone number is: $phoneNumber',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen1(
                            phoneNumber: phoneNumber,
                          )),
                ); // Navigate to the next screen or perform any action
              },
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              label: Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegCom extends StatelessWidget {
  final String restaurantName;
  final String inChargeName;
  final String email;
  final String address;
  final String district;
  final String state;
  final String phoneNumber;

  const RegCom({
    Key? key,
    required this.restaurantName,
    required this.inChargeName,
    required this.email,
    required this.address,
    required this.district,
    required this.state,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100.0,
                ),
                SizedBox(height: 20.0),
                Text(
                  'Registration Process Completed!',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(height: 10.0),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: ElevatedButton.icon(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isRegistered', true);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InterfaceT(
                      restaurantName: restaurantName,
                      inChargeName: inChargeName,
                      email: email,
                      address: address,
                      district: district,
                      state: state,
                      phoneNumber: phoneNumber,
                      foodDescriptions: [],
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              label: Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
