import 'package:driving_school_mobile_app/backend/data.dart';
import 'package:driving_school_mobile_app/colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingCalendar extends StatefulWidget {
  @override
  _BookingCalendarState createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  TextEditingController textEditingController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> lessonsDate = generateDummyLessonsData();
  Map<String, List<String>> bookedSlotsByDate = {};
  late String selectedValue = '';
  late bool showBookedAndAvailableSlots = false;

  List<String> disabledDays = [
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _initializeBookedSlots();
  }

  void _initializeBookedSlots() {
    for (var lesson in lessonsDate) {
      String date = lesson['date'];
      String time = lesson['time'];

      if (bookedSlotsByDate.containsKey(date)) {
        bookedSlotsByDate[date]!.add(time);
      } else {
        bookedSlotsByDate[date] = [time];
      }
    }
  }

  int _getAvailableSlotsCount(String date) {
    const int totalSlots = 8; // Slots from 8 AM to 3 PM
    if (bookedSlotsByDate.containsKey(date)) {
      return totalSlots - (bookedSlotsByDate[date]?.length ?? 0);
    }
    return totalSlots;
  }

  bool _isDayDisabled(DateTime day) {
    // Check if the current day is in the disabledDays list
    return disabledDays
        .contains(day.weekday == DateTime.sunday ? 'Sunday' : '');
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
                        }),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(), // Disable past dates
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            enabledDayPredicate: (day) {
              // Disable days based on the list of disabled days
              return !_isDayDisabled(day); // Return false for disabled days
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                String dayStr = day.toIso8601String().split('T')[0];
                bool isBooked = bookedSlotsByDate.containsKey(dayStr);
                int availableSlots = _getAvailableSlotsCount(dayStr);

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 10,
                      right: 0,
                      child: showBookedAndAvailableSlots == true
                          ? Container(
                              padding: EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                color:
                                    availableSlots < 8 ? redcolor : greenColor,
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
                          color: showBookedAndAvailableSlots == true
                              ? isBooked
                                  ? redcolor
                                  : customblack
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
          if (_selectedDay != null &&
              _selectedDay!.isAfter(DateTime.now())) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: customblack,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 50,
                    child: Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        'Select a Time Slot for ${_selectedDay!.toLocal().toIso8601String().split("T")[0]}',
                        style: TextStyle(color: lightgray),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  final timeSlot = '${8 + index}:00';
                  String selectedDateStr =
                      _selectedDay!.toIso8601String().split('T')[0];
                  bool isBooked =
                      bookedSlotsByDate[selectedDateStr]?.contains(timeSlot) ??
                          false;

                  return ListTile(
                    tileColor: isBooked ? lightgray : Colors.white,
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$timeSlot - ${8 + index + 1}:00'),
                        if (drivingSchools.containsKey(timeSlot))
                          Text(drivingSchools[timeSlot]!),
                      ],
                    ),
                    trailing: isBooked
                        ? Icon(Icons.event_busy_outlined, color: redcolor)
                        : Icon(
                            Icons.event_available,
                            color: greenColor,
                          ),
                    enabled: !isBooked,
                    onTap: isBooked
                        ? null
                        : () {
                            _showBuyNowModal('$timeSlot - ${8 + index + 1}:00');
                          },
                  );
                },
              ),
            )
          ] else if (_selectedDay != null &&
              _selectedDay!.isBefore(DateTime.now())) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "You cannot book lessons for past dates.",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ]
        ],
      ),
    );
  }

  void _showBuyNowModal(String timeSlot) {
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
                'Confirm Booking',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              SelectableText(
                textAlign: TextAlign.center,
                'Do you want to book a lesson for ${_selectedDay!.toLocal().toIso8601String().split("T")[0]} at $timeSlot?',
              ),
              if (drivingSchools.containsKey(timeSlot.split(' - ')[0]))
                Text(drivingSchools[timeSlot.split(' - ')[0]]!),
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
