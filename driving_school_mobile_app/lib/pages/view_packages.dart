import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school_mobile_app/colors.dart';
import 'package:driving_school_mobile_app/navigator%20%20menu/nav.dart';
import 'package:flutter/material.dart';

class ViewPackages extends StatefulWidget {
  final Map<String, dynamic> package;
  final String username;
  final String useremail;

  const ViewPackages({
    super.key,
    required this.package,
    required this.username,
    required this.useremail,
  });

  @override
  State<ViewPackages> createState() => _ViewPackagesState();
}

class _ViewPackagesState extends State<ViewPackages> {
  void _showBuyNowModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Confirm Purchase',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                  'Do you want to buy "${widget.package['name']}" for ${widget.package['price']}?'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: _addPackageOrder,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: customblack,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(color: lightgray),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: lightgray,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: redcolor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addPackageOrder() async {
    try {
      // Access the Firestore collection for package orders
      final packageOrdersCollection =
          FirebaseFirestore.instance.collection('packageOrders');

      // Query the user's profile document by email
      try {
        final QuerySnapshot leanersProfileSnapshot = await FirebaseFirestore
            .instance
            .collection('learnersProfile')
            .where('email', isEqualTo: widget.useremail)
            .get();

        if (leanersProfileSnapshot.docs.isNotEmpty) {
          final data =
              leanersProfileSnapshot.docs.first.data() as Map<String, dynamic>;
          print(data[
              'phone']); // This will print the phone field from the document

          // Create a new document in packageOrders
          await packageOrdersCollection.doc().set({
            'name': widget.package['name'],
            'price': widget.package['price'],
            'description': widget.package['description'],
            'email': widget.useremail,
            'username': widget.username,
            'uid': widget.useremail,
            'paid': false,
            'phone': data['phone'],
          });

          // Show success message and navigate back to the home screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Package order added successfully!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavigationBarExample(
                useremail: widget.useremail,
                username: widget.username,
              ),
            ),
          );
        } else {
          print("Document does not exist");
        }
      } catch (e) {
        print("Error retrieving contacts: $e");
      }
    } catch (e) {
      print("Error saving order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: Could not add order. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Buy!'),
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: customblack,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                'RN', // Display initials
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(widget.package['name'].toString()),
              Text(widget.package['price'].toString()),
              Text(widget.package['description'].toString()),
              GestureDetector(
                onTap: _showBuyNowModal,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: customblack,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Buy Now',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
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
