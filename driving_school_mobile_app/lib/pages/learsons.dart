import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:driving_school_mobile_app/colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../utils/utils.dart';

class BookingCalendar extends StatefulWidget {
  final String username;
  final String useremail;
  final int numberoflessons;
  final String package_reference;
  const BookingCalendar(
      {super.key,
      required this.username,
      required this.useremail,
      required this.numberoflessons,
      required this.package_reference});

  @override
  _BookingCalendarState createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  TextEditingController textEditingController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<String>> bookedSlotsByDate = {};
  Map<String, String> drivingSchools = {}; // To store driving schools data
  late bool showBookedAndAvailableSlots = false;
  String selectedValue = '';
  // Firestore query to fetch booked lessons based on package reference

// List to store user lessons
  final List<String> userLessons = [];

  List<String> disabledDays = ['Sunday'];

  @override
  void initState() {
    super.initState();
  }

  bool _isDayDisabled(DateTime day) {
    return disabledDays
        .contains(day.weekday == DateTime.sunday ? 'Sunday' : '');
  }

  int _getAvailableSlotsCount(String date) {
    const int totalSlots = 8; // Slots from 8 AM to 3 PM
    if (bookedSlotsByDate.containsKey(date)) {
      return totalSlots - (bookedSlotsByDate[date]?.length ?? 0);
    }
    return totalSlots;
  }

