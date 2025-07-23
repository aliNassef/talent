import 'package:flutter/material.dart';

class ColorObj {
  const ColorObj();

  static const Color textColor = Color(0xff666666);
  static const Color secondaryColor = Color(0xff999999);
  static const Color successColor = Color(0xFF58AF55);
  static const Color dropDownBorderColor = Color(0xFFBDBDBD);

  // static const Color mainColor = Color.fromARGB(255, 34, 122, 83);
  // static const Color mainColor = Color.fromARGB(255, 81, 34, 122);
  // static const Color mainColor = Color.fromARGB(255, 120, 52, 131);
  // static const Color mainColor = Color.fromARGB(255, 105, 93, 181);
  //  static const Color mainColor = Color.fromARGB(255, 78, 73, 157);
  static const Color mainColor4 = Color.fromARGB(255, 79, 80, 164);

  // static const Color mainColor = Color(0xff2985dc);026d94
  static const Color mainColor = Color(0xff026d94);

  static const Color homebgColor = Color.fromARGB(255, 164, 190, 255);

  static const Color loginBackgroundColor = Color.fromARGB(255, 48, 159, 176);
  static const Color secondColor = Color(0xff208d9c);
  static const Color titleColor = Color(0xFF5A606B);
  static const Color layoutColor = Color(0xfff5f5f5);
  static const Color text_color_dark_grey = Color(0xff37474F);
  static const Color text_color_light_grey = Color(0xff7A7B7C);
  static const Color gross_title_color = Color(0xffB5C7E6);
  static const Color darkColor = Color(0xff4e4496);

  // static const Color mainColor = const Color(0xff3757b3);
  // static const Color loginBackgroundColor = const Color(0xff3051b0);
  // static const Color secondColor = const Color(0xff208d9c);
  // static const Color titleColor = const Color(0xFF5A606B);
  // static const Color layoutColor = const Color(0xfff5f5f5);
  // static const Color text_color_dark_grey = const Color(0xff37474F);
  // static const Color text_color_light_grey = const Color(0xff7A7B7C);
  // static const Color gross_title_color = const Color(0xffB5C7E6);
  // static const Color darkColor = Color(0xff4e4496);

  static Color greyColor1 = Colors.grey[100]!;
  static Color greyColor2 = Colors.grey[200]!;
  static Color greyColor3 = Colors.grey[300]!;
  static Color greyColor4 = Colors.grey[400]!;
  static Color greyColor5 = Colors.grey[500]!;
  static Color greyColor6 = Colors.grey[600]!;
  static Color greyColor7 = Colors.grey[700]!;
  static Color greyColor8 = Colors.grey[800]!;
}

class Themes {
  final blueTheme = ThemeData();
}

TextStyle title7 = TextStyle(
  // fontFamily: 'Regular',
  fontSize: 14,
  color: Colors.grey[800],
);
//appBarTitle
TextStyle appBarTitleStyle = const TextStyle(
  fontFamily: 'Poppins',
  color: Colors.white,
);

//For state
TextStyle stateTextStyle = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  color: Colors.white,
);

//For Table
TextStyle tableHeadingStyle = const TextStyle(
  fontSize: 14,
  color: Colors.black,
  fontFamily: 'Poppins',
);
TextStyle tableHeadingStyle2 = const TextStyle(
  fontSize: 14,
  color: Colors.white,
  fontFamily: 'Poppins',
);

TextStyle tableCellStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  color: Colors.grey[700],
);

//For list
TextStyle listRow1TextStyle = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15,
  color: Colors.black,
);

TextStyle listRow2TextStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  color: Colors.grey[700],
);

TextStyle listRow3TextStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  color: Colors.grey[700],
);

TextStyle listRow2TextStyleMainColor = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  color: ColorObj.mainColor,
);

TextStyle sectionHeaderTextStyle = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  color: Colors.black,
);

//fontsize 14
TextStyle normalTextWithBlack = const TextStyle(
  color: Colors.black,
  fontSize: 14,
);
TextStyle normalTextWithWhite = const TextStyle(
  color: Colors.white,
  fontSize: 14,
);
TextStyle normalTextWithPurple = const TextStyle(
  color: ColorObj.darkColor,
  fontSize: 14,
);
TextStyle normalTextWithGrey800 = TextStyle(
  color: Colors.grey[800],
  fontSize: 14,
);
TextStyle normalTextWithGrey700 = TextStyle(
  color: Colors.grey[700],
  fontSize: 14,
);
TextStyle normalTextWithGrey600 = TextStyle(
  color: Colors.grey[600],
  fontSize: 14,
);

//fontsize 12
TextStyle smallTextWithBlack = const TextStyle(
  color: Colors.black,
  fontSize: 12,
);
TextStyle smallTextWithWhite = const TextStyle(
  color: Colors.white,
  fontSize: 12,
);
TextStyle smallTextWithPurple = const TextStyle(
  color: ColorObj.darkColor,
  fontSize: 12,
);
TextStyle smallTextWithGrey800 = TextStyle(
  color: Colors.grey[800],
  fontSize: 12,
);
TextStyle smallTextWithGrey700 = TextStyle(
  color: Colors.grey[700],
  fontSize: 12,
);
TextStyle smallTextWithGrey600 = TextStyle(
  color: Colors.grey[600],
  fontSize: 12,
);

