import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:driving_school_mobile_app/colors.dart';
import 'package:driving_school_mobile_app/pages/dashboard.dart';
import 'package:driving_school_mobile_app/pages/todo.dart';
import 'package:flutter/material.dart';

import '../pages/learsons.dart';
import '../pages/user_progress.dart';

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _page = 0; // Keep track of the selected index for navigation
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey<
      CurvedNavigationBarState>(); // Key to access the navigation state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _page, // Display page based on the selected index
        children: <Widget>[
          Dashboardpage(),
          BookingCalendar(),
          ProgressPage(),
          TodoPage(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page, // Set the currently selected page index
        items: <Widget>[
          Icon(Icons.dashboard_outlined, size: 30),
          Icon(Icons.schedule_outlined, size: 30),
          Icon(Icons.score, size: 30),
          Icon(Icons.school_outlined, size: 30),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: lightgray,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _page = index; // Update the page index on tap
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
