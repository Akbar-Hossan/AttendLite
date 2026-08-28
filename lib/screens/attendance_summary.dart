import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AttendanceSummary extends StatefulWidget {
  final String subjectId;
  const AttendanceSummary({super.key, required this.subjectId});

  @override
  State<AttendanceSummary> createState() => _AttendanceSummaryState();
}

class _AttendanceSummaryState extends State<AttendanceSummary> {
  bool isLoading = true;
  List<Map<String, dynamic>> sessions = [];
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  String formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();

    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> loadAttendance() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .where('subjectId', isEqualTo: widget.subjectId)
        .get();

    sessions.clear();

    for (var doc in querySnapshot.docs) {
      String attendanceId = '${doc.id}_$uid';

      DocumentSnapshot attendance = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(attendanceId)
          .get();

      if (attendance.exists) {
        sessions.add({
          'id': doc.id,
          'startedAt': doc['startedAt'],
          'present': attendance['present'],
        });
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalSessions = sessions.length;
    int present = sessions
        .where((attendance) => attendance['present'] == true)
        .length;

    double percentage = totalSessions == 0
        ? 0
        : (present / totalSessions) * 100;

    return Scaffold(
      appBar: _appBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Total Sessions',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '$totalSessions',
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
                              'Present',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '$present',
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
                for (var session in sessions)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(15),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date: ${formatDate(session['startedAt'])}',
                            style: const TextStyle(fontSize: 16),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: session['present']
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              session['present'] ? 'Present' : 'Absent',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
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
