import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../utility/style/theme.dart';

// ignore: must_be_immutable
class HRDropDown extends StatefulWidget {
  List<String> items;
  String? selectedValue;
  String hint;
  HRDropDown(
      {Key? key,
      required this.items,
      required this.selectedValue,
      required this.hint})
      : super(key: key);

  @override
  State<HRDropDown> createState() => _HRDropDownState();
}

class _HRDropDownState extends State<HRDropDown> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: ColorObj.dropDownBorderColor)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            dropdownDecoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            isExpanded: true,
            hint: Text(
              widget.hint,
              style: const TextStyle(
                fontSize: 14,
                color: ColorObj.textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            items: widget.items
                .map((item) => DropdownMenuItem<String>(
                      // alignment: AlignmentDirectional.topStart,
                      value: item,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item,
                            style: const TextStyle(
                              fontSize: 14,
                              color: ColorObj.textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: item != widget.items.last ? 6 : 0,
                          ),
                          item != widget.items.last
                              ? const Divider()
                              : const SizedBox(),
                        ],
                      ),
                    ))
                .toList(),
            value: widget.selectedValue,
            onChanged: (value) {
              setState(() {
                widget.selectedValue = value as String;
              });
            },
          ),
        ));
  }
}
