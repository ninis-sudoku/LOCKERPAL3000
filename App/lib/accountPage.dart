import 'package:trying_out/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Account",
          style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _profileAvatar()),

              const SizedBox(height: 30),

              const Text("Username", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 6),

              _inputField("Levi Ackerman"),

              const SizedBox(height: 20),

              _menuItem("Phone number"),
              _divider(),
              _menuItem("Email"),
              _divider(),
              _menuItem("Change password"),
              _divider(),
              _menuItem("Save login"),
              
              _logoutButton(context),

              const SizedBox(height: 15),

              _deleteButton(context),

              const SizedBox(height: 20),
            ],
          ),
        ),
      )
    );
  }

  Widget _profileAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.black,
          child: Icon(Icons.person, size: 55, color: Colors.white),
        ),
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(Icons.sync, size: 18),
        ),
      ],
    );
  }

  Widget _inputField(String text) {
    return TextField(
      decoration: InputDecoration(
        hintText: text,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _menuItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, color: Colors.grey)),
    );
  }

  Widget _divider() {
    return const Divider(thickness: 1.2);
  }

  Widget _logoutButton(BuildContext contextLog) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.push(contextLog, MaterialPageRoute(builder: (_) => const LoginPage()),);
        },

        child: const Text(
          "Log Out",
          style: TextStyle(color: Colors.red, fontSize: 18)),
      ),
    );
  }

  Widget _deleteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () => _showDeleteDialog(context),
        child: const Text(
          "Account Deletion",
          style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Delete Account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              ),

              const SizedBox(height: 12),

              const Text(
                "You are about to delete all of the data in your LockerPal 3000 account. Are you absolutely positive?\n\n"
                "Your account and all associated data will be permanently deleted after 30 days. During this period, you may still recover your account. "
                "A confirmation email will be sent once deletion is complete.\n\n"
                "To confirm your identity, please enter your account password.",
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 12),

              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Delete Levi Ackerman’s account",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child:
                      const Text("Cancel", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
