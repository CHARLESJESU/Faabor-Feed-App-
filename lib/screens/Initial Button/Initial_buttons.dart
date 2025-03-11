import 'package:flutter/material.dart';

import '../../Restaurant_reg.dart';
import '../../Trust_reg.dart';

class HomeScreen1 extends StatelessWidget {
  final String phoneNumber;

  const HomeScreen1({Key? key, this.phoneNumber = '7676789986'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Welcome to FAABOR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        shadowColor: Colors.black45,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Image.asset(
                'assets/WhatsApp Image 2024-05-18 at 21.21.16_890788e2.png',
                height: screenHeight * 0.45,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 50),
              _buildButton(
                text: 'FOOD PROVIDER',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RestaurantDetailsScreen(phoneNumber: phoneNumber),
                  ),
                ),
                colors: [Colors.green, Colors.lightGreenAccent],
              ),
              SizedBox(height: 20),
              _buildButton(
                text: 'ORPHANAGE',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrustForm(phoneNumber: phoneNumber),
                  ),
                ),
                colors: [Colors.orange, Colors.deepOrangeAccent],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      {required String text,
      required VoidCallback onPressed,
      required List<Color> colors}) {
    return Container(
      width: 200,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center, // Ensures the text is centered
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
