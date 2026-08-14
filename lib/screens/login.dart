import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formkey = GlobalKey<FormState>();

  // controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    }
  }

  @override
  void dispose() {
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
          height: 450,
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
          TextFormField(
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // SizedBox(height: 16,),
          TextFormField(
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formkey.currentState!.validate()) {
                print(emailController.text);
                print(passwordController.text);
                loginUser();
              }
            },
            child: Text(
              "Log In",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
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
