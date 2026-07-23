import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class LogsPage extends StatelessWidget {
  LogsPage({super.key});

  final DatabaseReference logsRef =
      FirebaseDatabase.instance.ref("logs");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Logs",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: logsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading logs"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No logs found"));
          }

          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          List<Map<String, dynamic>> logsList = [];

          data.forEach((key, value) {
            if (value is Map) {
              final status = value["status"]?.toString() ?? "";
              final method = value["method"]?.toString() ?? "";
              final timestamp = value["timestamp"] ?? 0;

              // Ignore alert, only show Locked and Unlocked by phone/RFID
              if (status == "Locked" ||
                  (status == "Unlocked" &&
                      (method.toLowerCase() == "phone" ||
                          method.toLowerCase() == "rfid"))) {
                logsList.add({
                  "status": status,
                  "method": method,
                  "timestamp": timestamp,
                });
              }
            }
          });

          logsList.sort((a, b) {
            final aTime = a["timestamp"] ?? 0;
            final bTime = b["timestamp"] ?? 0;
            return bTime.compareTo(aTime);
          });

          return ListView.separated(
            itemCount: logsList.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = logsList[index];

              final status = log["status"]?.toString() ?? "";
              final method = log["method"]?.toString() ?? "";
              final timestamp = log["timestamp"] ?? 0;

              final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
              final formattedTime = DateFormat("hh:mm a").format(dateTime);

              IconData icon;
              Color iconColor;
              String title;
              String subtitle;

              if (status == "Locked") {
                icon = Icons.lock;
                iconColor = Colors.green;
                title = "Locked";
                subtitle = "Locker locked properly.";
              } else {
                icon = Icons.lock_open;
                iconColor = Colors.red;
                title = "Unlocked";
                subtitle = "Locker unlocked by $method.";
              }

              return ListTile(
                leading: Icon(
                  icon,
                  color: iconColor,
                  size: 32,
                ),
                title: Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
