import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school_mobile_app/colors.dart';
import 'package:flutter/material.dart';

import '../authentication/auth_service.dart';
import '../authentication/google_sign_in.dart';
import 'learsons.dart';

class my_orders extends StatefulWidget {
  final String username;
  final String useremail;
  const my_orders({super.key, required this.username, required this.useremail});

  @override
  State<my_orders> createState() => _my_ordersState();
}

class _my_ordersState extends State<my_orders> {
  final AuthService _authService = AuthService();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Don't show the leading button
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Menu'),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black, // Custom color for the container
                  borderRadius: BorderRadius.circular(50),
                ),
                child: GestureDetector(
                  onTap: () async {
                    // Show confirmation dialog
                    bool shouldSignOut = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Sign Out"),
                              content:
                                  Text("Are you sure you want to sign out?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context)
                                      .pop(false), // Cancel sign-out
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context)
                                      .pop(true), // Confirm sign-out
                                  child: Text("Yes"),
                                ),
                              ],
                            );
                          },
                        ) ??
                        false; // Default to false if dialog is dismissed

                    // If confirmed, sign out and navigate to the login screen
                    if (shouldSignOut) {
                      await _authService.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  },
                  child: Text(
                    widget.username.split(' ').map((e) => e[0]).take(2).join(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('packageOrders')
                .where('email', isEqualTo: 'ronaldnt8@gmail.com')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error loading lessons'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No lessons available'));
              }

              return Container(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final lesson = snapshot.data!.docs[index];
                    final description = lesson['description'] ?? 'No Title';
                    final price = lesson['price'] ?? 'No Date';
                    final packagename = lesson['name'] ?? 'No Time';
                    final lessons = lesson['lessons'] ?? 'No Location';

                    final paid = lesson['paid'] ?? 'No Paid';

                    return Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: lightgray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(packagename,
                              style: TextStyle(
                                  color: customblack,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            ' $description',
                            style:
                                TextStyle(color: customblack.withOpacity(0.7)),
                          ),
                          Text(
                            'Price: R$price',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Text('Paid: $paid'),
                              Column(
                                children: [
                                  paid == true
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BookingCalendar(
                                                      numberoflessons: lessons,
                                                  username: widget.username,
                                                  useremail: widget.useremail,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: redcolor,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            padding: EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                top: 3,
                                                bottom: 3),
                                            child: Text(
                                              'Book for a lesson',
                                              style: TextStyle(
                                                  color: lightgray,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('Alert'),
                                                    content: Text(
                                                        'Please confirm your payment before booking for a lesson'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text('Cancel'),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: customblack,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            padding: EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                top: 3,
                                                bottom: 3),
                                            child: Text(
                                              'Book for a lesson',
                                              style: TextStyle(
                                                  color: lightgray,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ));
  }
}
