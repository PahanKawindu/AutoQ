import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter1/common/common_widget.dart';
import 'package:test_flutter1/controller/signup_controller.dart';
import 'package:test_flutter1/screens/login_screen.dart';
import 'package:test_flutter1/screens/welcome_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final contactNoController = TextEditingController();

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF46C2AF),
      appBar: AppBar(
        title: const Text('SIGN UP'),
        backgroundColor: const Color(0xFF46C2AF),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const SizedBox(
              width: 350.0,
              child: Center(
                child: Text(
                  'Crafting Your Perfect Space, \n One Shelf at a Time!',
                  style: TextStyle(fontSize: 20.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              width: double.infinity,
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
                  const SizedBox(height: 25.0),
                  Common_widget.buildTextFormField(
                    controller: firstNameController,
                    prefixIcon: Icons.person,
                    labelText: 'First Name',
                  ),
                  const SizedBox(height: 23.0),
                  Common_widget.buildTextFormField(
                    controller: lastNameController,
                    prefixIcon: Icons.person,
                    labelText: 'Last Name',
                  ),
                  const SizedBox(height: 23.0),
                  Common_widget.buildTextFormField(
                    controller: contactNoController,
                    prefixIcon: Icons.call,
                    labelText: 'Contact',
                  ),
                  const SizedBox(height: 23.0),
                  Common_widget.buildTextFormField(
                    controller: emailController,
                    prefixIcon: Icons.email,
                    labelText: 'Email',
                  ),
                  const SizedBox(height: 23.0),
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
                  const SizedBox(height: 20.0),
                  Center(
                    child: Common_widget.buildButton(
                      "Sign Up",
                          () async {
                        SignupController controller = SignupController();
                        await controller.signUpUser(
                          email: emailController.text,
                          password: passwordController.text,
                          firstName: firstNameController.text,
                          lastName: lastNameController.text,
                          contactNo: contactNoController.text,
                          context: context,
                        );
                      },
                      const Color(0xFF46C2AF),
                      Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                        children: [
                          TextSpan(
                            text: "login",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16.0,
                              fontStyle: FontStyle.italic,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
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
    );
  }
}
