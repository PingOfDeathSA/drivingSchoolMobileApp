import 'package:driving_school_mobile_app/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../navigator  menu/nav.dart';
import '../utils/utils.dart';

class ProgressPage extends StatelessWidget {
  final String username;
  final String useremail;

  const ProgressPage({
    Key? key,
    required this.username,
    required this.useremail,
  }) : super(key: key);
  // Fetch user lessons from Firebase Firestore
  Future<List<Map<String, dynamic>>> fetchUserLessons() async {
    try {
      // Fetch data from the 'userLessons' collection
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('bookedLessons').get();

      // Convert the data into a list of maps
      List<Map<String, dynamic>> lessons = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return lessons;
    } catch (e) {
      print('Error fetching lessons: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    List<LinearGaugeRange> generateRanges(
        List<Map<String, dynamic>> userLessons) {
      List<LinearGaugeRange> ranges = [];
      for (int i = 0; i < userLessons.length; i++) {
        ranges.add(
          LinearGaugeRange(
            midWidth: 70,
            edgeStyle: LinearEdgeStyle.bothCurve,
            rangeShapeType: LinearRangeShapeType.curve,
            startValue: i.toDouble(),
            endValue: (i + 1).toDouble(),
            color: userLessons[i]['status'] == 'pending'
                ? Colors.orange
                : userLessons[i]['status'] == 'missed'
                    ? redcolor
                    : greenColor,
            startWidth: 10,
            endWidth: 40,
            child: GestureDetector(
              onTap: () {
                if (userLessons[i]['status'] == 'completed') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // Assuming 'userLessons[i]['date']' is a String in ISO 8601 format
                      DateTime date = DateTime.parse(userLessons[i]['date']);
                      String formattedDate = DateFormat('dd MMMM yyyy')
                          .format(date); // Format the date
                      return AlertDialog(
                        title: Text('Lesson Completed'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('This lesson has already been completed.'),
                            Text('No further action is required.'),
                            Text(
                                'Date: $formattedDate'), // Show the formatted date
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                } else if (userLessons[i]['status'] == 'missed') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // Assuming 'userLessons[i]['date']' is a String in ISO 8601 format
                      DateTime date = DateTime.parse(userLessons[i]['date']);
                      String formattedDate = DateFormat('dd MMMM yyyy')
                          .format(date); // Format the date

                      return AlertDialog(
                        title: Text('Lesson Missed'),
                        content: Column(
                          mainAxisSize: MainAxisSize
                              .min, // To avoid overflow in the dialog
                          children: [
                            Text('This lesson has been missed.'),
                            Text('Please contact the instructor.'),
                            Text(
                                'Date: $formattedDate'), // Show the formatted date
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  _showBuyNowModal(
                    context,
                    // Use the context from the build method
                    userLessons[i]['date'].toString(),
                    userLessons[i]['time'].toString(),
                    userLessons[i]['status'].toString(),
                    userLessons[i]['instructor'].toString(),
                    userLessons[i]['course'].toString(),
                    userLessons[i]['duration'].toString(),
                    userLessons[i]['location'].toString(),
                    userLessons[i]['student'].toString(),
                    userLessons[i]['lesson_type'].toString(),
                    useremail,
                    userLessons[i]['package_reference'].toString(),
                    userLessons[i]['lesson_number'].toString(),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Center(
                  child: userLessons[i]['status'] == 'pending'
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              color: Colors.white,
                            ),
                            Text(
                              'Pend',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                      : userLessons[i]['status'] == 'missed'
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Miss',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Done',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ),
        );
      }
      return ranges;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson Progress'),
        backgroundColor: lightgray,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUserLessons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: customLoadingAnimation());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(child: Text('Error loading user lessons'));
          }

          List<Map<String, dynamic>> userLessons = snapshot.data!;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Lesson Progress',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SfLinearGauge(
                minorTicksPerInterval: 0,
                useRangeColorForAxis: true,
                animateAxis: true,
                axisTrackStyle: LinearAxisTrackStyle(thickness: 1),
                minimum: 0,
                maximum: userLessons.length.toDouble(),
                interval: 1,
                animationDuration: 1000,
                ranges: generateRanges(userLessons),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBuyNowModal(
    BuildContext context,
    String date,
    String time,
    String status,
    String instructor,
    String course,
    String duration,
    String location,
    String student,
    String lessonType,
    String useremail,
    String package_reference,
    String lesson_number,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 300, // Adjusted height
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lesson Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SelectableText(
                      textAlign: TextAlign.center,
                      'Status: $status',
                    ),
                    SelectableText(
                      textAlign: TextAlign.center,
                      date == ''
                          ? 'Please book a slot to get Date'
                          : 'Date: $date',
                      style: TextStyle(
                          color: date == '' ? redcolor : Colors.black),
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SelectableText(
                      textAlign: TextAlign.center,
                      time == 'null'
                          ? 'Please book a slot to get Time'
                          : 'Time: $time',
                      style: TextStyle(
                          color: time == 'null' ? redcolor : Colors.black),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SelectableText(
                      textAlign: TextAlign.center,
                      'Instructor: $instructor',
                    ),
                    SelectableText(
                      textAlign: TextAlign.center,
                      'Course: $course',
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SelectableText(
                      textAlign: TextAlign.center,
                      'Duration: $duration',
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SelectableText(
                      textAlign: TextAlign.center,
                      location == 'null'
                          ? 'Please book for a location'
                          : 'Location: $location',
                      style: TextStyle(
                          color: location == 'null' ? redcolor : Colors.black),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SelectableText(
                      textAlign: TextAlign.center,
                      'Student: $student',
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SelectableText(
                      textAlign: TextAlign.center,
                      'Lesson Type: Any',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () async {
                      try {
                        print('User email: ${useremail}'); // Debugging output
                        print(
                            'widget.package_reference: ${package_reference}'); // Debugging output

                        // Retrieve the document ID based on conditions (e.g., user email and package reference)
                        final querySnapshot = await FirebaseFirestore.instance
                            .collection('bookedLessons')
                            .where('email', isEqualTo: useremail)
                            .where('package_reference',
                                isEqualTo: package_reference)
                            .where('lesson_number', isEqualTo: lesson_number)
                            .get();

                        if (querySnapshot.docs.isNotEmpty) {
                          // Assuming the document exists, get its ID
                          final documentId = querySnapshot.docs.first.id;
                          // Update the document with new data
                          await FirebaseFirestore.instance
                              .collection('bookedLessons')
                              .doc(documentId)
                              .update({
                            'date': DateTime.now().toString(),
                            'status': 'completed',
                          });

                          // Show confirmation or perform further actions
                          print('Document updated successfully.');

                          // Refresh the page
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      BottomNavigationBarExample(
                                          username: username,
                                          useremail: useremail)));

                          // Optionally, show a success message to the user
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Lesson marked as completed!'),
                          ));
                        } else {
                          print('No matching document found to update.');
                        }
                      } catch (e) {
                        print('Error updating document: $e');
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: customblack,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Complete lesson',
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
}
