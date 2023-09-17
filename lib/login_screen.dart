import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:scanner/scanner_screen.dart'; // Import the SubjectListScreen file

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo? androidInfo;
      IosDeviceInfo? iosInfo;

      if (Theme.of(context).platform == TargetPlatform.android) {
        androidInfo = await deviceInfo.androidInfo;
      } else {
        iosInfo = await deviceInfo.iosInfo;
      }

      final deviceModel = androidInfo?.model ?? iosInfo?.model ?? 'Unknown';

      final response = await http.post(
        Uri.parse(
            'http://192.168.137.1/att-app/function/api/api.php'), // Replace with your API endpoint
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
          'device_name': deviceModel, // Include device name in the request
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        for (final Map<String, dynamic> messageData in responseData) {
          final message = messageData['message'];
          final userRole = messageData['user_role'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$message'),
            ),
          );

          // Check user role and navigate to SubjectListScreen for instructors
          if (userRole == 'instructor') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    SubjectListScreen(), // Replace with your SubjectListScreen widget
              ),
            );
          }
        }
      } else {
        // Handle non-200 status code (e.g., server error)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server error: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      // Handle other errors, show an error message, etc.
      print('Error during login: $e'); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during login: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }




@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Login'),
      backgroundColor: Color(0xFF0A28D8),
    ),
    body: Center( // Center the content vertically and horizontally
      child: SingleChildScrollView( // Wrap your Column with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 120,
                width: 120,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _usernameController,
                labelText: 'ID Number',
                icon: Icons.person,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                icon: Icons.lock,
                obscureText: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _login(context),
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Login'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String labelText,
  required IconData icon,
  bool obscureText = false,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.grey,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        border: InputBorder.none,
        icon: Icon(icon),
      ),
    ),
  );
}

}
