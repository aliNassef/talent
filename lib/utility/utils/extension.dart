import 'package:flutter/material.dart';

extension PercentSized on double {
  double hp(BuildContext context) =>
      MediaQuery.of(context).size.height * (this / 100);
  double wp(BuildContext context) =>
      MediaQuery.of(context).size.width * (this / 100);
}

extension ResponsiveText on double {
  double sp(BuildContext context) =>
      MediaQuery.of(context).size.width / 100 * (this / 3);
}