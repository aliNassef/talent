import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:talent/data/api/attendance_api.dart';
import 'package:talent/utility/style/theme.dart';

import '../../widgets/leave_time_picker.dart';
import 'error_dialog.dart';

class TimeSelectDialog extends StatefulWidget {
  const TimeSelectDialog({Key? key}) : super(key: key);

  @override
  State<TimeSelectDialog> createState() => _TimeSelectDialogState();
}

class _TimeSelectDialogState extends State<TimeSelectDialog> {
  late final DateTime init;
  late final DateTime lastDate;
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  int totalDays = 0;
  bool selectTime = false;
  @override
  void initState() {
    super.initState();
    init = DateTime.now();
    lastDate = DateTime(3000);
  }

  int totalDay() => totalDays = endTime.difference(startTime).inDays;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        height: 250,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.only(left: 20),
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: ColorObj.mainColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Choose Date",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ))
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TimePickerWidget(
                text: 'Start Date',
                timePicker: (t) {
                  setState(() {
                    startTime = t;
                    selectTime = true;
                    totalDays = -1;
                  });
                },
                init: startTime,
              ),
              const SizedBox(
                width: 30,
              ),
              const SizedBox(
                  child: Center(
                      child: Text(
                "TO",
                style: TextStyle(
                    fontSize: 15,
                    color: ColorObj.textColor,
                    fontWeight: FontWeight.bold),
              ))),
              const SizedBox(
                width: 30,
              ),
              selectTime
                  ? TimePickerWidget(
                      text: 'End Date',
                      timePicker: (t) {
                        setState(() {
                          endTime = t;
                          totalDays = totalDay();
                          if (totalDays < 0) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ErrorDialog(
                                      title: "End Date Select Error",
                                      content: const Text(
                                        "Please select correct End Date",
                                        style: TextStyle(
                                            color: ColorObj.textColor,
                                            fontSize: 15),
                                      ),
                                      icon: Icons.warning);
                                });
                          }
                        });
                      },
                      init: endTime,
                      totalDays: totalDays,
                    )
                  : InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return ErrorDialog(
                                title: "Date Select Failed",
                                content: const Text(
                                  "Please choose Start Date First",
                                  style: TextStyle(
                                      color: ColorObj.textColor, fontSize: 15),
                                ),
                                icon: Icons.warning,
                              );
                            });
                      },
                      child: AbsorbPointer(
                        absorbing: true,
                        child: TimePickerWidget(
                          text: 'End Time',
                          timePicker: (t) {
                            setState(() {
                              endTime = t;
                            });
                          },
                          init: endTime,
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                    width: 150,
                    height: 40,
                    child: TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black12)),
                        onPressed: () {
                          Navigator.of(context);
                        },
                        child: const Text("Cancel"))),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                    width: 150,
                    height: 40,
                    child: TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black12),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.green)),
                        onPressed: () async {
                          var attendanceApi = AttendanceAPI();
                          await attendanceApi.getAttendanceListByFilter(
                              'custom', startTime.toString().split(' ')[0], endTime.toString().split(' ')[0]);
                        },
                        child: const Text("Confirm"))),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
