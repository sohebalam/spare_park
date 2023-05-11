import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sparepark/services/auth_service.dart';

class CustomLoginDialog extends StatelessWidget {
  final _formKey1 = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return AlertDialog(
      title: Text('Custom Login'),
      content: Form(
        key: _formKey1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                authService.signInWithEmailAndPassword(
                  emailController.text,
                  passwordController.text,
                );
                Navigator.pop(context);
              },
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
