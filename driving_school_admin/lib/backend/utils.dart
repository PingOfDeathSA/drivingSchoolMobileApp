import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school_mobile_app/colors.dart';
import 'package:driving_school_mobile_app/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../navigator  menu/nav.dart';

Widget getUpComingLessons(BuildContext context, FirebaseFirestore firestore) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(0),
    ),
    width: MediaQuery.of(context).size.width / 2.5,
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upcoming Lessons (Today + Next 3 Days)'),
            GestureDetector(
                onTap: () {
                  getAllMissedLessons(context, firestore);
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: lightgray,
                    border: Border.all(color: bluecolor),
                  ),
                  child: Text(
                    'View All Missed Lessons',
                    style: TextStyle(
                        color: bluecolor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10), // Optional styling
                  ),
                )),
          ],
        ),
        SizedBox(height: 10),
        StreamBuilder(
          stream: firestore.collection('bookedLessons').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // Define the current date and the end date (next 3 days)
            DateTime today = DateTime.now();
            DateTime endDate = today.add(Duration(days: 3));
            DateFormat dateFormat = DateFormat('yyyy-MM-dd');
            DateFormat displayFormat = DateFormat('dd MMM- yyyy');

            // Filter and sort documents within the specified date range
            List<DocumentSnapshot> upcomingLessons =
                snapshot.data!.docs.where((lesson) {
              String lessonDateStr = lesson['date'];
              DateTime lessonDate = dateFormat.parse(lessonDateStr);

              // Check if lesson date is within today and the next 3 days
              return lessonDate.isAfter(today.subtract(Duration(days: 1))) &&
                  lessonDate.isBefore(endDate.add(Duration(days: 1)));
            }).toList();

            // Sort lessons by date in ascending order (most recent first)
            upcomingLessons.sort((a, b) {
              DateTime dateA = dateFormat.parse(a['date']);
              DateTime dateB = dateFormat.parse(b['date']);
              return dateA.compareTo(dateB);
            });

            if (upcomingLessons.isEmpty) {
              return Center(
                  child: Text("No lessons for today or the next 3 days"));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: upcomingLessons.length,
              itemBuilder: (context, index) {
                DocumentSnapshot lesson = upcomingLessons[index];

                // Parse the date and format it as "13 Nov- 2024"
                DateTime lessonDate = dateFormat.parse(lesson['date']);
                String formattedDate = displayFormat.format(lessonDate);

                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: lightgray,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(lesson['student']),
                            Text(" will attend lesson ${lesson['lessons']}"),
                          ],
                        ),
                        Row(
                          children: [
                            Text("Location: ${lesson['location']}"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Date $formattedDate at ${lesson['time']}"),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${lesson['status'][0].toUpperCase()}${lesson['status'].substring(1)} at ${lesson['time']}",
                                ),
                                lesson['status'] == 'pending'
                                    ? Icon(
                                        Icons.pending_actions_outlined,
                                        color: Colors.orange,
                                      )
                                    : lesson['status'] == 'completed'
                                        ? Icon(
                                            Icons.check_circle_outlined,
                                            color: greenColor,
                                          )
                                        : Icon(Icons.cancel_outlined,
                                            color: redcolor),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    ),
  );
}

