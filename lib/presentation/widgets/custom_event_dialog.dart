import 'package:flutter/material.dart';

class CustomEventDialog extends StatefulWidget {
  const CustomEventDialog({Key? key}) : super(key: key);

  @override
  CustomEventDialogState createState() => CustomEventDialogState();
}

class CustomEventDialogState extends State<CustomEventDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 160,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          color: Colors.white,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Wrap(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                color: Colors.red,
                child: Column(
                  children: <Widget>[
                    Container(height: 10),
                    const Icon(Icons.cloud_off, color: Colors.white, size: 80),
                    Container(height: 10),
                    Text(
                      "No internet !",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(color: Colors.white),
                    ),
                    Container(height: 10),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Text(
                      'Your device will need to make sure wifi or mobile data are turn on.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: const Color(0xFF666666),
                      ),
                    ),
                    Container(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[300],
                        padding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 40,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: const Text(
                        "Retry",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
