import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:scanner/scanner_screen.dart'; // Import the ScannerScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkConnectionAndNavigate();
  }

  Future<void> _checkConnectionAndNavigate() async {
    bool isInternetAvailable = await InternetConnectionChecker().hasConnection;

    if (!isInternetAvailable) {
      _showAlertDialog(
        'Error',
        'Message not available. Please check your internet connection.',
      );
      return;
    }

    bool isServerOnline = await _checkServerConnection();

    if (!isServerOnline) {
      _showAlertDialog(
        'Error',
        'Server is not online. Please try again later.',
      );
      return;
    }

    _navigateToScannerScreen();
  }

  Future<bool> _checkServerConnection() async {
    // Replace with your server URL
    final apiUrl = 'http://192.168.137.1/att-app/function/api/api.php';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _navigateToScannerScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SubjectListScreen()),
    );
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _exitApp(); // Exit the app
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _exitApp() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/psu_img.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                height: 40,
                color: Color(0xFF0A28D8),
              ),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              Container(
                height: 40,
                color: Color(0xFFFFE047),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