//fontsize 16
TextStyle largeTextWithBlack = const TextStyle(
  color: Colors.black,
  fontSize: 16,
);
TextStyle largeTextWithWhite = const TextStyle(
  color: Colors.white,
  fontSize: 16,
);
TextStyle largeTextWithPurple = const TextStyle(
  color: ColorObj.darkColor,
  fontSize: 16,
);
TextStyle largeTextWithGrey800 = TextStyle(
  color: Colors.grey[800],
  fontSize: 16,
);
TextStyle largeTextWithGrey700 = TextStyle(
  color: Colors.grey[700],
  fontSize: 16,
);
TextStyle largeTextWithGrey600 = TextStyle(
  color: Colors.grey[600],
  fontSize: 16,
);
//normalText Grey

TextStyle normalSmallGreyText = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  color: Colors.grey[700],
);

TextStyle normalMediumGreyText = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  color: Colors.grey[700],
);

TextStyle normalLargeGreyText = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15,
  color: Colors.grey[700],
);

TextStyle normalXLGreyText = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  color: Colors.grey[700],
);

TextStyle normalDoubleXLGreyText = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18,
  color: Colors.grey[700],
);
//normalText Black
TextStyle normalSmallBalckText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  color: Colors.black,
);

TextStyle normalMediumBalckText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  color: Colors.black,
);

TextStyle normalLargeBalckText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15,
  color: Colors.black,
);

TextStyle normalXLBalckText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  color: Colors.black,
);

TextStyle normalDoubleXLBalckText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18,
  color: Colors.black,
);

//normalText White
TextStyle normalSmallWhiteText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  color: Colors.white,
);

TextStyle normalMediumWhiteText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  color: Colors.white,
);

TextStyle normalLargeWhiteText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15,
  color: Colors.white,
);

TextStyle normalXLWhiteText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  color: Colors.white,
);

TextStyle normalDoubleXLWhiteText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18,
  color: Colors.white,
);

TextStyle normalDoubleXXLWhiteText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 22,
  color: Colors.white,
);

//normalText Red
TextStyle normalSmallRedText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  color: Colors.red,
);

TextStyle normalMediumRedText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  color: Colors.red,
);
TextStyle normalLargeRedText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15,
  color: Colors.red,
);

TextStyle normalXLRedText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  color: Colors.red,
);

TextStyle normalDoubleXLRedText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18,
  color: Colors.red,
);

//normalText Theme
TextStyle normalSmallBlueText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 13,
  color: ColorObj.mainColor,
);

TextStyle normalMediumBlueText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
  color: ColorObj.mainColor,
);

TextStyle normalLargeBlueText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15,
  color: ColorObj.mainColor,
);

TextStyle normalXLBlueText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  color: ColorObj.mainColor,
);

TextStyle normalDoubleXLBlueText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18,
  color: ColorObj.mainColor,
);

//BOLD
//Blue
TextStyle boldLargeBlueText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15,
  color: ColorObj.mainColor,
);

TextStyle boldXLBlueText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  color: ColorObj.mainColor,
);

TextStyle boldXXLBlueText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18,
  color: ColorObj.mainColor,
);

TextStyle boldXXXLBlueText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 20,
  color: ColorObj.mainColor,
);

TextStyle boldXXXXLWhiteText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 21,
  color: Colors.white,
);

//White
TextStyle boldLargeWhiteText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15,
  color: Colors.white,
);

TextStyle boldXLWhiteText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  color: Colors.white,
);

TextStyle boldXXLWhiteText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18,
  color: Colors.white,
);

TextStyle boldXXXLWhiteText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 20,
  color: Colors.white,
);

//Grey
TextStyle boldLargeGreyText = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15,
  color: Colors.grey[500],
);

TextStyle boldXLGreyText = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  color: Colors.grey[500],
);

TextStyle boldXXLGreyText = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18,
  color: Colors.grey[500],
);

TextStyle boldXXXLGreyText = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 20,
  color: Colors.grey[500],
);

//Grey

TextStyle boldMediumBlackText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 14,
);
TextStyle boldLargeBlackText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15,
);

TextStyle boldXLBlackText = const TextStyle(fontFamily: 'Poppins', fontSize: 16);

TextStyle boldXXLBlackText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18,
);

TextStyle boldXXXLBlackText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 20,
);

TextStyle boldXXXXLBlackText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 22,
);

//Grey
TextStyle boldLargeRedText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15,
  color: Colors.red,
);

TextStyle boldXLRedText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  color: Colors.red,
);

TextStyle boldXXLRedText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18,
  color: Colors.red,
);

TextStyle boldXXXLRedText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 20,
  color: Colors.red,
);
//Green
TextStyle boldLargeGreenText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15,
  color: Colors.green,
);

TextStyle boldXLGreenText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 16,
  color: Colors.green,
);

TextStyle boldXXLGreenText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18,
  color: Colors.green,
);

TextStyle boldXXXLGreenText = const TextStyle(
  fontFamily: 'Poppins',
  fontSize: 20,
  color: Colors.green,
);

//Grey
