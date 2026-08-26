import 'package:attend_lite/screens/student_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'teacher_home.dart';

class VerifyEmail extends StatefulWidget {
  final String role;
  const VerifyEmail({
    super.key,
    required this.role,
    });
  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Please verify your email address',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;

                await user?.reload();

                user = FirebaseAuth.instance.currentUser;

                if (user != null && user.emailVerified) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) {
                      if(widget.role == 'teacher') {
                        return TeacherHome();
                      } else {
                        return StudentHome();
                      }
                    }),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Email is not verified yet.(Check spam box)',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Email verified'),
            ),
          ],
        ),
      ),
    );
  }
}
