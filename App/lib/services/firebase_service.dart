import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class WeekData {
  final String day;
  final int lockCount;
  final int unlockCount;

  WeekData({
    required this.day,
    required this.lockCount,
    required this.unlockCount,
  });
}

class FirebaseService {
  static final FirebaseDatabase database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://lockerpal-3000-default-rtdb.asia-southeast1.firebasedatabase.app",
  );

  Stream<bool> lockerStatusStream() {
    final ref = database.ref("smartlocker/status");
    
    return ref.onValue.map((event) {
      final value = event.snapshot.value as String?;
      return value == "Locked";
    });
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> incrementUnlock(bool isLocked) async {
    final today = DateTime.now();
    final dateKey = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final refUnlockCount = database.ref("statistics/$dateKey/unlockCount");
    final refLockCount = database.ref("statistics/$dateKey/lockCount");

    if (!isLocked) {
      await refUnlockCount.runTransaction((currentUnlockData) {
        final current = (currentUnlockData as num?)?.toInt() ?? 0;
        return Transaction.success(current + 1);
      });
    }
    
    if (isLocked) {
      await refLockCount.runTransaction((currentLockData) {
        final current = (currentLockData as num?)?.toInt() ?? 0;
        return Transaction.success(current + 1);
      });
    }
  } 

  Future<void> lockerStatus(bool isLocked) async {
    final ref = database.ref("smartlocker/status");
    final commref = database.ref("smartlocker/command");

    final logsRef = FirebaseService.database.ref("logs");

    final newStatus = isLocked ? "Unlocked" : "Locked";

    await ref.runTransaction((currentData) {
      return Transaction.success(newStatus);
    });

    await logsRef.push().set({
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "status": newStatus,
    });

    await commref.set({
      "action": "unlock",
      "source": "app",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<bool> isLocked() async {
    final snapshot = await FirebaseService.database.ref("smartlocker/status").get();
    return snapshot.value == "Locked";
  }

  Future<void> setLocked(bool locked) async {
    await database.ref("smartlocker/status").set(locked ? "Locked" : "Unlocked");
  }

  Future<void> getAverageOpenTime() async {

    final now = DateTime.now();

    // Start of today
    final startOfDay = DateTime(now.year, now.month, now.day);

    // Start of tomorrow
    final endOfDay = startOfDay.add(Duration(days: 1));

    int startTimestamp = startOfDay.millisecondsSinceEpoch;
    int endTimestamp = endOfDay.millisecondsSinceEpoch;

    final snapshot = await database.ref("logs").orderByChild("timestamp").startAt(startTimestamp).endAt(endTimestamp).get();

    final today = DateTime.now();
    final dateKey = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final snapshotAvgOpenTime = await database.ref("statistics/$dateKey/avgOpenTime").get();

    if (!snapshotAvgOpenTime.exists) {
      await database.ref("statistics/$dateKey/avgOpenTime").set(0);
      return;
    }

    final data = Map<dynamic, dynamic>.from(snapshot.value as dynamic);

    List<Map<String, dynamic>> logs = [];

    data.forEach((key, value) {
      logs.add({
        "timestamp": value["timestamp"],
        "status": value["status"],
      });
    });

    logs.sort((a, b) => a["timestamp"].compareTo(b["timestamp"]));

    int? unlockTime;
    int totalDuration = 0;
    int sessionCount = 0;

    for (var log in logs) {
      if (log["status"] == "Unlocked") {
        unlockTime = (log["timestamp"] as num).toInt();
      } else if (log["status"] == "Locked" && unlockTime != null) {
        int lockTime = (log["timestamp"] as num).toInt();

        totalDuration += lockTime - unlockTime;
        sessionCount++;
        unlockTime = null;
      }
    }

    double milliseconds = totalDuration / sessionCount;

    int seconds = (milliseconds / 1000).round();
    int minutes = seconds ~/ 60;

    await database.ref("statistics/$dateKey/avgOpenTime").set(minutes);
  }

  Future<List<WeekData>> getWeeklyStats() async {
    final statRef = FirebaseDatabase.instance.ref("statistics");

    DataSnapshot snapshot = await statRef.get();

    Map data = {};
    if (snapshot.value != null) {
      data = snapshot.value as Map;
    }

    List<WeekData> weekList = [];
    DateTime now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      String dateKey = formatDate(day);

      int lock = 0;
      int unlock = 0;

      if (data.containsKey(dateKey)) {
        lock = data[dateKey]['lockCount'] ?? 0;
        unlock = data[dateKey]['unlockCount'] ?? 0;
      }

      weekList.add(
        WeekData(
          day: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][day.weekday - 1],
          lockCount: lock,
          unlockCount: unlock,
        ),
      );
    }

    return weekList;
  }
}