  void getUserLessons() async {
    final firebaseQuery = FirebaseFirestore.instance
        .collection('bookedLessons')
        .where('package_reference', isEqualTo: widget.package_reference)
        .where('status', isEqualTo: 'pending');

    try {
      // Clear the list to refresh before adding new data
      userLessons.clear();

      // Fetch the query snapshot
      final QuerySnapshot snapshot = await firebaseQuery.get();

      // Check if there are documents
      if (snapshot.docs.isNotEmpty) {
        // Extract desired data into the list
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          // Add the lesson number as a string to the userLessons list
          userLessons.add(data['lesson_number'].toString());
        }

        // Sort the list numerically
        userLessons.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

        print(
            "User lessons refreshed (sorted): $userLessons"); // Debugging output
      } else {
        print("No lessons found for the given package reference.");
      }
    } catch (e) {
      print("Error fetching lessons: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    getUserLessons();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lesson Booking'),
                Column(
                  children: [
                    Text(
                      'Show Booked Slots',
                      style: TextStyle(fontSize: 12),
                    ),
                    Switch(
                      inactiveTrackColor: lightgray,
                      activeColor: customblack,
                      value: showBookedAndAvailableSlots,
                      onChanged: (bool value) {
                        setState(() {
                          showBookedAndAvailableSlots = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: lightgray,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: TableCalendar(
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: greenColor,
                ),
                selectedDecoration: BoxDecoration(
                  color: redcolor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: lightgray),
                todayTextStyle: TextStyle(color: lightgray),
              ),
              availableGestures: AvailableGestures.horizontalSwipe,
              firstDay: DateTime.now(),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              enabledDayPredicate: (day) => !_isDayDisabled(day),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  String dayStr = day.toIso8601String().split('T')[0];
                  int availableSlots = _getAvailableSlotsCount(dayStr);

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 10,
                        right: 0,
                        child: showBookedAndAvailableSlots
                            ? Container(
                                padding: EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  color: availableSlots < 8
                                      ? redcolor
                                      : greenColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  '$availableSlots',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              )
                            : Text(''),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 16,
                            color: showBookedAndAvailableSlots &&
                                    availableSlots < 8
                                ? redcolor
                                : customblack,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: customblack,
              borderRadius: BorderRadius.circular(20),
            ),
            height: 50,
            child: Center(
              child: Text(
                textAlign: TextAlign.center,
                'Select a Time Slot for ${_selectedDay?.toLocal().toIso8601String().split("T")[0] ?? "No Date Selected"}',
                style: TextStyle(color: lightgray),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookedLessons')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: customLoadingAnimation());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading lessons'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No lessons available'));
                }

                bookedSlotsByDate.clear();
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  String date = data['date'];
                  String time = data['time'];

                  if (bookedSlotsByDate.containsKey(date)) {
                    bookedSlotsByDate[date]!.add(time);
                  } else {
                    bookedSlotsByDate[date] = [time];
                  }
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('drivingSchools')
                      .snapshots(),
                  builder: (context, drivingSchoolsSnapshot) {
                    if (drivingSchoolsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: customLoadingAnimation());
                    }

                    if (drivingSchoolsSnapshot.hasError) {
                      return Center(
                          child: Text('Error loading driving schools'));
                    }

                    if (drivingSchoolsSnapshot.hasData) {
                      drivingSchools.clear();
                      for (var doc in drivingSchoolsSnapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        String timeSlot = data['time'];
                        String schoolName = data['school'];
                        drivingSchools[timeSlot] = schoolName;
                        //  print(drivingSchools);
                      }
                    }

                    if (_selectedDay != null &&
                        _selectedDay!.isAfter(DateTime.now())) {
                      String selectedDateStr =
                          _selectedDay!.toIso8601String().split('T')[0];
                      return ListView.builder(
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          final timeSlot = '${8 + index}:00';
                          bool isBooked = bookedSlotsByDate[selectedDateStr]
                                  ?.contains(timeSlot) ??
                              false;

                          return ListTile(
                            tileColor: isBooked ? lightgray : Colors.white,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$timeSlot - ${8 + index + 1}:00'),
                                if (drivingSchools.containsKey(timeSlot))
                                  Text(drivingSchools[timeSlot]
                                      .toString()
                                      .toString()!),
                              ],
                            ),
                            trailing: isBooked
                                ? Icon(Icons.event_busy_outlined,
                                    color: redcolor)
                                : Icon(Icons.event_available,
                                    color: greenColor),
                            enabled: !isBooked,
                            onTap: isBooked
                                ? null
                                : () {
                                    userLessons.length == 0
                                        ? showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                    'No lessons available'),
                                                content: Text(
                                                    'All lessons for this package have been completed.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('OK'),
                                                  ),
                                                ],
                                              );
                                            },
                                          )
                                        : _showBuyNowModal(
                                            '$timeSlot - ${8 + index + 1}:00');
                                  },
                          );
                        },
                      );
                    } else {
                      return Center(
                          child: Text(
                              'Select a future date to view available slots'));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyNowModal(String timeSlot) {
    String timeKey =
        timeSlot.split(' - ')[0]; // Extract the time (e.g., "11:00")
    String localSelectedValue =
        selectedValue; // Create a local variable for the modal

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('drivingSchools')
              .where('time',
                  isEqualTo: timeKey) // Filter by time (e.g., "11:00")
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: customLoadingAnimation());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Error loading driving school data'));
            }

            String drivingSchoolName = 'Unknown School';
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              if (data['school'] != null && data['time'] == timeKey) {
                drivingSchoolName = data['school'] ?? 'Unknown School';
                break;
              }
            }

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  padding: EdgeInsets.all(16.0),
                  height: 300, // Adjusted height
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirm Booking',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Total Lessons: ${widget.numberoflessons}'),
                        ],
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          hint: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.class_outlined,
                                size: 16,
                                color: bluecolor,
                              ),
                              Text(
                                localSelectedValue.isEmpty
                                    ? 'Select lesson number'
                                    : 'Lesson $localSelectedValue', // Show "Lesson" with selected value
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: bluecolor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          items: userLessons
                              .map((String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: bluecolor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: localSelectedValue.isEmpty
                              ? null
                              : localSelectedValue, // Handle initial empty state
                          onChanged: (value) {
                            setModalState(() {
                              localSelectedValue = value!;
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: lightgray,
                            ),
                            elevation: 1,
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: 14,
                            iconEnabledColor: bluecolor,
                            iconDisabledColor: bluecolor,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 200,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: lightgray,
                            ),
                            offset: const Offset(20, 0),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: MaterialStateProperty.all(6),
                              thumbVisibility: MaterialStateProperty.all(true),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                            padding: EdgeInsets.only(left: 14, right: 14),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      SelectableText(
                        textAlign: TextAlign.center,
                        'Do you want to book a lesson for ${_selectedDay!.toLocal().toIso8601String().split("T")[0]} at $timeSlot?',
                      ),
                      SizedBox(height: 10),
                      Text(
                        drivingSchoolName,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              try {
                                print(
                                    'User email: ${widget.useremail}'); // Debugging output
                                print(
                                    'Selected lesson number: $localSelectedValue'); // Debugging output
                                print(
                                    'widget.package_reference: ${widget.package_reference}'); // Debugging output

                                // Retrieve the document ID based on conditions (e.g., user email and package reference)
                                final querySnapshot = await FirebaseFirestore
                                    .instance
                                    .collection('bookedLessons')
                                    .where('email', isEqualTo: widget.useremail)
                                    .where('package_reference',
                                        isEqualTo: widget.package_reference)
                                    .where('lesson_number',
                                        isEqualTo:
                                            localSelectedValue) // Query as string
                                    .get();

                                if (querySnapshot.docs.isNotEmpty) {
                                  // Assuming the document exists, get its ID
                                  final documentId =
                                      querySnapshot.docs.first.id;
                                  String fromtime = timeSlot.split(' - ')[0];
                                  // Update the document with new data
                                  await FirebaseFirestore.instance
                                      .collection('bookedLessons')
                                      .doc(documentId)
                                      .update({
                                    'date': _selectedDay!
                                        .toLocal()
                                        .toIso8601String()
                                        .split("T")[0],
                                    'time': fromtime,
                                    'lesson_number': localSelectedValue,
                                    'status': 'pending',
                                    'location': drivingSchoolName,
                                  });

                                  // Show confirmation or perform further actions
                                  print('Document updated successfully.');
                                } else {
                                  print(
                                      'No matching document found to update.');
                                }
                              } catch (e) {
                                print('Error updating document: $e');
                              }

                              Navigator.pop(context); // Close the modal
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
          },
        );
      },
    );
  }
}
