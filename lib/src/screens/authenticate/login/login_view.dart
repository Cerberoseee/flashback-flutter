import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:flutter_final/src/widgets/app_bar_widget.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  static const routeName = '/';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      body: Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFF222831),
        child: const LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscureText = true;
  final FirebaseAuthService _auth = FirebaseAuthService();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "LOGIN VIA YOUR ACCOUNT",
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter your username',
              labelStyle: TextStyle(
                color: Colors.white,
              )),
        ),
        const SizedBox(height: 18),
        TextFormField(
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelStyle: const TextStyle(
              color: Colors.white,
            ),
            border: const OutlineInputBorder(),
            labelText: 'Enter your password',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _singIn(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF76ABAE),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(20),
            ),
            child: const Text(
              "LOG IN",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/forgot-password");
              },
              child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  "Forget your password?",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/register");
              },
              child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  "Don't have an account?",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _singIn(context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String email = _emailController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);
    print("User is successfully Log In");

    Navigator.popAndPushNamed(context, "/home");

    // if(user != null) {
    //   print("User is successfully created");
    //   Navigator.pushNamed(context, "/home");
    // } else {
    //   print("Error");
    // }
  }
}
