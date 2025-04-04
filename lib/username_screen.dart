// username_screen.dart
import 'package:authk/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final TextEditingController usernameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String errorMessage = '';
  String successMessage = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill username if available
    if (authService.value.currentUser != null && 
        authService.value.currentUser!.displayName != null) {
      usernameController.text = authService.value.currentUser!.displayName!;
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  void updateUsername() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });
    
    try {
      await authService.value.updateUsername(
        username: usernameController.text,
      );
      setState(() {
        successMessage = 'Username updated successfully!';
        isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'Failed to update username';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text("Update Username"),
        backgroundColor: Colors.greenAccent[400],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Update Username",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Form(
                key: formKey,
                child: Column(children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.black54,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  if (successMessage.isNotEmpty)
                    Text(
                      successMessage,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: isLoading 
                        ? null 
                        : () {
                            if (formKey.currentState!.validate()) {
                              updateUsername();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[400],
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Update Username",
                            style: TextStyle(color: Colors.black),
                          ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}