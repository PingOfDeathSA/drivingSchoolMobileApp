import 'package:driving_school_mobile_app/colors.dart';
import 'package:flutter/material.dart';

class ViewPackages extends StatefulWidget {
  final Map<String, dynamic> package;
  const ViewPackages({super.key, required this.package});

  @override
  State<ViewPackages> createState() => _ViewPackagesState();
}

class _ViewPackagesState extends State<ViewPackages> {
  void _showBuyNowModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Confirm Purchase',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                  'Do you want to buy "${widget.package['name']}" for ${widget.package['price']}?'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Buy!'),
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
      body: Center(
        child: Container(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(widget.package['name'].toString()),
              Text(widget.package['price'].toString()),
              Text(widget.package['description'].toString()),
              GestureDetector(
                onTap: _showBuyNowModal,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: customblack,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Buy Now',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