Future<void> getAllMissedLessons(
    BuildContext context, FirebaseFirestore firestore) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
          ),
          width: MediaQuery.of(context).size.width / 2.5,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_ios),
                        Text('Back'),
                      ],
                    ),
                  ),
                  Text('All missed lessons'),
                ],
              ),
              SizedBox(height: 10),
              StreamBuilder(
                stream: firestore
                    .collection('bookedLessons')
                    .where('status', isEqualTo: 'missed')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Define the current date and the end date (next 3 days)
                  DateTime today = DateTime.now();
                  DateTime endDate = today.add(Duration(days: 3));
                  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
                  DateFormat displayFormat = DateFormat('dd MMM- yyyy');

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot lesson = snapshot.data!.docs[index];

                      // Parse the date and format it as "13 Nov- 2024"
                      DateTime lessonDate = dateFormat.parse(lesson['date']);
                      String formattedDate = displayFormat.format(lessonDate);

                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  children: [
                                    Text(lesson['student']),
                                    Text(" missed lesson ${lesson['lessons']}"),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Text("Location: ${lesson['location']}"),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "Date $formattedDate at ${lesson['time']}"),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${lesson['status'][0].toUpperCase()}${lesson['status'].substring(1)} at ${lesson['time']}",
                                      ),
                                      Icon(Icons.cancel_outlined,
                                          color: Colors.red),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget getAllPackages(BuildContext context, FirebaseFirestore firestore) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(0),
    ),
    width: MediaQuery.of(context).size.width / 4.5,
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('All Packages'),
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: lightgray,
                border: Border.all(color: bluecolor),
              ),
              child: GestureDetector(
                onTap: () {
                  showAddPackageBottomSheet(context, firestore);
                },
                child: Text(
                  'Add New Package',
                  style: TextStyle(
                      color: bluecolor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10), // Optional styling
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        StreamBuilder(
          stream: firestore.collection('packages').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            List<DocumentSnapshot> pages = snapshot.data!.docs;

            if (pages.isEmpty) {
              return Center(child: Text("No packages found"));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                DocumentSnapshot page = pages[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightgray,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Text(
                              "Package Name: ",
                              style: TextStyle(
                                  color: customblack,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(page['name'].toString()),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Column(
                          children: [
                            Text(
                              "Description: ",
                              style: TextStyle(
                                  color: customblack,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${page['description'].toString()}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w100,
                                  color: customblack.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Original Price: ${page['price'].toString()}",
                              style: TextStyle(color: redcolor)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Sale Price: ${page['sale_price'].toString()}",
                              style: TextStyle(color: greenColor)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Show confirmation dialog before deleting
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirm Delete'),
                                    content: Text(
                                        'Are you sure you want to delete this package?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Delete the package
                                          firestore
                                              .collection('packages')
                                              .doc(page.id)
                                              .delete()
                                              .then((_) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Package deleted successfully'),
                                                backgroundColor:
                                                    greenColor, // Green for success
                                              ),
                                            );
                                          });

                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Icon(Icons.delete_outlined, color: redcolor),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () =>
                                showUpdateBottomSheet(context, firestore, page),
                            child: Icon(
                              Icons.edit_outlined,
                              color: greenColor,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    ),
  );
}

void showAddPackageBottomSheet(
    BuildContext context, FirebaseFirestore firestore) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(20),
        // ),
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_ios),
                          Text('Back'),
                        ],
                      ),
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      'New Package Below',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: customblack),
                    ),
                  ],
                ),
              ),
              customTextfields(nameController, descriptionController,
                  priceController, salePriceController),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Check if all fields are filled
                      if (nameController.text.isEmpty ||
                          descriptionController.text.isEmpty ||
                          priceController.text.isEmpty ||
                          salePriceController.text.isEmpty) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('All fields are required'),
                            backgroundColor: Colors.red, // Red for error
                          ),
                        );
                      } else {
                        // Add new package to Firestore
                        firestore.collection('packages').add({
                          'name': nameController.text,
                          'description': descriptionController.text,
                          'price': double.tryParse(priceController.text) ?? 0.0,
                          'sale_price':
                              double.tryParse(salePriceController.text) ?? 0.0,
                        }).then((_) {
                          Navigator.pop(context); // Close the dialog
                          // Show success snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Package added successfully'),
                              backgroundColor: greenColor, // Green for success
                            ),
                          );
                        });
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: customblack,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 5, bottom: 5),
                      child: Center(
                        child: Text(
                          'Save',
                          style: TextStyle(color: lightgray),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}

void showUpdateBottomSheet(
    BuildContext context, FirebaseFirestore firestore, DocumentSnapshot page) {
  final TextEditingController nameController =
      TextEditingController(text: page['name']);
  final TextEditingController descriptionController =
      TextEditingController(text: page['description']);
  final TextEditingController priceController =
      TextEditingController(text: page['price'].toString());
  final TextEditingController salePriceController =
      TextEditingController(text: page['sale_price'].toString());

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_ios),
                          Text('Back'),
                        ],
                      ),
                    ),
                    Text(
                      'Update Package Below',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: customblack),
                    ),
                  ],
                ),
              ),
              customTextfields(nameController, descriptionController,
                  priceController, salePriceController),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Show confirmation dialog before updating
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Update'),
                            content: Text(
                                'Are you sure you want to update this package?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: Text('Cancel',
                                    style: TextStyle(color: redcolor)),
                              ),
                              TextButton(
                                  onPressed: () {
                                    // Update Firestore with new data
                                    firestore
                                        .collection('packages')
                                        .doc(page.id)
                                        .update({
                                      'name': nameController.text,
                                      'description': descriptionController.text,
                                      'price': double.tryParse(
                                              priceController.text) ??
                                          0.0,
                                      'sale_price': double.tryParse(
                                              salePriceController.text) ??
                                          0.0,
                                    }).then((_) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MyHomePage(),
                                          ));

                                      // Show success snackbar
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Package updated successfully'),
                                          backgroundColor:
                                              greenColor, // Green for success
                                        ),
                                      );
                                    });
                                  },
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(color: greenColor),
                                  )),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: customblack,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 5, bottom: 5),
                      child: Center(
                        child: Text(
                          'Update',
                          style: TextStyle(color: lightgray),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}

Widget customTextfields(
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController priceController,
    TextEditingController salePriceController) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          cursorColor: greenColor,
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Package Name',
            hintStyle: TextStyle(
              color: greenColor,
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: lightgray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: lightgray, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: lightgray, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: lightgray, width: 1),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 200,
          child: TextField(
            cursorColor: greenColor,
            controller: descriptionController,
            maxLines: null,
            expands: true,
            decoration: InputDecoration(
              hintText: 'Description',
              alignLabelWithHint: true,
              hintStyle: TextStyle(
                color: greenColor,
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: lightgray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: lightgray, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: lightgray, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: lightgray, width: 1),
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          cursorColor: greenColor,
          controller: priceController,
          decoration: InputDecoration(
            hintText: 'Price',
            hintStyle: TextStyle(
              color: greenColor,
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: lightgray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: lightgray, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: lightgray, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: lightgray, width: 1),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          cursorColor: greenColor,
          controller: salePriceController,
          decoration: InputDecoration(
            hintText: 'Sale Price',
            hintStyle: TextStyle(
              color: greenColor,
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: lightgray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: lightgray, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: lightgray, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: lightgray, width: 1),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ),
    ],
  );
}
