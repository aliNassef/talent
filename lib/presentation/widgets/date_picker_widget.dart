import 'package:flutter/material.dart';
import 'package:talent/utility/style/theme.dart';

 

// ignore: must_be_immutable
class DatePickerWidget extends StatefulWidget {
  String text;
  Function(DateTime) timePicker;
  DateTime init;
  int totalDays;
  DatePickerWidget({ Key? key,required this.text, required this.timePicker,required this.init, this.totalDays = 0 }) : super(key: key);

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? time;
  String? hour;
  String? minute;
  @override
  Widget build(BuildContext context) {
    
    return InkWell(
      onTap: ()async{
        time = await showDatePicker(context: context, initialDate: widget.init, firstDate: DateTime(2000), lastDate: DateTime(3000));
        if(time != null){
          print(time)
;
          setState(() {
            widget.timePicker(time!);
          });
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: 50,
        width: 200,
        decoration: BoxDecoration(
          border: Border.all(color:widget.totalDays < 0 ? Colors.redAccent : ColorObj.secondaryColor),
          borderRadius:const BorderRadius.all(Radius.circular(8)),
        ),
        child: Text(time==null || widget.totalDays < 0 ? widget.text : widget.init.toString().split(' ')[0],style: const TextStyle(fontSize: 15,color: ColorObj.textColor),),
      ),
    );
  }
}