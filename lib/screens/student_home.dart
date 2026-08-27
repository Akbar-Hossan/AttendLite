import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  String studentDept = '';
  List<Map<String, dynamic>> subjects = [];
  Set<String> registeredSubjects = {};

  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadStudentData();
  }

  // Student Department showing
  Future<void> loadStudentData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    studentDept = snapshot['dept'];

    await loadSubjects();

    await loadRegistrations();

    if (mounted) {
      setState(() {});
    }
  }

  // Load Subjects that belong to the student's Department
  Future<void> loadSubjects() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('subjects')
        .where('department', isEqualTo: studentDept)
        .get();

    subjects.clear();

    for (var sub in snapshot.docs) {
      String teacherId = sub['teacherId'];

      DocumentSnapshot teacher = await FirebaseFirestore.instance
          .collection('users')
          .doc(teacherId)
          .get();

      subjects.add({
        'id': sub.id,
        'name': sub['name'],
        'teacher': teacher['name'],
        'teacherDept': teacher['dept'],
      });
    }
    print('Number of Subjects: ${subjects.length}');
    print('Subjects: $subjects');
  }

  // Register in a Subject
  Future<void> registerSubject(Map<String, dynamic> subject) async {
    // show Confirmation pop up for registration
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Register Subject'),
          content: Text(
            'Are you sure you want to register for ${subject['name']}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    // if no then don't register
    if (confirm != true) return;

    // prevent multiple registraion in one subject
    String registrationId = '${uid}_${subject['id']}';

    DocumentReference registrationRef = FirebaseFirestore.instance
        .collection("registrations")
        .doc(registrationId);

    DocumentSnapshot registration = await registrationRef.get();

    // once registered avoid request
    if (registration.exists) {
      return;
    }

    await registrationRef.set({
      'studentId': uid,
      'subjectId': subject['id'],
      'registeredAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      setState(() {
        registeredSubjects.add(subject['id']);
      });
    }
  }
  // after login load the user registered subjects
  Future<void> loadRegistrations() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('registrations')
        .where('studentId', isEqualTo: uid)
        .get();

        registeredSubjects.clear();

        for( var sub in querySnapshot.docs){
          registeredSubjects.add(sub['subjectId']);
        }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: ListView(
        children: [
          for (var subject in subjects)
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
                      title: Text(subject['name'].toString()),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Teacher: ${subject['teacher']}'),
                          Text('Department: ${subject['teacherDept']}'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: registeredSubjects.contains(subject['id'])
                            ? ElevatedButton(
                                onPressed: () {
                                  //Open attendance page
                                },
                                child: Text('View'),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  registerSubject(subject);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student Home',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            studentDept,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (!context.mounted) return;
            Navigator.pushReplacement(
              (context),
              MaterialPageRoute(builder: (context) => const Login()),
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
