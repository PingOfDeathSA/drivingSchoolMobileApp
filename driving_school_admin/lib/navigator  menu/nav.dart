import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';

import '../colors.dart';
import '../pages/dashboard.dart';
import '../pages/learsons.dart';
import '../pages/orders_page.dart';
import '../pages/todo.dart';
import '../pages/user_progress.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();

  // Add a state variable to track menu collapse state
  bool collapsed = false;

  @override
  void initState() {
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideMenu(
            controller: sideMenu,
            style: SideMenuStyle(
              displayMode: collapsed
                  ? SideMenuDisplayMode.compact // Show only icons
                  : SideMenuDisplayMode.open, // Show full menu
              hoverColor: lightgray,
              selectedColor: greenColor,
              selectedTitleTextStyle: const TextStyle(color: Colors.white),
              unselectedTitleTextStyle: TextStyle(color: bluecolor),
              unselectedIconColor: bluecolor,
              selectedIconColor: Colors.white,
            ),
            title: collapsed == false
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            collapsed = !collapsed; // Toggle collapse state
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 25,
                            color: customblack,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            collapsed = !collapsed; // Toggle collapse state
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 25,
                            color: customblack,
                          ),
                        ),
                      ),
                    ],
                  ),
            items: [
              SideMenuItem(
                title: 'Dashboard',
                onTap: (index, _) => sideMenu.changePage(index),
                icon: const Icon(Icons.home),
              ),
              SideMenuItem(
                title: 'Users',
                onTap: (index, _) => sideMenu.changePage(index),
                icon: const Icon(Icons.supervisor_account),
                trailing: _buildUserCountStream(),
              ),
              SideMenuItem(
                title: 'Orders',
                onTap: (index, _) => sideMenu.changePage(index),
                icon: const Icon(Icons.shopping_cart),
                trailing: _buildUnpaidOrderStream(),
              ),
              SideMenuItem(
                title: 'Lessons',
                onTap: (index, _) => sideMenu.changePage(index),
                icon: const Icon(Icons.download),
              ),
              SideMenuItem(
                title: 'Driving School',
                onTap: (index, _) => sideMenu.changePage(index),
                icon: const Icon(Icons.settings),
              ),
              SideMenuItem(
                title: 'Admin',
                onTap: (index, _) => sideMenu.changePage(index),
                icon: const Icon(Icons.admin_panel_settings),
              ),
            ],
          ),
          const VerticalDivider(width: 0),
          Expanded(
            child: PageView(
              controller: pageController,
              children: [
                Dashboardpage(),
                BookingCalendar(),
                OrdersPage(),
                TodoPage(),
                const SizedBox.shrink(), // For the divider
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text(
                      'Settings',
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCountStream() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('learnersProfile').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.lightBlue[50],
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3),
          child: Text(
            snapshot.data!.docs.length.toString(),
            style: const TextStyle(fontSize: 11, color: Colors.black),
          ),
        );
      },
    );
  }

  Widget _buildUnpaidOrderStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('packageOrders')
          .where('paid', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final unpaidCount = snapshot.data!.docs.length;
        if (unpaidCount == 0) return Container();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3),
          child: Text(
            'New $unpaidCount',
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
        );
      },
    );
  }
}
