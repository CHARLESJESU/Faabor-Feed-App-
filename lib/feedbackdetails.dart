import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedbackDetailPage extends StatefulWidget {
  final String restaurantName;

  const FeedbackDetailPage({Key? key, required this.restaurantName})
      : super(key: key);

  @override
  _FeedbackDetailPageState createState() => _FeedbackDetailPageState();
}

class _FeedbackDetailPageState extends State<FeedbackDetailPage> {
  final TextEditingController _feedbackController = TextEditingController();

  void _submitFeedback() async {
    String feedback = _feedbackController.text.trim();
    if (feedback.isNotEmpty) {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'restaurantName': widget.restaurantName,
        'feedback': feedback,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feedback submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your feedback'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe your feedback',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: SizedBox(
                  width: double.infinity, // Extend the width of the button
                  child: ElevatedButton(
                    onPressed: _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Background color
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0), // Increase padding for height
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18), // Text color and size
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
