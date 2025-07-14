// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:flutter/services.dart';
// import 'package:matrix_hrms/utility/style/theme.dart';
// //import 'package:qr_code_scanner/qr_code_scanner.dart';

// class QrAttendancePage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _QrAttendancePageState();
// }

// class _QrAttendancePageState extends State<QrAttendancePage> {
//   Barcode? result;
//   QRViewController? controller;
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

//   void _onQRViewCreated(QRViewController controller) {
//     // setState(() =>
//     this.controller = controller;
//     //);
//     controller.scannedDataStream.listen((scanData) {
//       print('scanData-----------${scanData.code}');
//       // setState(() =>
//       result = scanData;
//       // );
//     });
//   }

//   // In order to get hot reload to work we need to pause the camera if the platform
//   // is android, or resume the camera if the platform is iOS.
//   @override
//   void reassemble() {
//     super.reassemble();
//     if (Platform.isAndroid) {
//       print('reassemble pause------');
//       controller!.pauseCamera();
//     } else if (Platform.isIOS) {
//       controller!.resumeCamera();
//     }
//   }

//   void readQr() async {
//     print('readQr--------');
//     if (result != null) {
//       controller!.pauseCamera();
//       print(result!.code);
//       controller!.dispose();
//       // dispose();
//       Map<String, dynamic> qrValue = new Map();
//       qrValue['code'] = result!.code;
//       Navigator.pop(context, qrValue);
//       print('dispose----------');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     //   if (controller != null && mounted) {
//     //     controller!.pauseCamera();
//     //     controller!.resumeCamera();
//     //   }
//     //   return Scaffold();
//     // }
//     readQr();
//     return Scaffold(
//       body: QRView(
//         key: qrKey,
//         onQRViewCreated: _onQRViewCreated,
//         overlay: QrScannerOverlayShape(
//           borderColor: ColorObj.mainColor,
//           borderRadius: 10,
//           borderLength: 30,
//           borderWidth: 10,
//           cutOutSize: 250,
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     controller?.stopCamera();
//     super.dispose();
//   }
// }
