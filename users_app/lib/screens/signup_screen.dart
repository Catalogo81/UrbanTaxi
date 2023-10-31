import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users_app/screens/login_screen.dart';

import '../helpers/user_helper.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm() {
    if (nameTextEditingController.text.length < 3) {
      Fluttertoast.showToast(msg: "name must be atleast 3 Characters.");
    } else if (!emailTextEditingController.text.contains("@")) {
      Fluttertoast.showToast(msg: "Email address is not Valid.");
    } else if (phoneTextEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Phone Number is required.");
    } else if (passwordTextEditingController.text.length < 6) {
      Fluttertoast.showToast(msg: "Password must be atleast 6 Characters.");
    } else {
      UserHelpers.saveUserInfo(
        context,
        emailTextEditingController.text.trim(),
        passwordTextEditingController.text.trim(),
        nameTextEditingController.text.trim(),
        phoneTextEditingController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Urban\nTaxi",
                  style: TextStyle(color: Colors.white, fontSize: 72),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Register User",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: nameTextEditingController,
                style: const TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "Name",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: emailTextEditingController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "Email",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: phoneTextEditingController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: "Phone",
                  hintText: "Phone",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: passwordTextEditingController,
                keyboardType: TextInputType.text,
                obscureText: true,
                style: const TextStyle(color: Colors.grey),
                decoration: const InputDecoration(
                  labelText: "Password",
                  hintText: "Password",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  validateForm();
                },
                child: const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ),
              TextButton(
                child: const Text(
                  "Already have an Account? Login Here",
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const LoginScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
