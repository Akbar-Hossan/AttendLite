import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  List<String> subjects = [];
  bool isAdding = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadSubjects();
  }

  Future<void> loadSubjects() async {
    final String teacherId = FirebaseAuth.instance.currentUser!.uid;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      for (var doc in snapshot.docs) {
        subjects.add(doc['name']);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
    setState(() {});
  }

  final TextEditingController subjectNameController = TextEditingController();

  @override
  void dispose() {
    subjectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ListView(
                  children: [
                    for (String subject in subjects)
                      Padding(
                        padding: const EdgeInsets.all(10),
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
                          child: ListTile(title: Text(subject)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setDialogState) {
                  return AlertDialog(
                    title: Text('Add Subject'),
                    content: TextFormField(
                      controller: subjectNameController,
                      decoration: InputDecoration(
                        labelText: 'Subject name:',
                        labelStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                        hintText: 'Bangla',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(143, 69, 52, 146),
                        ),
                      ),
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final sub = subjectNameController.text.trim();

                              String teacherid =
                                  FirebaseAuth.instance.currentUser!.uid;

                              if (sub.isEmpty || isAdding) {
                                return;
                              }
                              setDialogState(() {
                                isAdding = true;
                              });

                              try {
                                await FirebaseFirestore.instance
                                    .collection('subjects')
                                    .add({'name': sub, 'teacherId': teacherid});

                                setDialogState(() {
                                  subjects.add(sub);
                                });

                                subjectNameController.clear();
                                Navigator.pop(context);
                              } on Exception catch (e) {
                                // later
                              } finally {
                                setState(() {
                                  isAdding = false;
                                });
                              }
                            },
                            child: isAdding
                                ? const CircularProgressIndicator()
                                : Text("Add"),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // This the AppBar
  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: const Text('Teacher Home'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (!context.mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
        ),
      ],
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
