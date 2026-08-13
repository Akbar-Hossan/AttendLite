import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
    void dispose() {
      emailController.dispose();
      passwordController.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Center(
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _form(),
          ),
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
                    print(emailController.text);
                    print(passwordController.text);
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
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        )
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
