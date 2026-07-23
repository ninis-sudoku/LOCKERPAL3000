import 'package:flutter/material.dart';
import 'package:trying_out/loginPage.dart';

class start_page extends StatelessWidget {
  const start_page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Align(
              alignment: Alignment.center,
              child: Image.asset('assets/andiferru_logo.png'),
            ),

            const SizedBox(height: 10,),

            // Button "Get Started"
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()),);
              }, 
              label: const Text("Get Started"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 187, 217, 224),
                shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
                padding: EdgeInsets.fromLTRB(100, 0, 100, 0)
              ),
            )
          ],
        ),
      ),
    );
  }
}
