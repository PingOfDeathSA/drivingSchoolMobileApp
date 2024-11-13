import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:driving_school_mobile_app/colors.dart';

class BookingCalendar extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
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
                  return Center(child: CircularProgressIndicator());
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
                      return Center(child: CircularProgressIndicator());
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
                                    _showBuyNowModal(
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
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Error loading driving school data'));
            }

            // Debugging: Print the snapshot data
            //   print('Snapshot Data: ${snapshot.data!.docs}');

            // Iterate over all documents to find the matching driving school
            String drivingSchoolName = 'Unknown School';
            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;

              // Check for the school and time match
              if (data['school'] != null && data['time'] == timeKey) {
                drivingSchoolName = data['school'] ?? 'Unknown School';
                break; // Exit loop once you find a match
              }
            }

            return Container(
              padding: EdgeInsets.all(16.0),
              height: 300, // Adjusted height
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Confirm Booking',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  SelectableText(
                    textAlign: TextAlign.center,
                    'Do you want to book a lesson for ${_selectedDay!.toLocal().toIso8601String().split("T")[0]} at $timeSlot?',
                  ),
                  SizedBox(height: 10),
                  Text(
                    drivingSchoolName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      },
    );
  }
}
