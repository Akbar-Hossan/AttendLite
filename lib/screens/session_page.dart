import 'package:attend_lite/screens/teacher_attendance.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'session_summary.dart';

class SessionPage extends StatefulWidget {
  final String subjectId;

  const SessionPage({super.key, required this.subjectId});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> sessions = [];
  final teacherId = FirebaseAuth.instance.currentUser!.uid;
  bool isAdding = false;

  Future<void> loadSessions() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .where('subjectId', isEqualTo: widget.subjectId)
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('startedAt')
        .get();
    sessions.clear();

    for (var doc in snapshot.docs) {
      sessions.add({
        'id': doc.id,
        'subjectId': doc['subjectId'],
        'teacherId': doc['teacherId'],
        'startedAt': doc['startedAt'],
      });
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                for (int i = 0; i < sessions.length; i++)
                  ListTile(
                    leading: CircleAvatar(child: Text('${i + 1}')),
                    title: Text('Session ${i + 1}'),
                    subtitle: Text(
                      DateFormat('dd MMMM yyyy • hh:mm a').format(
                        (sessions[i]['startedAt'] as Timestamp).toDate(),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SessionSummary(
                            sessionId: sessions[i]['id']!,
                            subjectId: widget.subjectId,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
      floatingActionButton: _addSessions(context),
    );
  }

  FloatingActionButton _addSessions(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: Text('New Session'),
                  content: Text(
                    'Are you sure you want to start a new session?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (isAdding) return;

                        setDialogState(() {
                          isAdding = true;
                        });

                        try {
                          DocumentReference sessionRef = await FirebaseFirestore
                              .instance
                              .collection('sessions')
                              .add({
                                'subjectId': widget.subjectId,
                                'teacherId': teacherId,
                                'startedAt': FieldValue.serverTimestamp(),
                              });

                          await loadSessions();

                          final sessionId = sessionRef.id;

                          if (!context.mounted) return;

                          setDialogState(() {
                            isAdding = false;
                          });

                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeacherAttendance(
                                sessionId: sessionId,
                                subjectId: widget.subjectId,
                              ),
                            ),
                          );
                        } catch (e) {
                          setDialogState(() {
                            isAdding = false;
                          });
                        }
                      },
                      child: isAdding
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Start'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Text('Sessions'),
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: const Color.fromARGB(255, 179, 47, 179),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
