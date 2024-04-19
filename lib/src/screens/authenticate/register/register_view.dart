import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/user_services.dart';
import 'package:flutter_final/src/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:flutter_final/src/model/Users.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  static const routeName = '/register';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FlashBack",
          style: GoogleFonts.robotoCondensed(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFEEEEEE),
          ),
        ),
        backgroundColor: const Color(0xFF222831),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFF222831),
        child: const FormWidget(),
      ),
    );
  }
}

class FormWidget extends StatefulWidget {
  const FormWidget({Key? key}) : super(key: key);

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _obscureText = true;
  bool _obscureTextVerify = true;
  final _formKey = GlobalKey<FormState>();
  String password = "";
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "REGISTERING YOUR ACCOUNT",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _usernameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              if (value.length < 6 || value.length > 32) {
                return 'Username must be between 6 and 32 characters';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter your username',
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter your email',
            ),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _passwordController,
            onChanged: (value) {
              setState(() {
                password = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }

              if (value.length < 6) {
                return 'Password must contain at least 6 characters';
              }

              if (!value.contains(RegExp(r'[A-Z]'))) {
                return 'Password must contain at least one uppercase letter';
              }

              if (!value.contains(RegExp(r'[a-z]'))) {
                return 'Password must contain at least one lowercase letter';
              }

              if (!value.contains(RegExp(r'[0-9]'))) {
                return 'Password must contain at least one digit';
              }
              return null;
            },
            obscureText: _obscureText,
            decoration: InputDecoration(
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
          const SizedBox(height: 18),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please re-enter your password';
              }
              if (value != password) {
                return 'Password mismatched!';
              }
              return null;
            },
            obscureText: _obscureTextVerify,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Re-enter your password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureTextVerify ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _obscureTextVerify = !_obscureTextVerify;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Submitting Data')),
                  // );
                  _singUp();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF76ABAE),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(20),
              ),
              child: const Text(
                "SIGN UP",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _singUp() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String email = _emailController.text.trim();
    bool isUsernameExist = await isUsernameTaken(username);
    bool isEmailExist = await isEmailTaken(email);

    if (isUsernameExist) {
      print('Username đã tồn tại');
      return;
    } else if (isEmailExist) {
      print('Email đã được sử dụng');
      return;
    } else {
      User? user = await _auth.signUpWithEmailAndPassword(email, password);

      if (user != null) {
        try {
          Users newUser = Users(
              avatarUrl: 'https://firebasestorage.googleapis.com/v0/b/plashcard2.appspot.com/o/origin.jpg?alt=media&token=d10294c0-e645-49b1-8efd-1afcd9a1b08b',
              email: email,
              language: 'Tiếng Việt',
              name: username,
              status: 'Unblock',
              username: username);

          await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
          print("User is successfully created");
          Navigator.pushNamed(context, "/home");
        } catch (e) {
          print('$e');
        }
      } else {
        print("Đăng ký không thành công");
      }
    }
  }
}
