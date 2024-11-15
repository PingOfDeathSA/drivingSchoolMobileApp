import 'dart:math';

import 'package:driving_school_mobile_app/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'dashboardComponents.dart';

TextStyle style =
    TextStyle(fontFamily: 'Montserrat', fontSize: 15.0, color: Colors.white);
Widget getallOrders(BuildContext context) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.only(left: 40, right: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Orders Table',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Text('View All',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
              ],
            ),
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.only(left: 40, right: 40),
        color: customblack,
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 15,
              child: Text('Username', style: style),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 15,
              child: Text('Email', style: style),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 13,
              child: Text('Description', style: style),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 15,
              child: Text('Package Name', style: style),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 15,
              child: Text('Phone', style: style),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 15,
              child: Text('Price', style: style),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 15,
              child: Text('Paid', style: style),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 15,
              child: Text('Date', style: style),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 15,
              child: Text('Delete', style: style),
            ),
          ],
        ),
      ),
      // Add the table here

      StreamBuilder(
        stream: firestore
            .collection('packageOrders')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: customLoadingAnimation(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No orders available'),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot orders = snapshot.data!.docs[index];
              DateTime date = orders['date'].toDate();
              String formattedDate = DateFormat('d MMM yyyy').format(date);

              return Container(
                margin: EdgeInsets.only(bottom: 10, left: 40, right: 40),
                decoration: BoxDecoration(
                  color: lightgray,
                ),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  child: Text(orders['username'].toString()),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  child: Text(orders['email'].toString()),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 13,
                                  child: Text(orders['description'].toString()),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  child: Text(orders['name'].toString()),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  child: Text(orders['phone'].toString()),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  child: Text(orders['price'].toString()),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (orders['paid'] == true) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Payment Status'),
                                              content: Text(
                                                  'This order has been paid for do you want to mark it as not paid?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('No')),
                                                TextButton(
                                                    onPressed: () {
                                                      firestore
                                                          .collection(
                                                              'packageOrders')
                                                          .doc(orders.id)
                                                          .update(
                                                              {'paid': false});
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Yes')),
                                              ],
                                            );
                                          });
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                  'Payment Status Not Paid'),
                                              content: Text(
                                                  'Do you want to confirm payment for this order?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('No')),
                                                TextButton(
                                                    onPressed: () {
                                                      firestore
                                                          .collection(
                                                              'packageOrders')
                                                          .doc(orders.id)
                                                          .update(
                                                              {'paid': true});
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Yes')),
                                              ],
                                            );
                                          });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: orders['paid'] == true
                                            ? greenColor
                                            : redcolor,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    width:
                                        MediaQuery.of(context).size.width / 15,
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      orders['paid'] == true ? 'Yes' : 'No',
                                      style: style,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  child: Text(formattedDate),
                                ),
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width / 15,
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Delete Order'),
                                                content: Text(
                                                    'Are you sure you want to delete this order?'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('No')),
                                                  TextButton(
                                                      onPressed: () {
                                                        firestore
                                                            .collection(
                                                                'packageOrders')
                                                            .doc(orders.id)
                                                            .delete();
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Yes')),
                                                ],
                                              );
                                            });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            color: redcolor,
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      )
    ],
  );
}
