import 'package:driving_school_mobile_app/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressPage extends StatelessWidget {
  // Fetch user lessons from Firebase Firestore
  Future<List<Map<String, dynamic>>> fetchUserLessons() async {
    try {
      // Fetch data from the 'userLessons' collection
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('usersLessons').get();

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
                );
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
                              Icons.pending_actions,
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
            return Center(child: CircularProgressIndicator());
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
      String lessonType) {
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
                      'Date: $date',
                    ),
                    SelectableText(
                      textAlign: TextAlign.center,
                      'Time: $time',
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
                      'Location: $location',
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
                      'Lesson Type: $lessonType',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
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
}
