import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school_mobile_app/backend/utils.dart';
import 'package:driving_school_mobile_app/colors.dart';
import 'package:driving_school_mobile_app/pages/view_packages.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../backend/service.dart';
import 'package:intl/intl.dart';
import '../components/dashboardComponents.dart';
import '../components/orders_table.dart';

class Dashboardpage extends StatefulWidget {
  const Dashboardpage({super.key});

  @override
  State<Dashboardpage> createState() => _DashboardpageState();
}

class _DashboardpageState extends State<Dashboardpage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double width = size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: lightgray,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dashboard'),
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
                SizedBox(
                  height: 20,
                ),
                Wrap(
                  spacing: 10.0, // Space between items horizontally
                  runSpacing: 5.0, // Space between lines vertically
                  children: [
                    TopContainers(greenColor, getallusers(), Colors.white),
                    TopContainers(lightgray, getPaidUsers(), customblack),
                    TopContainers(customblack, getallMissed(), Colors.white),
                    TopContainers(
                        bluecolor, getallAllCompletedlessons(), Colors.white),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Wrap(
                  spacing: 10.0, // Space between items horizontally
                  runSpacing: 5.0, // Space between lines vertically
                  children: [
                    getUpComingLessons(
                        context, firestore, width < 900 ? width : width / 2),
                    getAllPackages(
                        context, firestore, width < 900 ? width : width / 4.3),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                getallOrders(context),
              ],
            ),
          ),
        ));
  }

  Widget TopContainers(customColor, Widget Customwiget, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: lightgray,
        border: Border.all(
          color: greenColor.withOpacity(0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      height: 150,
      width: MediaQuery.of(context).size.width / 5.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [Customwiget],
      ),
    );
  }
}
