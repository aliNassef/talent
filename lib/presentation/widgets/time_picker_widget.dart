import 'package:flutter/material.dart';
import 'package:talent/utility/utils/extension.dart';
 
class TimePickerWidget extends StatefulWidget {
  String text;
  Function(TimeOfDay) timePicker;
  TimeOfDay init;
  double totalHours;

  TimePickerWidget(
      {Key? key,
      required this.text,
      required this.timePicker,
      required this.init,
      this.totalHours = 0.0})
      : super(key: key);

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  TimeOfDay? time;
  String? hour;
  String? minute;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        time = await showTimePicker(context: context, initialTime: widget.init);
        if (time != null) {
          setState(() {
            widget.timePicker(time!);
          });
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: 50,
        width: 30.0.wp(context),
        decoration: BoxDecoration(
          border: Border.all(
              color: widget.totalHours < 0 ? Colors.redAccent : Colors.grey
              // ThemeColor.secondaryColor
              ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Text(
          time == null || widget.totalHours < 0
              ? widget.text
              : "${widget.init.hour} : ${widget.init.minute}",
          style: const TextStyle(
            fontSize: 15,
            //  color:  ThemeColor.textColor
          ),
        ),
      ),
    );
  }
}
