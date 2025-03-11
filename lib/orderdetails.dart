import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final String restaurantName;

  const OrderDetailsPage({Key? key, required this.restaurantName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Donation Records'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('orderdetails')
            .doc(restaurantName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No order details available.'));
          }

          List<dynamic> orderDetails = snapshot.data!['descriptions'];

          return ListView.builder(
            itemCount: orderDetails.length,
            itemBuilder: (context, index) {
              final orderDetail = orderDetails[index];

              return Dismissible(
                key: Key(orderDetail['description']),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
                onDismissed: (direction) async {
                  final removedOrderDetail = orderDetails[index];

                  // Remove the item from Firestore
                  orderDetails.removeAt(index);
                  await _firestore
                      .collection('orderdetails')
                      .doc(restaurantName)
                      .update({
                    'descriptions': orderDetails,
                  });

                  // Show SnackBar with undo option
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order detail removed'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          // Add the removed item back to Firestore
                          orderDetails.insert(index, removedOrderDetail);
                          await _firestore
                              .collection('orderdetails')
                              .doc(restaurantName)
                              .update({
                            'descriptions': orderDetails,
                          });
                        },
                      ),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(orderDetail['description']),
                  subtitle: Text(orderDetail['dateTime']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
