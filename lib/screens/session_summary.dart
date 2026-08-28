import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SessionSummary extends StatefulWidget {
  final String sessionId;
  final String subjectId;
  const SessionSummary({
    super.key,
    required this.sessionId,
    required this.subjectId,
  });
  @override
  State<SessionSummary> createState() => _SessionSummaryState();
}

class _SessionSummaryState extends State<SessionSummary> {
  List<Map<String, dynamic>> attendances = [];

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('sessionId', isEqualTo: widget.sessionId)
        .get();

    attendances.clear();

    for (var attendance in querySnapshot.docs) {
      String studentId = attendance['studentId'];

      DocumentSnapshot student = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .get();

      attendances.add({
        'studentId': studentId,
        'name': student['name'],
        'roll': student['roll'],
        'present': attendance['present'],
      });
    }
    attendances.sort((a, b) => a['roll'].compareTo(b['roll']));

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalStudents = attendances.length;
    int presentStudents = attendances
        .where((attendance) => attendance['present'] == true)
        .length;

    double percentage = totalStudents == 0
        ? 0
        : (presentStudents / totalStudents) * 100;

    return Scaffold(
      appBar: _appBar(),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Total Students',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '$totalStudents',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Present Students',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '$presentStudents',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Percentage',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '${percentage.toInt()}%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (var attendance in attendances)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(31, 69, 52, 146),
                      blurRadius: 2,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(attendance['name']),
                  subtitle: Text(attendance['roll']),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: attendance['present'] ? Colors.green : Colors.red,
                    ),
                    child: Text(
                      attendance['present'] ? 'Present' : 'Absent',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Text('Attendance Summary'),
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: const Color.fromARGB(255, 179, 47, 179),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
