import 'package:attend_lite/screens/teacher_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'verify_email.dart';
import 'student_home.dart';
import '../data/departments.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formkey = GlobalKey<FormState>();
  String selectedRole = "student";
  bool isLogin = true;
  bool isLoading = false;
  String? selectedDepartment = departments.first;
  // controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollController = TextEditingController();

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final name = nameController.text.trim();
    final roll = rollController.text.trim();
    final dept = selectedDepartment;

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        UserCredential credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        String uid = credential.user!.uid;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        String userRole = userDoc['role'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                userRole == "student" ? StudentHome() : TeacherHome(),
          ), // for now homescreen
        );
      } else {
        UserCredential credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        credential.user!.sendEmailVerification();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
              'uid': credential.user!.uid,
              'name': name,
              'email': email,
              'role': selectedRole,
              'roll': selectedRole == 'student' ? roll : null,
              'dept': dept,
              'createAt': FieldValue.serverTimestamp(),
            });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyEmail(role: selectedRole),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // everything functional is here
    return Scaffold(
      appBar: _appBar(),
      body: Center(
        child: Container(
          // box hold the form
          height: 600,
          width: 350,
          decoration: BoxDecoration(
            color: const Color.fromARGB(190, 96, 125, 139),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 3,
                offset: Offset(2, 6),
              ),
            ],
          ),
          child: Padding(padding: const EdgeInsets.all(12.0), child: _form()),
        ),
      ),
    );
  }

  Form _form() {
    return Form(
      key: _formkey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color.fromARGB(255, 68, 49, 58),
            ),
          ),
          // SizedBox(height: 20,),
          if (!isLogin) ...[
            TextFormField(
              controller: nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            DropdownButtonFormField<String>(
              value: selectedRole,

              items: const [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
              ],
              onChanged: (value) => setState(() => selectedRole = value!),
              decoration: const InputDecoration(
                labelText: 'I am a',
                labelStyle: TextStyle(
                  fontSize: 28,
                  color: const Color.fromARGB(255, 11, 23, 29),
                ),
              ),
            ),

            if (selectedRole == 'student') ...[
              TextFormField(
                controller: rollController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your roll number';
                  }
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Roll Number'),
              ),
            ],
            DropdownButtonFormField<String>(
              value: selectedDepartment,
              isExpanded: true,
              items: departments.map((dept) {
                return DropdownMenuItem<String>(
                  value: dept,
                  child: Text(dept, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a department';
                }
                return null;
              },
              decoration: const InputDecoration(labelText: 'Department'),
            ),
          ],

          _emailTextForm(),

          _passwordTextForm(),

          _logInbutton(),

          _loginSwitchButton(),
        ],
      ),
    );
  }

  TextButton _loginSwitchButton() {
    return TextButton(
      onPressed: () {
        emailController.clear();
        passwordController.clear();

        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(
        isLogin
            ? "Don't have an account? Register"
            : 'Already registered? Login',

        style: TextStyle(
          fontSize: 20,
          color: const Color.fromARGB(255, 22, 8, 32),
        ),
      ),
    );
  }

  ElevatedButton _logInbutton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: () {
        if (isLoading) return;
        if (_formkey.currentState!.validate()) {
          print(emailController.text);
          print(passwordController.text);
          loginUser();
        }
      },
      child: isLoading
          ? const CircularProgressIndicator()
          : Text(
              isLogin ? "Log In" : "Register",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
    );
  }

  TextFormField _passwordTextForm() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }

        if (value.length < 6) {
          return 'At least 6 charecters';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(
          color: const Color.fromARGB(255, 11, 23, 29),
          fontSize: 20,
        ),
        hintText: 'Use strong password',
        hintStyle: TextStyle(color: Colors.black54, fontSize: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  TextFormField _emailTextForm() {
    return TextFormField(
      controller: emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        // Regular expression for email validation
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: TextStyle(
          color: const Color.fromARGB(255, 11, 23, 29),
          fontSize: 20,
        ),
        hintText: 'Ex: you@example.com',
        hintStyle: TextStyle(color: Colors.black54, fontSize: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: const Color.fromARGB(189, 128, 39, 136),
      toolbarHeight: 100,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),

      title: const Text(
        'AttendLite',
        style: TextStyle(
          fontSize: 40,
          color: Color.fromARGB(255, 41, 36, 63),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
