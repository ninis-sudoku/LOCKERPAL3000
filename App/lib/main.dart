import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trying_out/analyticsPage.dart';
import 'package:trying_out/loginPage.dart';
import 'package:trying_out/logsPage.dart';
import 'package:trying_out/settingsPage.dart';
import 'package:trying_out/start_page.dart';
import 'package:trying_out/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: start_page(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasData) {
            return Stack(
              children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset('assets/wave_background.png'),
                  ),

                  SafeArea(
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Top Icon (Settings & Notifications)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [                            
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()),);
                                    }, 
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(0),
                                      backgroundColor: Colors.blue
                                    ),
                                    child: Icon(Icons.settings, color: Colors.black,)
                                  ),

                                  ElevatedButton(
                                    onPressed: () {}, 
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(0),
                                      backgroundColor: Colors.blue
                                    ),
                                    child: Icon(Icons.notifications, color: Colors.black,)
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40,),
                              
                              // Set your locker container
                              StreamBuilder<bool>(
                                stream: FirebaseService().lockerStatusStream(), 
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const CircularProgressIndicator();
                                  }

                                  bool isLocked = snapshot.data!;

                                  return Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(vertical: 40),
                                        decoration: BoxDecoration(
                                          color: isLocked ? const Color.fromARGB(42, 52, 168, 83) : Color.fromARGB(42, 234, 67, 53),
                                          borderRadius: BorderRadius.circular(16)
                                        ),
                                        
                                        child: Column(
                                          children: [
                                            Icon(Icons.lock, size: 40,color: isLocked ? const Color.fromARGB(255, 52, 168, 83) : Color.fromARGB(255, 249, 50, 45),),
                                            Text(isLocked ? "LOCKER IS LOCKED" : "LOCKER IS UNLOCKED", style: TextStyle(fontSize: 16, fontFamily: "Norwester", fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 25,),

                                      // Lock/Unlock Button
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // Unlock Button
                                          ElevatedButton.icon(
                                            onPressed: isLocked ? () {
                                              FirebaseService().lockerStatus(true);

                                              FirebaseService().incrementUnlock(true);
                                              FirebaseService().lockerStatus(true);

                                            } : null, 
                                            icon: Icon(Icons.lock_open),
                                            label: const Text("UNLOCK", style: TextStyle(color: Colors.black),),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              side: const BorderSide(color: Colors.green),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20)
                                            ),                     
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 25,),

                                      // Logs Button
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => LogsPage()),);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(color: Colors.black),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                          minimumSize: const Size(double.infinity, 55)
                                        ), 
                                        child: Text("LOGS", style: TextStyle(fontFamily: "Norwester", fontWeight: FontWeight.bold),),
                                      ),

                                      const SizedBox(height: 15,),

                                      // Analytics Button
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsPage()),);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(color: Colors.black),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                          minimumSize: const Size(double.infinity, 55),
                                        ), 
                                        child: Text("ANALYTICS", style: TextStyle(fontFamily: "Norwester", fontWeight: FontWeight.bold),),
                                      ),
                                    ],
                                  );
                                }
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
              ],
            ); // User logged in
          }
          return LoginPage();      
        },
      ),
    );
  }
}
