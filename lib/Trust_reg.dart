import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_otp_module/screens/home_screen/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Confirm_details.dart';

class TrustForm extends StatefulWidget {
  final String phoneNumber;

  const TrustForm({Key? key, required this.phoneNumber}) : super(key: key);
  @override
  _TrustFormState createState() => _TrustFormState();
}

class _TrustFormState extends State<TrustForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController orphanageNameController = TextEditingController();
  TextEditingController inChargeNameController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController registrationNumberController = TextEditingController();

  String countryValue = "";
  String stateValue = "";
  String cityValue = "";

  String selectedButton = ''; // State variable to track selected button
  bool isValidRegistrationNumber =
      true; // State variable to track registration number validity

  Future<void> autoFillFields(String registrationNumber) async {
    final csvData =
        await rootBundle.loadString('assets/orphanages357 details.csv');
    List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);

    for (var row in csvTable) {
      if (row.contains(registrationNumber)) {
        setState(() {
          orphanageNameController.text =
              row[5]; // Orphanage name is in the 5th column
          countryValue = row[7]; // Assuming Country is in the 7th column
          stateValue = row[8]; // Assuming State is in the 8th column
          cityValue = row[6]; // Assuming City is in the 6th column
          addressController.text =
              row[2]; // Assuming Address is in the 2nd column
        });
        break;
      }
    }
  }

  Future<bool> checkRegistrationNumberExists(String registrationNumber) async {
    final csvData =
        await rootBundle.loadString('assets/orphanages357 details.csv');
    List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);
    return csvTable.any((row) => row.contains(registrationNumber));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Orphanage Form',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: registrationNumberController,
                decoration: InputDecoration(
                  labelText: 'Orphanage Registration Number',
                  errorText: isValidRegistrationNumber
                      ? null
                      : 'Invalid registration number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the orphanage registration number';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    autoFillFields(value);
                  }
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: orphanageNameController,
                decoration: InputDecoration(labelText: 'Name of the Orphanage'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of the orphanage';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: inChargeNameController,
                decoration: InputDecoration(labelText: 'Name of the InCharge'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of the in-charge';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: emailAddressController,
                decoration: InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the email address';
                  }
                  // Regular expression pattern for email validation
                  String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                  RegExp regex = new RegExp(emailPattern);
                  if (!regex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: widget.phoneNumber.isNotEmpty
                    ? TextEditingController(text: widget.phoneNumber)
                    : null,
                enabled: false,
                decoration: InputDecoration(labelText: 'Your Phone Number'),
              ),
              SizedBox(height: 10),
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
              SizedBox(height: 10),
              CSCPicker(
                showStates: true,
                showCities: true,
                countryDropdownLabel:
                    countryValue.isNotEmpty ? countryValue : 'Country',
                stateDropdownLabel:
                    stateValue.isNotEmpty ? stateValue : 'State',
                cityDropdownLabel: cityValue.isNotEmpty ? cityValue : 'City',
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      countryValue.isNotEmpty &&
                      stateValue.isNotEmpty &&
                      cityValue.isNotEmpty) {
                    // Perform actions with the entered data
                    String registrationNumber =
                        registrationNumberController.text;

                    bool registrationNumberExists =
                        await checkRegistrationNumberExists(registrationNumber);

                    if (!registrationNumberExists) {
                      setState(() {
                        isValidRegistrationNumber = false;
                      });
                      return;
                    }

                    setState(() {
                      isValidRegistrationNumber = true;
                    });

                    String orphanageName = orphanageNameController.text;
                    String inChargeName = inChargeNameController.text;
                    String emailAddress = emailAddressController.text;
                    String address = addressController.text;
                    String phoneNumber = widget.phoneNumber;
                    DateTime currentDateTime = DateTime.now();

                    // Save the data to Firestore
                    try {
                      await FirebaseFirestore.instance
                          .collection('orphanage')
                          .add({
                        'OrphanageName': orphanageName,
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
                      await prefs.setString('restaurantName', orphanageName);
                      await prefs.setString('inChargeName', inChargeName);
                      await prefs.setString('email', emailAddress);
                      await prefs.setString('address', address);
                      await prefs.setString('district', cityValue);
                      await prefs.setString('state', stateValue);
                      await prefs.setString('phoneNumber', phoneNumber);
                      await prefs.setStringList('foodDescriptions', []);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Confdeta(
                            type: 'Orphanage',
                            name: orphanageName,
                            inCharge: inChargeName,
                            email: emailAddress,
                            address: address,
                            district: cityValue,
                            state: stateValue,
                            registrationNumber: registrationNumber,
                            phoneNumber: widget.phoneNumber,
                            onEdit: () {
                              Navigator.pop(
                                  context); // Go back to the form for editing
                            },
                            onNext: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegCom(
                                    email: emailAddress,
                                    restaurantName: orphanageName,
                                    inChargeName: inChargeName,
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
                      print('Error adding orphanage: $e');
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
}
