import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:driving_school_mobile_app/colors.dart';
import 'package:intl/intl.dart';
import '../components/dashboardComponents.dart';

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

  late int totalSlotsBooked = 0;

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
                Text('Booked Slots'),
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
              firstDay: DateTime.utc(2020, 12, 31),
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

                  totalSlotsBooked = 8 - availableSlots;

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
          SizedBox(height: 10),
          _selectedDay != null
              ? Text(
                  'Slots for ${DateFormat('d MMMM yyyy').format(_selectedDay!)} ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )
              : Text(''),
          SizedBox(height: 10),
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
                        print(drivingSchools);
                      }
                    }

                    if (_selectedDay != null &&
                        _selectedDay!.isAfter(
                          DateTime.utc(2020, 12, 31),
                        )) {
                      String selectedDateStr =
                          _selectedDay!.toIso8601String().split('T')[0];
                      return ListView.builder(
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          final timeSlot = '${8 + index}:00';
                          bool isBooked = bookedSlotsByDate[selectedDateStr]
                                  ?.contains(timeSlot) ??
                              false;
                          return GestureDetector(
                            onTap: () {
                              if (isBooked) {
                                _checkSlotAndShowDetails(
                                    selectedDateStr, timeSlot);
                              }
                            },
                            child: ListTile(
                              tileColor: isBooked ? lightgray : Colors.white,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$timeSlot - ${8 + index + 1}:00'),
                                  if (drivingSchools.containsKey(timeSlot))
                                    Text(drivingSchools[timeSlot].toString()),
                                ],
                              ),
                              trailing: isBooked
                                  ? Icon(Icons.event_busy_outlined,
                                      color: redcolor)
                                  : Icon(Icons.event_available,
                                      color: greenColor),
                              enabled: isBooked,
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                          child: Text('Select a a date to view slots'));
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

  void _showSlotDetails(BuildContext context, Map<String, dynamic> slotData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Slot Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Course: ${slotData['course'] ?? 'N/A'}'),
              Text('Date: ${slotData['date'] ?? 'N/A'}'),
              Text('Duration: ${slotData['duration'] ?? 'N/A'}'),
              Text('Instructor: ${slotData['instructor'] ?? 'N/A'}'),
              Text('Lessons: ${slotData['lessons'] ?? 'N/A'}'),
              Text('Location: ${slotData['location'] ?? 'N/A'}'),
              Text('Status: ${slotData['status'] ?? 'N/A'}'),
              Text('Student: ${slotData['student'] ?? 'N/A'}'),
              Text('Time: ${slotData['time'] ?? 'N/A'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _checkSlotAndShowDetails(String selectedDate, String timeSlot) async {
    // Fetch the slot details from Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('bookedLessons')
        .where('date', isEqualTo: selectedDate)
        .where('time', isEqualTo: timeSlot)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Show the slot details
      _showSlotDetails(context, snapshot.docs.first.data());
    } else {
      // Show a message that the slot is not booked
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Slot Not Booked'),
            content: Text('This slot is not booked.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }
}
