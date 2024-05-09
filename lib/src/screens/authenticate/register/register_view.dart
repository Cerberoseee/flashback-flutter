import 'package:flutter/material.dart';
import 'package:flutter_final/src/screens/authenticate/login/login_view.dart';
import 'package:flutter_final/src/services/user_services.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: SingleChildScrollView(
        child: Container(
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
  final _formKey = GlobalKey<FormState>();
  String password = "";
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false, _isUsernameExist = false, _isEmailExist = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
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
              if (_isUsernameExist) {
                return 'Username already exists!';
              }
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
              if (_isEmailExist) {
                return 'Email already exists!';
              }
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
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        _signUp();
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
                    "SIGN UP",
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

  void _signUp() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String email = _emailController.text.trim();
    setState(() {
      _isLoading = true;
    });
    isEmailTaken(email).then((isEmailExist) {
      isUsernameTaken(username).then((isUsernameExist) {
        setState(() {
          _isUsernameExist = isUsernameExist;
          _isEmailExist = isEmailExist;
        });
        if (!isUsernameExist && !isEmailExist) {
          createUser(email, username, password).then((value) {
            if (value) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) => const LoginView()), ModalRoute.withName('/login'));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong, please try again!")));
            }
          });
        } else {
          _formKey.currentState?.validate();
          setState(() {
            _isUsernameExist = false;
            _isEmailExist = false;
            _isLoading = false;
          });
        }
      });
    });
  }
}
