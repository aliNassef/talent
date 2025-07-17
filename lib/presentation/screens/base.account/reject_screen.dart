import 'package:flutter/material.dart';

import '../../../utility/utils/size_config.dart';

class RejectScreen extends StatefulWidget {
  const RejectScreen({super.key});

  _RejectScreenState createState() => _RejectScreenState();
}

class _RejectScreenState extends State<RejectScreen> {
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Image(
                width: 250,
                height: 250,
                color: Colors.red,
                image: AssetImage('assets/logos/ic_device.png'),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Access Denied!',
              style: TextStyle(
                color: Colors.red,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'You don\'t have access',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              'Please contact',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
