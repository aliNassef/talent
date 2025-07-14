import 'dart:ui';
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
  static const Color secondColor = const Color(0xff208d9c);
  static const Color titleColor = const Color(0xFF5A606B);
  static const Color layoutColor = const Color(0xfff5f5f5);
  static const Color text_color_dark_grey = const Color(0xff37474F);
  static const Color text_color_light_grey = const Color(0xff7A7B7C);
  static const Color gross_title_color = const Color(0xffB5C7E6);
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
    color: Colors.grey[800]);
//appBarTitle
TextStyle appBarTitleStyle =
    TextStyle(fontFamily: 'Regular', color: Colors.white);

//For state
TextStyle stateTextStyle =
    TextStyle(fontFamily: 'Regular', fontSize: 13, color: Colors.white);

//For Table
TextStyle tableHeadingStyle =
    TextStyle(fontSize: 14, color: Colors.black, fontFamily: 'Regular');
    TextStyle tableHeadingStyle2 =
    TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'Regular');

TextStyle tableCellStyle =
    TextStyle(fontFamily: 'Regular', fontSize: 13, color: Colors.grey[700]);

//For list
TextStyle listRow1TextStyle =
    TextStyle(fontFamily: 'Regular', fontSize: 15, color: Colors.black);

TextStyle listRow2TextStyle =
    TextStyle(fontFamily: 'Regular', fontSize: 14, color: Colors.grey[700]);

TextStyle listRow3TextStyle =
    TextStyle(fontFamily: 'Regular', fontSize: 13, color: Colors.grey[700]);

TextStyle listRow2TextStyleMainColor =
    TextStyle(fontFamily: 'Regular', fontSize: 14, color: ColorObj.mainColor);

TextStyle sectionHeaderTextStyle =
    TextStyle(fontFamily: 'Regular', fontSize: 16, color: Colors.black);

//fontsize 14
TextStyle normalTextWithBlack = TextStyle(
  color: Colors.black,
  fontSize: 14,
);
TextStyle normalTextWithWhite = TextStyle(color: Colors.white, fontSize: 14);
TextStyle normalTextWithPurple =
    TextStyle(color: ColorObj.darkColor, fontSize: 14);
TextStyle normalTextWithGrey800 =
    TextStyle(color: Colors.grey[800], fontSize: 14);
TextStyle normalTextWithGrey700 =
    TextStyle(color: Colors.grey[700], fontSize: 14);
TextStyle normalTextWithGrey600 =
    TextStyle(color: Colors.grey[600], fontSize: 14);

//fontsize 12
TextStyle smallTextWithBlack = TextStyle(color: Colors.black, fontSize: 12);
TextStyle smallTextWithWhite = TextStyle(color: Colors.white, fontSize: 12);
TextStyle smallTextWithPurple =
    TextStyle(color: ColorObj.darkColor, fontSize: 12);
TextStyle smallTextWithGrey800 =
    TextStyle(color: Colors.grey[800], fontSize: 12);
TextStyle smallTextWithGrey700 =
    TextStyle(color: Colors.grey[700], fontSize: 12);
TextStyle smallTextWithGrey600 =
    TextStyle(color: Colors.grey[600], fontSize: 12);

//fontsize 16
TextStyle largeTextWithBlack = TextStyle(color: Colors.black, fontSize: 16);
TextStyle largeTextWithWhite = TextStyle(color: Colors.white, fontSize: 16);
TextStyle largeTextWithPurple =
    TextStyle(color: ColorObj.darkColor, fontSize: 16);
TextStyle largeTextWithGrey800 =
    TextStyle(color: Colors.grey[800], fontSize: 16);
TextStyle largeTextWithGrey700 =
    TextStyle(color: Colors.grey[700], fontSize: 16);
TextStyle largeTextWithGrey600 =
    TextStyle(color: Colors.grey[600], fontSize: 16);
//normalText Grey

TextStyle normalSmallGreyText =
    TextStyle(fontFamily: 'Regular', fontSize: 13, color: Colors.grey[700]);

TextStyle normalMediumGreyText =
    TextStyle(fontFamily: 'Regular', fontSize: 14, color: Colors.grey[700]);

TextStyle normalLargeGreyText =
    TextStyle(fontFamily: 'Regular', fontSize: 15, color: Colors.grey[700]);

TextStyle normalXLGreyText =
    TextStyle(fontFamily: 'Regular', fontSize: 16, color: Colors.grey[700]);

TextStyle normalDoubleXLGreyText =
    TextStyle(fontFamily: 'Regular', fontSize: 18, color: Colors.grey[700]);
//normalText Black
TextStyle normalSmallBalckText =
    TextStyle(fontFamily: 'Regular', fontSize: 13, color: Colors.black);

TextStyle normalMediumBalckText =
    TextStyle(fontFamily: 'Regular', fontSize: 14, color: Colors.black);

TextStyle normalLargeBalckText =
    TextStyle(fontFamily: 'Regular', fontSize: 15, color: Colors.black);

TextStyle normalXLBalckText =
    TextStyle(fontFamily: 'Regular', fontSize: 16, color: Colors.black);

TextStyle normalDoubleXLBalckText =
    TextStyle(fontFamily: 'Regular', fontSize: 18, color: Colors.black);

//normalText White
TextStyle normalSmallWhiteText =
    TextStyle(fontFamily: 'Regular', fontSize: 13, color: Colors.white);

TextStyle normalMediumWhiteText =
    TextStyle(fontFamily: 'Regular', fontSize: 14, color: Colors.white);

