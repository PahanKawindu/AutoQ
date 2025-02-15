import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:test_flutter1/common/common_widget.dart';
import 'package:test_flutter1/screens/signup_screen.dart';
import 'package:test_flutter1/screens/welcome_screen.dart';
import '../controller/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false; // Boolean to track password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF34A0A4),
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF34A0A4),
        centerTitle: true,
        automaticallyImplyLeading: false, // This removes the back button
      ),
      body: Stack(
        children: [
          // Background Scrollable Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60.0), // Adjusted for spacing
                // Header Text
                const SizedBox(
                  width: 350.0,
                  child: Center(
                    child: Text(
                      'Fast, Easy, Reliable \n Log In to Your Spot in Line!',
                      style: TextStyle(fontSize: 20.0, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 50.0),

                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.close,
                          size: 30.0,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      Common_widget.buildTextFormField(
                        controller: emailController,
                        prefixIcon: Icons.email,
                        labelText: 'Email',
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26.0),
                      Center(
                        child: Common_widget.buildButton(
                          "Login",
                              () async {
                            LoginController controller = LoginController();
                            await controller.loginUser(
                              emailController.text,
                              passwordController.text,
                              context,
                            );
                          },
                          const Color(0xFF34A0A4),
                          Colors.white,
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                            children: [
                              TextSpan(
                                text: "Signup",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16.0,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const SignupScreen(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
