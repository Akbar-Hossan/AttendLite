import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeacherAttendance extends StatefulWidget {
  final String sessionId;
  final String subjectId;
  const TeacherAttendance({
    super.key,
    required this.sessionId,
    required this.subjectId,
  });

  @override
  State<TeacherAttendance> createState() => _TeacherAttendanceState();
}

class _TeacherAttendanceState extends State<TeacherAttendance> {
  List<Map<String, dynamic>> students = [];
  Map<String, bool> attendance = {};
  bool isSaving = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  // Load the students that registered in this subject
  Future<void> loadStudents() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('registrations')
        .where('subjectId', isEqualTo: widget.subjectId)
        .get();

    students.clear();

    for (var registration in querySnapshot.docs) {
      String studentId = registration['studentId'];

      DocumentSnapshot student = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .get();

      students.add({
        'studentId': studentId,
        'name': student['name'],
        'roll': student['roll'],
      });
    }

    students.sort((a, b) {
      return a['roll'].compareTo(b['roll']);
    });

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Save students attendance at once
  Future<void> saveAttendance() async {
    // check every student has been marked
    if (attendance.length != students.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please mark Present or Absent for every student"),
        ),
      );
      return;
    }
    setState(() {
      isSaving = true;
    });
    try {
      for (var student in students) {
        String studentId = student['studentId'];

        await FirebaseFirestore.instance
            .collection('attendance')
            .doc('${widget.sessionId}_$studentId')
            .set({
              'studentId': studentId,
              'sessionId': widget.sessionId,
              'subjectId': widget.subjectId,
              'present': attendance[studentId],
            });
      }
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance saved successfully")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (var student in students)
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
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(student['name']),
                            subtitle: Text('Roll: ${student['roll']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      attendance[student['studentId']] = true;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        attendance[student['studentId']] == true
                                        ? Colors.green
                                        : null,
                                  ),
                                  child: const Text('Present'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      attendance[student['studentId']] = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        attendance[student['studentId']] ==
                                            false
                                        ? Colors.red
                                        : null,
                                  ),
                                  child: const Text('Absent'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isSaving ? null : saveAttendance,
        icon: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: Text(isSaving ? 'Saving...' : 'Save Attendance'),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text('Attendance'),
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Color.fromARGB(255, 179, 47, 179),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
