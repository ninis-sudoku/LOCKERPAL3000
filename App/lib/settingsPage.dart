import 'package:flutter/material.dart';
import 'package:trying_out/accountPage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _profileCard(context),
            const SizedBox(height: 20),
            _sectionCard([
              _tile(Icons.notifications, "Notifications Settings", (){}),
              _tile(Icons.wifi, "Devices", (){}),
            ]),
            const SizedBox(height: 15),
            _sectionCard([
              _tile(Icons.info, "About", (){}),
              _tile(Icons.help, "Help & Support", (){}),
            ]),
          ],
        ),
      ),
    );
  }
}

Widget _profileCard(BuildContext contextprof) {
  return ElevatedButton(
    onPressed: () {
      Navigator.push(contextprof, MaterialPageRoute(builder: (_) => const AccountPage()),);
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      elevation: 4,
      shadowColor: Colors.grey.shade200,
      padding: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Colors.black,
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Username",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black, // important
              ),
            ),
            SizedBox(height: 3),
            Text(
              "example@gmail.com",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.black, // important
        ),
      ],
    ),
  );
}

Widget _sectionCard(List<Widget> children) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: const Color(0xFFE7F7FB),
    ),
    child: Column(children: children),
  );
}

Widget _tile(IconData icon, String title, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE7F7FB), // match your section color
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.black,
          ),
        ],
      ),
    ),
  );
}
