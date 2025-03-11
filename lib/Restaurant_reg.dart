import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_module/screens/home_screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Confirm_details.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final String phoneNumber;

  const RestaurantDetailsScreen({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  _RestaurantDetailsScreenState createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController restaurantNameController = TextEditingController();
  TextEditingController inChargeNameController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String countryValue = "";
  String stateValue = "";
  String cityValue = "";

  @override
  void dispose() {
    restaurantNameController.dispose();
    inChargeNameController.dispose();
    emailAddressController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Food Provider\'s Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: restaurantNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: inChargeNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailAddressController,
                decoration: InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the email address';
                  }
                  if (!isEmailValid(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: widget.phoneNumber.isNotEmpty
                    ? TextEditingController(text: widget.phoneNumber)
                    : null,
                enabled: false,
                decoration: InputDecoration(labelText: 'Your Phone Number'),
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              CSCPicker(
                showStates: true,
                showCities: true,
                onCountryChanged: (value) {
                  setState(() {
                    countryValue = value;
                  });
                },
                onStateChanged: (value) {
                  setState(() {
                    stateValue = value ?? "";
                  });
                },
                onCityChanged: (value) {
                  setState(() {
                    cityValue = value ?? "";
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      countryValue.isNotEmpty &&
                      stateValue.isNotEmpty &&
                      cityValue.isNotEmpty) {
                    // Perform actions with the entered data
                    String restaurantName = restaurantNameController.text;
                    String inChargeName = inChargeNameController.text;
                    String emailAddress = emailAddressController.text;
                    String address = addressController.text;
                    String phoneNumber = widget.phoneNumber;
                    DateTime currentDateTime = DateTime.now();

                    // Store data in Firestore
                    try {
                      await FirebaseFirestore.instance
                          .collection('restaurants')
                          .add({
                        'restaurantName': restaurantName,
                        'inChargeName': inChargeName,
                        'emailAddress': emailAddress,
                        'phoneNumber': phoneNumber,
                        'address': address,
                        'country': countryValue,
                        'state': stateValue,
                        'city': cityValue,
                        'timestamp': currentDateTime,
                      });

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString('restaurantName', restaurantName);
                      await prefs.setString('inChargeName', inChargeName);
                      await prefs.setString('email', emailAddress);
                      await prefs.setString('address', address);
                      await prefs.setString('district', cityValue);
                      await prefs.setString('state', stateValue);
                      await prefs.setString('phoneNumber', phoneNumber);
                      await prefs.setStringList('foodDescriptions', []);

                      // Navigate to Confirm Details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Confdeta(
                            type: 'Restaurant',
                            name: restaurantName,
                            inCharge: inChargeName,
                            email: emailAddress,
                            address: address,
                            district: cityValue,
                            state: stateValue,
                            phoneNumber: widget.phoneNumber,
                            registrationNumber: null,
                            onEdit: () {
                              Navigator.pop(
                                  context); // Go back to the form for editing
                            },
                            onNext: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegCom(
                                    restaurantName: restaurantName,
                                    inChargeName: inChargeName,
                                    email: emailAddress,
                                    address: address,
                                    district: cityValue,
                                    state: stateValue,
                                    phoneNumber: widget.phoneNumber,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    } catch (e) {
                      // Handle error
                      print('Error adding restaurant: $e');
                    }
                  } else {
                    // Indicate the missing section by updating the state
                    setState(() {});
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isEmailValid(String email) {
    // Regular expression for email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
