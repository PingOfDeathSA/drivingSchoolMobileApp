import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school_mobile_app/colors.dart';
import 'package:driving_school_mobile_app/navigator%20%20menu/nav.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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
      // Access the Firestore collections
      final packageOrdersCollection =
          FirebaseFirestore.instance.collection('packageOrders');
      final userLessonsCollection =
          FirebaseFirestore.instance.collection('bookedLessons');

      // Generate a unique reference ID
      String generateUniqueId() {
        var uuid = Uuid();
        return uuid.v4(); // Generates a unique UUID
      }

      // Query the user's profile document by email
      final QuerySnapshot learnersProfileSnapshot = await FirebaseFirestore
          .instance
          .collection('learnersProfile')
          .where('email', isEqualTo: widget.useremail)
          .get();

      if (learnersProfileSnapshot.docs.isNotEmpty) {
        final data =
            learnersProfileSnapshot.docs.first.data() as Map<String, dynamic>;

        // Create a unique reference for the package
        String uniqueReference = generateUniqueId();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavigationBarExample(
              useremail: widget.useremail,
              username: widget.username,
            ),
          ),
        );
        // Add the package order
        await packageOrdersCollection.doc(uniqueReference).set({
          'package_reference': uniqueReference,
          'name': widget.package['name'],
          'price': widget.package['price'],
          'description': widget.package['description'],
          'email': widget.useremail,
          'username': widget.username,
          'uid': widget.useremail,
          'paid': false,
          'phone': data['phone'],
          'date': DateTime.now(),
          'lessons': widget.package['number_of_lessons'],
        });

        // Batch to add lessons efficiently
        WriteBatch batch = FirebaseFirestore.instance.batch();

        for (var i = 0; i < widget.package['number_of_lessons']; i++) {
          String lessonId = generateUniqueId();
          final lessonDocRef = userLessonsCollection.doc(lessonId);
          final numberOfLessons = i + 1;
          batch.set(lessonDocRef, {
            'package_reference': uniqueReference,
            'course': widget.package['name'],
            'date': '',
            'duration': '1 hour',
            'email': widget.useremail,
            'instructor': 'Themba',
            'lesson_type': 'lesson type',
            'lesson_number': numberOfLessons.toString(),
            'location': 'null',
            'status': 'pending',
            'student': widget.username,
            'time': 'null',
          });
        }

        // Commit the batch
        await batch.commit();

        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Package order added successfully!')),
        );
      } else {
        print("Learner's profile not found.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Learner's profile not found.")),
        );
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
