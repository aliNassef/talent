import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:talent/utility/style/theme.dart';
 import '../../data/models/holiday/holiday.dart';

// ignore: must_be_immutable
class HolidayCardWidget extends StatefulWidget {
  Holiday holiday;
  HolidayCardWidget({Key? key, required this.holiday}) : super(key: key);

  @override
  State<HolidayCardWidget> createState() => _HolidayCardWidgetState();
}

class _HolidayCardWidgetState extends State<HolidayCardWidget> {
  //Variable
  List<String> start = [];
  List<String> end = [];
  bool isOneDay = false;

  @override
  void initState() {
    super.initState();
    dateFormatChange();
  }

  void dateFormatChange() {
    String startDate;
    String endDate;
    startDate =
        DateFormat.MMMEd().format(DateTime.parse(widget.holiday.date_from!));
    start = startDate.split(',');
    if (widget.holiday.date_to! != "") {
      endDate =
          DateFormat.MMMEd().format(DateTime.parse(widget.holiday.date_to!));
      end = endDate.split(',');
      isOneDay = const DeepCollectionEquality().equals(start, end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 80,
            width: 70,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: const BoxDecoration(
              color: Color(0xFF427caa),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  start[0],
                  style: normalMediumWhiteText,
                ),
                Text(start[1].split(' ')[2], style: normalMediumWhiteText),
                Text(start[1].split(' ')[1], style: normalMediumWhiteText)
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: Text(
            widget.holiday.name!,
            style: normalSmallGreyText,
          )),
          isOneDay == false
              ? Container(
                  width: 70,
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: const BoxDecoration(
                    color: Color(0xFFe95e1d),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        end[0],
                        style: normalMediumWhiteText,
                      ),
                      Text(end[1].split(' ')[2], style: normalMediumWhiteText),
                      Text(end[1].split(' ')[1], style: normalMediumWhiteText)
                    ],
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
