import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'subject.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart'; // Import the fluttertoast package

class CombinedScreen extends StatefulWidget {
  final Subject subject;

  CombinedScreen({required this.subject});

  @override
  _CombinedScreenState createState() => _CombinedScreenState();
}

class _CombinedScreenState extends State<CombinedScreen> {
  List<Barcode> barcodes = [];
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String scannedQRCode = ''; // Store the currently scanned QR code
  String studentName = ''; // Store the student's name

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject.subjectCode} Attendance Scanner'),
        backgroundColor: Color(0xFF0A28D8),
      ),
      body: Column(
        children: [
          // QR Code Scanner
          Expanded(
            flex: 11,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              formatsAllowed: [BarcodeFormat.qrcode],
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).colorScheme.secondary,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          // Scanned QR Code and Student Name
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'QR Code: $scannedQRCode',
                  style: TextStyle(
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10), // Add spacing between QR code and name
                Text(
                  'Student Name: $studentName',
                  style: TextStyle(
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((barcode) async {
      setState(() {
        barcodes.add(barcode);
        scannedQRCode = barcode.code ?? ''; 
      });

      String qrData = barcode.code ?? '';

      try {
        List<String> qrDataParts = qrData.split(',');
        if (qrDataParts.length == 1) {
          String studentNumber = qrDataParts[0];
          print('Extracted Student Number: $studentNumber');

          await sendPostRequest(studentNumber);
        } else {
          print('Invalid QR code format.');
        }
      } catch (e) {
        print('Error processing QR code: $e');
      }
    });
  }

  Future<void> sendPostRequest(String studentNumber) async {
    final url =
        'http://192.168.137.1/att-app/function/api/checkStudent.php'; 
    print('Sending POST request...'); 

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'studentNumber': studentNumber,
          'subject_id': widget.subject.subjectId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Show server message as a toast at the top
        Fluttertoast.showToast(
          msg: responseData['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER, 
          backgroundColor: Color.fromARGB(255, 250, 249, 249),
          textColor: const Color.fromARGB(255, 8, 8, 8),
        );

        setState(() {
          studentName = responseData['lname'] + ', ' + responseData['fname'] + ' ' + responseData['mname']; // Update student's name
        });
      } else {
        // Handle the error
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending POST request: $e');
    }
  }
}
