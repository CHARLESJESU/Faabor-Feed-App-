import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProvideFoodScreen extends StatefulWidget {
  final String orphanageName;
  final String email;
  final String address;
  final String district;
  final String state;
  final String phoneNumber;
  final String? foodDescription;
  final String? id;
  final Function(String, String, String, String, String, String, String)
      onDescriptionProvided;

  const ProvideFoodScreen({
    Key? key,
    required this.orphanageName,
    required this.email,
    required this.address,
    required this.district,
    required this.state,
    required this.phoneNumber,
    this.foodDescription,
    required this.onDescriptionProvided,
    this.id,
  }) : super(key: key);

  @override
  _ProvideFoodScreenState createState() => _ProvideFoodScreenState();
}

class _ProvideFoodScreenState extends State<ProvideFoodScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.foodDescription != null) {
      _controller.text = widget.foodDescription!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provide Food'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Please enter a detailed description below:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Provided Food List...',
                  errorText: _errorText,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final description = _controller.text;
                  if (description.isEmpty) {
                    setState(() {
                      _errorText = 'Description cannot be empty';
                    });
                  } else {
                    setState(() {
                      _errorText = null;
                    });
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text('Description: $description'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                final dateTime =
                                    DateFormat('yyyy-MM-dd hh:mm a')
                                        .format(DateTime.now());
                                widget.onDescriptionProvided(
                                  widget.orphanageName,
                                  description,
                                  dateTime,
                                  widget.address,
                                  widget.phoneNumber,
                                  widget.district,
                                  widget.state,
                                );
                                Navigator.of(context).pop(); // Close the dialog
                                Navigator.of(context)
                                    .pop(); // Go back to previous screen
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.green),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Food Available',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
