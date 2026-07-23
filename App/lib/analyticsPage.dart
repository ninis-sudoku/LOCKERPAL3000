import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trying_out/services/firebase_service.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {

  final ref = FirebaseService.database.ref();
  late DatabaseReference countRef;

  String selectedTab = "Day";

  late String todayDate;

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();
    todayDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    countRef = FirebaseService.database.ref("statistics/$todayDate");
  }

  // Getting Week's Average Open Time
  List<BarChartGroupData> getWeeklyBarGroups(Map<String, dynamic> statistics) {
    final now = DateTime.now();

    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    Map<int, double> dailyAverages = {
      1: 0, // Mon
      2: 0, // Tue
      3: 0, // Wed
      4: 0, // Thu
      5: 0, // Fri
      6: 0, // Sat
      7: 0, // Sun
    };

    statistics.forEach((dateKey, value) {
      try {
        final date = DateTime.parse(dateKey);

        if (!date.isBefore(startOfWeek) && date.isBefore(endOfWeek)) {
          final dayData = Map<String, dynamic>.from(value);
          final avgOpenTime = (dayData['avgOpenTime'] ?? 0).toDouble();

          dailyAverages[date.weekday] = avgOpenTime;
        }
      } catch (e) {
        // skip invalid date
      }
    });

    return dailyAverages.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            width: 18,
            borderRadius: BorderRadius.circular(4),
            color: Colors.blue,
          ),
        ],
      );
    }).toList();
  }

  // Getting Month's Average Open Time
  List<BarChartGroupData> getMonthlyBarGroups(Map<String, dynamic> statistics) {
    final now = DateTime.now();

    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = (now.month == 12)
        ? DateTime(now.year + 1, 1, 1)
        : DateTime(now.year, now.month + 1, 1);

    Map<int, List<double>> weeklyData = {
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
    };

    for (var entry in statistics.entries) {
      try {
        final date = DateTime.parse(entry.key);

        if (!date.isBefore(startOfMonth) && date.isBefore(endOfMonth)) {
          final dayData = Map<String, dynamic>.from(entry.value);

          final avgOpenTime = (dayData['avgOpenTime'] ?? 0).toDouble();
          final weekOfMonth = ((date.day - 1) ~/ 7) + 1;

          if (weeklyData.containsKey(weekOfMonth)) {
            weeklyData[weekOfMonth]!.add(avgOpenTime);
          }
        }
      } catch (e) {
        // skip invalid date
      }
    }

    Map<int, double> weeklyAverages = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
    };

    weeklyData.forEach((week, values) {
      if (values.isNotEmpty) {
        weeklyAverages[week] =
            values.reduce((a, b) => a + b) / values.length;
      }
    });

    return weeklyAverages.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            width: 18,
            borderRadius: BorderRadius.circular(4),
            color: Colors.orange,
          ),
        ],
      );
    }).toList();
  }

  // The build function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analytics"),
      ),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No data found"));
          }

          final rootData = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

          final smartData = Map<String, dynamic>.from(rootData["smartlocker"] ?? {});

          int alerts = smartData['alerts'] ?? 0;
          String status = smartData['status'] ?? "Locked";

          FirebaseService().getAverageOpenTime();

          final statisticsData = Map<String, dynamic>.from(rootData["statistics"] ?? {});
          
          final countData = Map<String, dynamic>.from(statisticsData[todayDate] ?? {});
          final weeklyBarGroups = getWeeklyBarGroups(statisticsData);
          final monthlyBarGroups = getMonthlyBarGroups(statisticsData);
          
          int unlocks = 0;
          int locks = 0;

          int avgTime = countData['avgOpenTime'] ?? 0;
          unlocks = countData['unlockCount'] ?? 0;
          locks = countData['lockCount'] ?? 0;

          final logs = Map<String, dynamic>.from(rootData["logs"] ?? {});
          
          List<FlSpot> spots = [];

          if (logs.isNotEmpty) {

            DateTime now = DateTime.now();

            final sortedLogs = logs.entries.toList()..sort((a,b) => a.value["timestamp"].compareTo(b.value["timestamp"]));

            for (var entry in sortedLogs) {
              final log = Map<String, dynamic>.from(entry.value);

              int timestamp = log['timestamp'];
              String status = log['status'];

              DateTime logTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

              if (logTime.year == now.year && logTime.month == now.month && logTime.day == now.day) {
                double x = logTime.hour + (logTime.minute / 60);
                double y = status == "Locked" ? 1 : 0;
                spots.add(FlSpot(x, y));
              }
            }
          }

          spots.sort((a, b) => a.x.compareTo(b.x));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                /// Tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTab("Day"),
                    _buildTab("Week"),
                    _buildTab("Month"),
                  ],
                ),

                const SizedBox(height: 20),
                
                /// Blue Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          todayDate,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          _infoBox("Unlocks today", "$unlocks"),
                          _infoBox("Avg. open time", "$avgTime min"),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          _infoBox("Alerts triggered", "$alerts"),
                          _infoBox("Status", status),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 TITLE
                    Text(
                      selectedTab == "Day"
                          ? "Locker Status Today"
                          : selectedTab == "Week"
                              ? "Weekly Unlock Duration"
                              : "Monthly Unlock Duration",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🔥 CHART
                    SizedBox(
                      height: 250,
                      child: selectedTab == "Day"
                          ? LineChart(
                              LineChartData(
                                minY: -0.3,
                                maxY: 1.3,
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    getTooltipItems: (touchedSpots) {
                                      return touchedSpots.map((spot) {
                                        String status =
                                            spot.y == 1 ? "Locked" : "Unlocked";

                                        return LineTooltipItem(
                                          status,
                                          const TextStyle(color: Colors.white),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 70,
                                      getTitlesWidget: (value, meta) {
                                        if (value == 0) return const Text("Unlocked");
                                        if (value == 1) return const Text("Locked");
                                        return const Text("");
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 0.5,
                                      getTitlesWidget: (value, meta) {
                                        int hour = value.floor();
                                        int minute =
                                            ((value - hour) * 60).round();

                                        String formatted =
                                            "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";

                                        return Text(
                                          formatted,
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    isStepLineChart: true,
                                    spots: spots,
                                    color: Colors.green,
                                    barWidth: 2,
                                    dotData: FlDotData(show: false),
                                  ),
                                ],
                              ),
                            )

                          // 🔥 WEEK CHART
                          : selectedTab == "Week"
                              ? BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: weeklyBarGroups
                                                .map((g) => g.barRods.first.toY)
                                                .reduce((a, b) => a > b ? a : b) ==
                                            0
                                        ? 10
                                        : weeklyBarGroups
                                                .map((g) => g.barRods.first.toY)
                                                .reduce((a, b) => a > b ? a : b) +
                                            5,
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          getTitlesWidget: (value, meta) {
                                            return Text("${value.toInt()} min");
                                          },
                                        ),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            switch (value.toInt()) {
                                              case 1:
                                                return const Text("Mon");
                                              case 2:
                                                return const Text("Tue");
                                              case 3:
                                                return const Text("Wed");
                                              case 4:
                                                return const Text("Thu");
                                              case 5:
                                                return const Text("Fri");
                                              case 6:
                                                return const Text("Sat");
                                              case 7:
                                                return const Text("Sun");
                                              default:
                                                return const Text("");
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    gridData: FlGridData(show: true),
                                    barGroups: weeklyBarGroups,
                                  ),
                                )

                              // 🔥 MONTH CHART
                              : BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: monthlyBarGroups
                                                .map((g) => g.barRods.first.toY)
                                                .reduce((a, b) => a > b ? a : b) ==
                                            0
                                        ? 10
                                        : monthlyBarGroups
                                                .map((g) => g.barRods.first.toY)
                                                .reduce((a, b) => a > b ? a : b) +
                                            5,
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          getTitlesWidget: (value, meta) {
                                            return Text("${value.toInt()} min");
                                          },
                                        ),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            switch (value.toInt()) {
                                              case 1:
                                                return const Text("Week 1");
                                              case 2:
                                                return const Text("Week 2");
                                              case 3:
                                                return const Text("Week 3");
                                              case 4:
                                                return const Text("Week 4");
                                              case 5:
                                                return const Text("Week 5");
                                              default:
                                                return const Text("");
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    gridData: FlGridData(show: true),
                                    barGroups: monthlyBarGroups,
                                  ),
                                ),
                    ),
                  ],
                ), 
                
                const SizedBox(height: 20),

                /// Pie Chart
                const Text(
                  "Time Locked vs Unlocked Today",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: locks.toDouble(),
                              color: Colors.green,
                              title: "Locked",
                              radius: 100,
                            ),
                            PieChartSectionData(
                              value: unlocks.toDouble(),
                              color: Colors.red,
                              title: "Unlocked",
                              radius: 100,
                            ),
                          ],
                          sectionsSpace: 0,
                          centerSpaceRadius: 0,
                        ),
                      ),
                    ),

                    const SizedBox(width: 20,),

                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, color: Colors.green,),
                            Text("Locked"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.circle, color: Colors.red,),
                            Text("Unlocked")
                          ],
                        )
                      ],
                    )
                  ],
                ),

                SizedBox(
                  
                ),

              ],
            ),
          );

        },
      ),
    );
  }

  Widget _buildTab(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selectedTab == title
              ? Colors.blue
              : Colors.blue.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selectedTab == title
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _infoBox(String title, String value) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ],
      ),
    );
  }
}
