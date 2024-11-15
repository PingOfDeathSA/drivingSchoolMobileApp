import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../colors.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  TextStyle style =
      TextStyle(fontFamily: 'Montserrat', fontSize: 15.0, color: Colors.white);

  // TextController for search bar
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: lightgray,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Orders'),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: customblack,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  'RN',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Package Name or Username',
                    hintStyle: TextStyle(
                      color: bluecolor,
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                    //
                    filled: true,
                    fillColor: lightgray,
                    suffix: Icon(
                      Icons.search,
                      color: bluecolor,
                    ),

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
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // S
              Container(
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
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No orders available'),
                    );
                  }

                  // Filter the orders based on search query
                  final filteredOrders = snapshot.data!.docs.where((order) {
                    final username = order['username'].toString().toLowerCase();
                    final packageName = order['name'].toString().toLowerCase();
                    return username.contains(searchQuery) ||
                        packageName.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot orders = filteredOrders[index];
                      DateTime date = orders['date'].toDate();
                      String formattedDate =
                          DateFormat('d MMM yyyy').format(date);

                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              15,
                                          child: Text(
                                              orders['username'].toString()),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              15,
                                          child:
                                              Text(orders['email'].toString()),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              13,
                                          child: Text(
                                              orders['description'].toString()),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              15,
                                          child:
                                              Text(orders['name'].toString()),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              15,
                                          child:
                                              Text(orders['phone'].toString()),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              15,
                                          child:
                                              Text(orders['price'].toString()),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (orders['paid'] == true) {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          'Payment Status'),
                                                      content: Text(
                                                          'This order has been paid for do you want to mark it as not paid?'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text('No')),
                                                        TextButton(
                                                            onPressed: () {
                                                              firestore
                                                                  .collection(
                                                                      'packageOrders')
                                                                  .doc(
                                                                      orders.id)
                                                                  .update({
                                                                'paid': false
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text('Yes')),
                                                      ],
                                                    );
                                                  });
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          'Payment Status Not Paid'),
                                                      content: Text(
                                                          'Do you want to confirm payment for this order?'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text('No')),
                                                        TextButton(
                                                            onPressed: () {
                                                              firestore
                                                                  .collection(
                                                                      'packageOrders')
                                                                  .doc(
                                                                      orders.id)
                                                                  .update({
                                                                'paid': true
                                                              });
                                                              Navigator.pop(
                                                                  context);
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
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                15,
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              orders['paid'] == true
                                                  ? 'Yes'
                                                  : 'No',
                                              style: style,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              15,
                                          child: Text(formattedDate),
                                        ),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                15,
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Delete Order'),
                                                        content: Text(
                                                            'Are you sure you want to delete this order?'),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child:
                                                                  Text('No')),
                                                          TextButton(
                                                              onPressed: () {
                                                                firestore
                                                                    .collection(
                                                                        'packageOrders')
                                                                    .doc(orders
                                                                        .id)
                                                                    .delete();
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child:
                                                                  Text('Yes')),
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
          ),
        ));
  }
}