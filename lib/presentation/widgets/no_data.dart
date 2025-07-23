import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:talent/utility/share/app_strings.dart';

Widget noDataWidget() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Image(
            image: AssetImage('assets/imgs/ic_empty_data.png'),
            width: 250,
            height: 250,
          ),
          Text(
            AppStrings.noData.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.red[300],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noDataAvailable.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.noDataRefresh.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