TextStyle normalLargeWhiteText =
    TextStyle(fontFamily: 'Regular', fontSize: 15, color: Colors.white);

TextStyle normalXLWhiteText =
    TextStyle(fontFamily: 'Regular', fontSize: 16, color: Colors.white);

TextStyle normalDoubleXLWhiteText =
    TextStyle(fontFamily: 'Regular', fontSize: 18, color: Colors.white);

TextStyle normalDoubleXXLWhiteText =
    TextStyle(fontFamily: 'Regular', fontSize: 22, color: Colors.white);

//normalText Red
TextStyle normalSmallRedText =
    TextStyle(fontFamily: 'Regular', fontSize: 13, color: Colors.red);

TextStyle normalMediumRedText =
    TextStyle(fontFamily: 'Regular', fontSize: 14, color: Colors.red);

TextStyle normalLargeRedText =
    TextStyle(fontFamily: 'Regular', fontSize: 15, color: Colors.red);

TextStyle normalXLRedText =
    TextStyle(fontFamily: 'Regular', fontSize: 16, color: Colors.red);

TextStyle normalDoubleXLRedText =
    TextStyle(fontFamily: 'Regular', fontSize: 18, color: Colors.red);

//normalText Theme
TextStyle normalSmallBlueText =
    TextStyle(fontFamily: 'Regular', fontSize: 13, color: ColorObj.mainColor);

TextStyle normalMediumBlueText =
    TextStyle(fontFamily: 'Regular', fontSize: 14, color: ColorObj.mainColor);

TextStyle normalLargeBlueText =
    TextStyle(fontFamily: 'Regular', fontSize: 15, color: ColorObj.mainColor);

TextStyle normalXLBlueText =
    TextStyle(fontFamily: 'Regular', fontSize: 16, color: ColorObj.mainColor);

TextStyle normalDoubleXLBlueText =
    TextStyle(fontFamily: 'Regular', fontSize: 18, color: ColorObj.mainColor);

//BOLD
//Blue
TextStyle boldLargeBlueText =
    TextStyle(fontFamily: 'Bold', fontSize: 15, color: ColorObj.mainColor);

TextStyle boldXLBlueText =
    TextStyle(fontFamily: 'Bold', fontSize: 16, color: ColorObj.mainColor);

TextStyle boldXXLBlueText =
    TextStyle(fontFamily: 'Bold', fontSize: 18, color: ColorObj.mainColor);

TextStyle boldXXXLBlueText =
    TextStyle(fontFamily: 'Bold', fontSize: 20, color: ColorObj.mainColor);

TextStyle boldXXXXLWhiteText =
    TextStyle(fontFamily: 'Bold', fontSize: 21, color: Colors.white);

//White
TextStyle boldLargeWhiteText =
    TextStyle(fontFamily: 'Bold', fontSize: 15, color: Colors.white);

TextStyle boldXLWhiteText =
    TextStyle(fontFamily: 'Bold', fontSize: 16, color: Colors.white);

TextStyle boldXXLWhiteText =
    TextStyle(fontFamily: 'Bold', fontSize: 18, color: Colors.white);

TextStyle boldXXXLWhiteText =
    TextStyle(fontFamily: 'Bold', fontSize: 20, color: Colors.white);

//Grey
TextStyle boldLargeGreyText =
    TextStyle(fontFamily: 'Bold', fontSize: 15, color: Colors.grey[500]);

TextStyle boldXLGreyText =
    TextStyle(fontFamily: 'Bold', fontSize: 16, color: Colors.grey[500]);

TextStyle boldXXLGreyText =
    TextStyle(fontFamily: 'Bold', fontSize: 18, color: Colors.grey[500]);

TextStyle boldXXXLGreyText =
    TextStyle(fontFamily: 'Bold', fontSize: 20, color: Colors.grey[500]);

//Grey

TextStyle boldMediumBlackText = TextStyle(
  fontFamily: 'Bold',
  fontSize: 14,
);
TextStyle boldLargeBlackText = TextStyle(
  fontFamily: 'Bold',
  fontSize: 15,
);

TextStyle boldXLBlackText = TextStyle(
  fontFamily: 'Bold',
  fontSize: 16,
);

TextStyle boldXXLBlackText = TextStyle(
  fontFamily: 'Bold',
  fontSize: 18,
);

TextStyle boldXXXLBlackText = TextStyle(
  fontFamily: 'Bold',
  fontSize: 20,
);

TextStyle boldXXXXLBlackText = TextStyle(
  fontFamily: 'Bold',
  fontSize: 22,
);

//Grey
TextStyle boldLargeRedText =
    TextStyle(fontFamily: 'Bold', fontSize: 15, color: Colors.red);

TextStyle boldXLRedText =
    TextStyle(fontFamily: 'Bold', fontSize: 16, color: Colors.red);

TextStyle boldXXLRedText =
    TextStyle(fontFamily: 'Bold', fontSize: 18, color: Colors.red);

TextStyle boldXXXLRedText =
    TextStyle(fontFamily: 'Bold', fontSize: 20, color: Colors.red);

//Green
TextStyle boldLargeGreenText =
    TextStyle(fontFamily: 'Bold', fontSize: 15, color: Colors.green);

TextStyle boldXLGreenText =
    TextStyle(fontFamily: 'Bold', fontSize: 16, color: Colors.green);

TextStyle boldXXLGreenText =
    TextStyle(fontFamily: 'Bold', fontSize: 18, color: Colors.green);

TextStyle boldXXXLGreenText =
    TextStyle(fontFamily: 'Bold', fontSize: 20, color: Colors.green);


    //Grey
