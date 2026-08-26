import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: const Text('Student Home'),
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
