import 'package:flutter/material.dart';
import 'package:talent/utility/share/app_strings.dart';

import '../../../utility/utils/size_config.dart';

class RejectScreen extends StatefulWidget {
  const RejectScreen({super.key});

  @override
  State<RejectScreen> createState() => _RejectScreenState();
}

class _RejectScreenState extends State<RejectScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Image(
                width: 250,
                height: 250,
                color: Colors.red,
                image: AssetImage('assets/logos/ic_device.png'),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              AppStrings.accessDenied,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              AppStrings.youDontHaveAccess,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              AppStrings.youDontHaveAccess,
              style: const TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
