import 'package:flutter/material.dart';

class Confdeta extends StatelessWidget {
  final String type;
  final String name;
  final String inCharge;
  final String phoneNumber;
  final String email;
  final String address;
  final String district;
  final String state;
  final String? registrationNumber;
  final String? description;
  final String? trustType;
  final String? authorized;
  final VoidCallback onEdit;
  final VoidCallback onNext;

  Confdeta({
    required this.type,
    required this.name,
    required this.inCharge,
    required this.email,
    required this.address,
    required this.district,
    required this.phoneNumber,
    required this.state,
    this.registrationNumber,
    this.description,
    this.trustType,
    this.authorized,
    required this.onEdit,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$type Registration Complete'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$type Name: $name', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('In Charge: $inCharge', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Email: $email', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Address: $address', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('District: $district', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('State: $state', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            if (registrationNumber != null) ...[
              Text('Registration Number: $registrationNumber',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
            ],
            if (description != null) ...[
              Text('Description: $description', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
            ],
            if (trustType != null) ...[
              Text('Trust Type: $trustType', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
            ],
            if (authorized != null) ...[
              Text('Government Authorized: $authorized',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
            ],
            Text('Phone No: $phoneNumber', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onEdit,
                  child: Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: onNext,
                  child: Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
