import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'dart:io';

import 'package:scanner/login_screen.dart';
import 'package:scanner/scanner.dart';
import 'subject.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subject List',
      theme: ThemeData(
        primaryColor: Color(0xFF0A28D8), // Set your custom primary color here
      ),
      home: SubjectListScreen(),
    );
  }
}

class SubjectListScreen extends StatefulWidget {
  @override
  _SubjectListScreenState createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  String deviceName = "";
  List<Subject> subjects = [];

  Future<void> fetchDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        setState(() {
          deviceName = androidInfo.model.trim();
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        setState(() {
          deviceName = iosInfo.name.trim();
        });
      }
    } catch (e) {
      print("Error fetching device info: $e");
    }
  }

  Future<void> fetchSubjects() async {
    try {
      final encodedDeviceName = Uri.encodeQueryComponent(deviceName);
      final apiUrl =
          'http://192.168.137.1/att-app/function/api/viewSubjectAPI.php?device_name=$encodedDeviceName';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final subjectData = json.decode(response.body);

        if (subjectData['success'] == true) {
          final subjectList = subjectData['subjects'];

          setState(() {
            subjects = List<Subject>.from(
                subjectList.map((subject) => Subject.fromJson(subject)));
            // subjects.forEach((subject) {
            //   print('Subject Name: ${subject.subjectName}');
            //   print('Subject Code: ${subject.subjectCode}');
            // });
          });
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content:
                    Text('Failed to fetch subjects: ${subjectData['error']}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(
                  'Failed to fetch subjects. Status Code: ${response.statusCode}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while fetching subjects: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showSubjectDetails(Subject subject) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return CombinedScreen(subject: subject);
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    await fetchDeviceInfo();
    await fetchSubjects();
  }

  @override
  void initState() {
    super.initState();
    _refreshData(); // Fetch data initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Subjects'),
        backgroundColor: Color(0xFF0A28D8),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: subjects.isEmpty
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 1.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 6.0, horizontal: 14.0),
                    child: ListTile(
                      title: Text(
                        '${subjects[index].subjectCode} ${subjects[index].subjectName}', // Add subject code to the title
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Year: ${subjects[index].subjectYear}, Section: ${subjects[index].subjectSection}',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      onTap: () {
                        _showSubjectDetails(subjects[index]);
                      },
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Device Name: $deviceName",
            // style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
