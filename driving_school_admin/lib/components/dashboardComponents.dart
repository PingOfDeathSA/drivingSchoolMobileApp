import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

Widget getPaidUsers() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('packageOrders')
        .where('paid', isEqualTo: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox.shrink();
      final paidCount = snapshot.data!.docs.length;
      if (paidCount == 0)
        return Container(
          child: Text(
            'No Paid Orders',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.01,
              color: greenColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.shopping_cart,
            size: MediaQuery.of(context).size.width * 0.04,
            color: Colors.amber,
          ),
          Text(
            paidCount == 1 ? '$paidCount Paid Order' : '$paidCount Paid Orders',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.01,
              color: greenColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    },
  );
}

Widget getallusers() {
  return StreamBuilder<QuerySnapshot>(
    stream:
        FirebaseFirestore.instance.collection('learnersProfile').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox.shrink();
      final totalUsers = snapshot.data!.docs.length;
      if (totalUsers == 0)
        return Container(
          child: Text('No Users',
              style: TextStyle(
                fontSize: 20,
                color: greenColor,
                fontWeight: FontWeight.bold,
              )),
        );
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.person,
            size: MediaQuery.of(context).size.width * 0.04,
            color: bluecolor,
          ),
          Text(
            totalUsers == 1 ? '$totalUsers User' : '$totalUsers Users',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.01,
              color: greenColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    },
  );
}

Widget getallMissed() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('bookedLessons')
        .where('status', isEqualTo: 'missed')
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox.shrink();
      final totalUsers = snapshot.data!.docs.length;
      if (totalUsers == 0)
        return Container(
          child: Text('No Missed Lessons',
              style: TextStyle(
                fontSize: 20,
                color: greenColor,
                fontWeight: FontWeight.bold,
              )),
        );
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.cancel_outlined,
            size: MediaQuery.of(context).size.width * 0.04,
            color: redcolor,
          ),
          Text(
            totalUsers == 1
                ? '$totalUsers Missed Lesson'
                : '$totalUsers Missed Lessons',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.01,
              color: greenColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    },
  );
}

Widget getallAllCompletedlessons() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('bookedLessons')
        .where('status', isEqualTo: 'completed')
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const SizedBox.shrink();
      final totalUsers = snapshot.data!.docs.length;
      if (totalUsers == 0)
        return Container(
          child: Text('No completed Lessons',
              style: TextStyle(
                fontSize: 20,
                color: greenColor,
                fontWeight: FontWeight.bold,
              )),
        );
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.check_circle_outlined,
            size: MediaQuery.of(context).size.width * 0.04,
            color: greenColor,
          ),
          Text(
            totalUsers == 1
                ? '$totalUsers completed Lesson'
                : '$totalUsers completed Lessons',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.01,
              color: greenColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    },
  );
}
