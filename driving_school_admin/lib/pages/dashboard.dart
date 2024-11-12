import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school_mobile_app/backend/utils.dart';
import 'package:driving_school_mobile_app/colors.dart';
import 'package:driving_school_mobile_app/pages/view_packages.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../backend/service.dart';
import 'package:intl/intl.dart';

class Dashboardpage extends StatefulWidget {
  const Dashboardpage({super.key});

  @override
  State<Dashboardpage> createState() => _DashboardpageState();
}

class _DashboardpageState extends State<Dashboardpage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Menu'),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: customblack,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'RN',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 10.0, // Space between items horizontally
                  runSpacing: 5.0, // Space between lines vertically
                  children: [
                    TopContainers(greenColor, 'Registered Users', Colors.white),
                    TopContainers(lightgray, 'Paid Users', customblack),
                    TopContainers(customblack, 'Passed Users', Colors.white),
                    TopContainers(bluecolor, 'Failed Users', Colors.white),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Wrap(
                  spacing: 10.0, // Space between items horizontally
                  runSpacing: 5.0, // Space between lines vertically
                  children: [
                    getUpComingLessons(context, firestore),
                    getAllPackages(context, firestore),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget TopContainers(customColor, String userType, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: customColor,
        borderRadius: BorderRadius.circular(30),
      ),
      height: 150,
      width: MediaQuery.of(context).size.width / 5.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            textAlign: TextAlign.center,
            userType,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
