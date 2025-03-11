import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_module/screens/login_screen/login_screen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'feedbackdetails.dart';
import 'fooddetails.dart';
import 'gethelpdetails.dart';
import 'orderdetails.dart';
import 'providefood.dart';

class InterfaceT extends StatefulWidget {
  final String restaurantName;
  final String inChargeName;
  final String email;
  final String address;
  final String district;
  final String state;
  final String phoneNumber;
  final List<String> foodDescriptions;

  const InterfaceT({
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
  _InterfaceTState createState() => _InterfaceTState();
}

class _InterfaceTState extends State<InterfaceT> {
  List<String> foodDescriptions = [];
  Map<String, Color> profileColors = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String id = "";
  String orphanageNameController = "";
  File? _profileImage;
  String? address;
  String? district;
  String? phoneNumber;
  String? state;
  bool isOrphanage = false;

  // Inside _InterfaceTState
  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadFoodDescriptions();
    _loadProfileData();
    _startAutoRemoveTimer(); // Start auto-remove timer
  }

  Future<void> _refresh() async {
    await _loadFoodDescriptions();
  }

  void _loadProfileData() async {
    setState(() {
      profileColors[widget.restaurantName] =
          _getProfileColor(widget.restaurantName);
    });

    // Check if the restaurant name is in the orphanageNameController
    final csvData =
        await rootBundle.loadString('assets/orphanages357 details.csv');
    List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);

    setState(() {
      isOrphanage = csvTable.any((row) => row[5] == widget.restaurantName);
    });
  }

  Future<void> autoFillFields(String registrationNumber) async {
    final csvData =
        await rootBundle.loadString('assets/orphanages357 details.csv');
    List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);

    for (var row in csvTable) {
      if (row.contains(registrationNumber)) {
        setState(() {
          orphanageNameController =
              row[5]; // Orphanage name is in the 5th column
          // Assuming Address is in the 2nd column
        });
        break;
      }
    }
  }

// Update _loadFoodDescriptions method in _InterfaceTState
// Update _loadFoodDescriptions method in _InterfaceTState
  Future<void> _loadFoodDescriptions() async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('foodDescriptions')
          .doc("fooddetails")
          .get();

      if (snapshot.exists) {
        List<String> descriptions = List<String>.from(snapshot['descriptions']);
        setState(() {
          // Filter out canceled descriptions
          foodDescriptions = descriptions
              .where((desc) => !desc.startsWith('Cancelled:'))
              .toList();
        });
      } else {
        setState(() {
          foodDescriptions = widget.foodDescriptions;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        foodDescriptions = widget.foodDescriptions;
      });
    }
  }

  // Add a method to periodically check and remove expired food descriptions
  void _startAutoRemoveTimer() {
    Timer.periodic(Duration(minutes: 1), (timer) async {
      DateTime now = DateTime.now();

      setState(() {
        foodDescriptions.removeWhere((description) {
          final parts = description.split('|');
          if (parts.length < 8) return false;
          final expiryTime = DateTime.parse(parts[7]);
          return expiryTime.isBefore(now);
        });
      });

      await _saveFoodDescriptions();
    });
  }

  void addFoodDescription(
      String orphanageName,
      String description,
      String dateTime,
      String address,
      String phoneNumber,
      String district,
      String state) async {
    final DateTime now = DateTime.now();
    final expiryTime = now.add(Duration(hours: 2));
    setState(() {
      foodDescriptions.add(
          '$orphanageName|$description|$dateTime|$address|$phoneNumber|$district|$state|$expiryTime');
      this.address = address;
      this.phoneNumber = phoneNumber;
      this.district = district;
      this.state = state;
    });
    await _saveFoodDescriptions();
    await _saveOrderDetails(description, dateTime);
  }

