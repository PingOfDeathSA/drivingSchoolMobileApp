import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school_mobile_app/colors.dart';
import 'package:driving_school_mobile_app/pages/view_packages.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';

import '../authentication/auth_service.dart';
import '../authentication/google_sign_in.dart';
import '../backend/data.dart';

class Dashboardpage extends StatefulWidget {
  final String username;
  final String useremail;
  const Dashboardpage(
      {super.key, required this.username, required this.useremail});

  @override
  State<Dashboardpage> createState() => _DashboardpageState();
}

class _DashboardpageState extends State<Dashboardpage> {
  final AuthService _authService = AuthService();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                            content: Text("Are you sure you want to sign out?"),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('On Sale!',
                      style: TextStyle(
                        fontSize: 20,
                        color: customblack,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
            Container(
              height: 250,
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('packages').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading packages'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No packages available'));
                  }

                  final packages = snapshot.data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();

                  return Swiper(
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      return GestureDetector(
                        onTap: () {
                          //   print(index);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey[200],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Package name
                                Text(
                                  package['name'],
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Price display with discount badge
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Column(
                                        children: [
                                          Text(
                                            'R${package['sale_price']}.00',
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Was ',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'R${package['price']}.00',
                                                style: TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Discount badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                        ),
                                      ),
                                      child: Text(
                                        'SALE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                // Buy Now button
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViewPackages(
                                          package: package,
                                          useremail: widget.useremail,
                                          username: widget.username,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 40,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Buy Now!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    autoplay: true,
                    itemCount: packages.length,
                    pagination: SwiperPagination(
                      margin: EdgeInsets.zero,
                      builder: DotSwiperPaginationBuilder(
                        color: Color(0xFFD5D5D5),
                        activeColor: Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('All Packages',
                      style: TextStyle(
                        fontSize: 15,
                        color: customblack,
                        fontWeight: FontWeight.bold,
                      )),
                  Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 15,
                          color: customblack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: customblack,
                        size: 15,
                      )
                    ],
                  )
                  //  Stream all packages
                ],
              ),
            ),
            Container(
              height: 220 * 2, // Adjust the height as needed
              width: double.infinity,
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('packages').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading packages'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No packages available'));
                  }

                  final packages = snapshot.data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 100,
                          margin:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Package name
                                Text(
                                  package['name'] ?? '',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Package description
                                Text(
                                  package['description'] ?? '',
                                  maxLines: 3,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                // Price and Buy Now button
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Price: R${package['price'] ?? ''}',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: bluecolor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ViewPackages(
                                              package: package,
                                              useremail: widget.useremail,
                                              username: widget.username,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        child: Center(
                                          child: Text(
                                            'Buy Now!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
