import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trying_out/loginPage.dart';
import 'package:trying_out/main.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [

                /// Top Part (White)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text("Have an account? "),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()),);
                        },
                        style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 187, 217, 224),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
                              padding: EdgeInsets.all(1.0)
                        ),
                        child: const Text('Log In'),
                      )
                    ],
                  ),
                ),

                const SizedBox(height:  100,),

                /// Bottom Part 
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 180, 
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E5663),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.elliptical(300, 150),
                      topRight: Radius.elliptical(300, 150),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        const SizedBox(height: 50),

                        const Center(
                          child: Text(
                            'Welcome To LockerPAL 3000',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        _inputField('Email / Phone Number', controller: emailController),
                        const SizedBox(height: 15),
                        _inputField('Password', obscure: true, controller: passwordController),
                        const SizedBox(height: 15),
                        _inputField('Confirm Password', obscure: true, controller: confirmPasswordController),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            signUpUser();
                          },
                          
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 187, 217, 224),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),

                          child: Text("Sign Up"),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        }
      )
    );
  }

  Future<void> signUpUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Navigate only if success
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuth Error: ${e.code}");
      print("Message: ${e.message}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Sign up failed")),
      );
    }
  }

  Widget _inputField(String hint, {bool obscure = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