// Update _saveOrderDetails method in _InterfaceTState
// Update _saveOrderDetails method in _InterfaceTState
  Future<void> _saveOrderDetails(String description, String dateTime) async {
    await _firestore.collection('orderdetails').doc(widget.restaurantName).set({
      'descriptions': FieldValue.arrayUnion([
        {
          'description': description,
          'dateTime': dateTime,
        }
      ])
    }, SetOptions(merge: true));
  }

  void removeFoodDescription(String description) async {
    setState(() {
      foodDescriptions.removeWhere((item) => item.split('|')[1] == description);
    });
    await _saveFoodDescriptions();
  }

  Future<void> _saveFoodDescriptions() async {
    await _firestore.collection('foodDescriptions').doc("fooddetails").set({
      'descriptions': foodDescriptions,
    });
  }

  Color _generateRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  Color _getProfileColor(String name) {
    return profileColors[name] ??= _generateRandomColor();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image');
    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _saveProfileImage(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profile_image', imagePath);
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      );

      if (croppedFile != null) {
        setState(() {
          _profileImage = File(croppedFile.path);
        });
        _saveProfileImage(croppedFile.path); // Save the image path
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Donated Foods",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'get_help') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GetHelpDetailsPage(),
                  ),
                );
              } else if (value == 'feedback') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackDetailPage(
                      restaurantName: widget.restaurantName,
                    ),
                  ),
                );
              } else if (value == 'log_out') {
                _showLogoutConfirmationDialog(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'get_help',
                  child: Row(
                    children: [
                      Icon(Icons.help, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Get Help'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'feedback',
                  child: Row(
                    children: [
                      Icon(Icons.feedback, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Feedback'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'log_out',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Log Out'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      drawer: Drawer(
        elevation: 16.0,
        child: ListView(
          shrinkWrap: true,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                widget.restaurantName,
                style: TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                widget.email,
                style: TextStyle(color: Colors.white),
              ),
              currentAccountPicture: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  backgroundColor: _getProfileColor(widget.restaurantName),
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? Text(
                          widget.restaurantName.isNotEmpty
                              ? widget.restaurantName[0].toUpperCase()
                              : '',
                          style: TextStyle(fontSize: 40.0, color: Colors.white),
                        )
                      : null,
                ),
              ),
              otherAccountsPictures: [
                IconButton(
                  icon: Icon(Icons.photo_camera, color: Colors.white),
                  onPressed: _pickImage,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    id = isOrphanage ? 'Orp' : 'Res',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            ..._buildDrawerOptions(context),
          ],
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: foodDescriptions.length,
                itemBuilder: (context, index) {
                  final parts = foodDescriptions[index].split('|');
                  if (parts.length < 7) {
                    // Skip rendering if the format is incorrect
                    return SizedBox.shrink();
                  }

                  final orphanageName = parts[0];
                  final description = parts[1];
                  final dateTime = parts[2];
                  final address = parts[3];
                  final phoneNumber = parts[4];
                  final district = parts[5];
                  final state = parts[6];

                  final inChargeName = widget.inChargeName.toUpperCase();

                  return Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: DescriptionButton(
                      inChargeName: inChargeName,
                      orphanageName: orphanageName,
                      description: description,
                      dateTime: dateTime,
                      state: state,
                      address: address,
                      profileColor: _getProfileColor(orphanageName),
                      district: district,
                      phoneNumber: phoneNumber,
                      id: id,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUserData() async {
    // Delete user data from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Delete user food descriptions from Firestore
    await _firestore
        .collection('foodDescriptions')
        .doc("fooddetails")
        .update({'descriptions': FieldValue.arrayRemove(foodDescriptions)});

    // Optionally, delete other user data from Firestore if needed
    await _firestore
        .collection('orderdetails')
        .doc(widget.restaurantName)
        .delete();
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text(
              'Are you sure you want to log out? All your data will be deleted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteUserData(); // Delete user data
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildDrawerOptions(BuildContext context) {
    return [
      _buildListTile(
        title: 'My Donation Records',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailsPage(restaurantName: widget.restaurantName),
            ),
          );
        },
      ),
      _buildDivider(),
      _buildListTile(
        title: 'Provide Food',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProvideFoodScreen(
              orphanageName: widget.restaurantName,
              email: widget.email,
              address: widget.address,
              phoneNumber: widget.phoneNumber,
              district: widget.district,
              state: widget.state,
              onDescriptionProvided: addFoodDescription,
            ),
          ),
        ),
      ),
      _buildDivider(),
      _buildListTile(
        title: 'Cancel Your Order',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailsPage(
              foodDescriptions: foodDescriptions,
              onCancel: removeFoodDescription,
              currentUser: widget.restaurantName,
            ),
          ),
        ),
      ),
    ];
  }

  ListTile _buildListTile(
      {required String title, required VoidCallback onTap}) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }

  Divider _buildDivider() => Divider(height: 1.0);
}

class DescriptionButton extends StatelessWidget {
  final String orphanageName;
  final String inChargeName;
  final String description;
  final String dateTime;
  final Color profileColor;
  final String address;
  final String state;
  final String district;
  final String phoneNumber;
  final String id;

  const DescriptionButton({
    Key? key,
    required this.orphanageName,
    required this.inChargeName,
    required this.description,
    required this.dateTime,
    required this.profileColor,
    required this.state,
    required this.district,
    required this.phoneNumber,
    required this.address,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String buttonText = description.length > 20
        ? '${description.substring(0, 20)} ....'
        : description;

    bool isCancelled = orphanageName.startsWith('Cancelled:');
    Color textColor = isCancelled ? Colors.red : Colors.black;

    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: () {
          _showFullDescription(context);
        },
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '($district) $orphanageName',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                  ),
                  Text(
                    dateTime,
                    style: TextStyle(fontSize: 12, color: textColor),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showContactDetails(context);
                    },
                    child: Text(
                      'Contact Details',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add a method to periodically check and remove expired descriptions

  void _showFullDescription(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Food Details'),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showContactDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Contact Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Address: $address'),
              Row(
                children: [
                  Expanded(child: Text('Phone: $phoneNumber')),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: phoneNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Phone number copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
              Text('District: $district'),
              Text('State: $state'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
