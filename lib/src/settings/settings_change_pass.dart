import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/user_services.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  static const routeName = '/change-password';
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
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 80,
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF222831),
          child: const FormWidget(),
        ),
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
  bool _obscureText = true;
  bool _obscureTextVerify = true;
  bool _obscureTextCurr = true;
  final _formKey = GlobalKey<FormState>();
  String password = "";
  final TextEditingController _passwordController = TextEditingController(), _currPasswordController = TextEditingController();
  bool _isLoading = false, _isCurrWrong = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _currPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CHANGING YOUR PASSWORD",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _currPasswordController,
            obscureText: _obscureTextCurr,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Enter your current password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureTextCurr ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _obscureTextCurr = !_obscureTextCurr;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          _isCurrWrong
              ? Text(
                  "Wrong current password, please enter again!",
                  style: TextStyle(
                    color: Colors.red[400],
                  ),
                )
              : Container(),
          const SizedBox(height: 10),
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
              labelText: 'Enter your new password',
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
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please re-enter your new password';
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
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        _changePassword();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF76ABAE),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "SUBMIT",
                    style: TextStyle(
                      color: !_isLoading ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _changePassword() {
    String password = _passwordController.text.trim();
    setState(() {
      _isLoading = true;
      _isCurrWrong = false;
    });

    updatePassword(FirebaseAuth.instance.currentUser!, password, _currPasswordController.text.trim()).then((res) {
      setState(() {
        _isLoading = false;
      });
      if (res) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password updated successfully!")));
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
          _isCurrWrong = true;
        });
      }
    });
  }
}
