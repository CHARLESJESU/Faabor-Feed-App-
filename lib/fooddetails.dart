import 'package:flutter/material.dart';

class FoodDetailsPage extends StatefulWidget {
  final List<String> foodDescriptions;
  final Function(String description) onCancel;
  final String currentUser; // Identifier for the currently logged-in user

  const FoodDetailsPage({
    Key? key,
    required this.foodDescriptions,
    required this.onCancel,
    required this.currentUser,
  }) : super(key: key);

  @override
  _FoodDetailsPageState createState() => _FoodDetailsPageState();
}

class _FoodDetailsPageState extends State<FoodDetailsPage> {
  void _cancelFood(String description) async {
    final String? reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return CancelFoodDialog();
      },
    );

    if (reason != null) {
      setState(() {
        int index = widget.foodDescriptions.indexOf(description);
        if (index != -1) {
          widget.foodDescriptions.removeAt(index);
        }
      });
      widget.onCancel(description);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter food descriptions for the current user
    List<String> currentUserFoodDescriptions =
        widget.foodDescriptions.where((description) {
      final parts = description.split('|');
      // Assuming parts[0] contains the user identifier
      return parts.isNotEmpty && parts[0] == widget.currentUser;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cancel Your Order'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: currentUserFoodDescriptions.length,
        itemBuilder: (context, index) {
          final parts = currentUserFoodDescriptions[index].split('|');
          final description = parts[1];
          final dateTime = parts[1];

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                description.startsWith('Cancelled:')
                    ? description
                    : description,
                style: TextStyle(
                  color:
                      description.startsWith('Cancelled:') ? Colors.red : null,
                ),
              ),
              trailing: description.startsWith('Cancelled:')
                  ? null
                  : ElevatedButton(
                      onPressed: () =>
                          _cancelFood(currentUserFoodDescriptions[index]),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'Cancel Food',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class CancelFoodDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Cancel Food',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Food is not available'),
            onTap: () => Navigator.of(context).pop('Food is not available'),
          ),
          ListTile(
            title: Text('Food is delivered'),
            onTap: () => Navigator.of(context).pop('Food is delivered'),
          ),

        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
