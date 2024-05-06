import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_final/src/services/user_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  static const routeName = '/';
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
  final _auth = FirebaseAuth.instance;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false, _showVerifyMessage = false, _wrongLogin = false;

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
          controller: _emailController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter your username or email',
              labelStyle: TextStyle(
                color: Colors.white,
              )),
        ),
        const SizedBox(height: 18),
        TextFormField(
          controller: _passwordController,
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
            onPressed: _isLoading ? null : () => _signIn(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF76ABAE),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.all(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "LOGIN",
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
        _showVerifyMessage
            ? Text(
                "Please verify your account via your email",
                style: TextStyle(
                  color: Colors.red[400],
                ),
              )
            : Container(),
        _wrongLogin
            ? Text(
                "Incorrect username, email or password",
                style: TextStyle(
                  color: Colors.red[400],
                ),
              )
            : Container(),
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
        const SizedBox(height: 12),
        Row(
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/verify-mail");
              },
              child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  "Verify your email",
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
        ),
        const SizedBox(height: 36),
        const Text(
          "OR YOU CAN LOGIN VIA",
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(
              const EdgeInsets.all(24),
            ),
            backgroundColor: MaterialStateProperty.all(
              const Color.fromARGB(255, 30, 61, 63),
            ),
          ),
          onPressed: () async {
            await signInWithGoogle().then((value) {
              if (value) {
                Navigator.popAndPushNamed(context, "/home");
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong, please try again!")));
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Image.asset("/images/google_logo.png"),
              ),
              const Text(
                "GOOGLE ACCOUNT",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(
              const EdgeInsets.all(24),
            ),
            backgroundColor: MaterialStateProperty.all(
              const Color.fromARGB(255, 30, 61, 63),
            ),
          ),
          onPressed: () async {
            await signInWithFacebook().then((value) {
              if (value) {
                Navigator.popAndPushNamed(context, "/home");
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something went wrong, please try again!")));
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Image.asset("/images/facebook_logo.png"),
              ),
              const Text(
                "FACEBOOK ACCOUNT",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _signIn(context) async {
    final logger = Logger();
    String password = _passwordController.text.trim();
    String email = _emailController.text.trim();
    User? user;
    setState(() {
      _isLoading = true;
      _showVerifyMessage = false;
      _wrongLogin = false;
    });

    if (!isEmail(email)) {
      email = await getEmailFromUsername(email) ?? "";
    }

    if (email != "") {
      try {
        UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
        user = credential.user;
      } catch (e) {
        logger.e("Error pasword or username or email");
        setState(() {
          _wrongLogin = true;
        });
      }
    }
    //logger.e(user);
    setState(() {
      _isLoading = false;
    });
    if (user != null) {
      if (user.emailVerified) {
        logger.i("User is successfully Log In");
        Navigator.popAndPushNamed(context, "/home");
      } else {
        setState(() {
          _showVerifyMessage = true;
        });
      }
    } else {
      logger.e("Error pasword or username or email");
      setState(() {
        _wrongLogin = true;
      });
    }
  }
}
