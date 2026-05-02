import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/task_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_drawer.dart';
import 'reward_screen.dart';

class ChildScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDark;

  ChildScreen({required this.toggleTheme, required this.isDark});

  @override
  _ChildScreenState createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> {
  final TaskService taskService = TaskService();

  DateTime selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    double width = MediaQuery.of(context).size.width;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        var userData = userSnapshot.data!.data() as Map<String, dynamic>;

        String? familyCode = userData['familyCode'];
        String name = userData['name'] ?? "Usuário";
        int points = userData['points'] ?? 0;

        int waterGoal = userData['waterGoal'] ?? 2000;
        int waterDrank = userData['waterDrank'] ?? 0;

        double percent =
            waterGoal > 0 ? (waterDrank / waterGoal).clamp(0.0, 1.0) : 0;

        if (familyCode == null || familyCode.isEmpty) {
          return Scaffold(
            body: Center(child: Text("Família não encontrada")),
          );
        }

        return Scaffold(
          drawer: AppDrawer(
            name: name,
            isDark: widget.isDark,
            onThemeChanged: widget.toggleTheme,
            isParent: false,
          ),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text("Minhas Tarefas"),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.card_giftcard),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RewardScreen()),
                  );
                },
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [Colors.black, Colors.grey.shade900]
                    : [Colors.blue.shade50, Colors.purple.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // HEADER (mantido igual)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, 100, 20, 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.purpleAccent],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Olá, $name",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "$points pontos",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.05,
                        ),
                      ),

                      SizedBox(height: 20),

                      // HIDRATAÇÃO (mantido)
                      Text(
                        "Hidratação",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: percent,
                              strokeWidth: 8,
                              color: Colors.white,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                          Text(
                            "${(percent * 100).toInt()}%",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                        ),
                        icon: Icon(Icons.water_drop),
                        label: Text("Beber 200ml"),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .update({
                            'waterDrank': FieldValue.increment(200),
                          });
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                // CALENDÁRIO + TAREFAS
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: taskService.getTasks(familyCode),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var tasks = snapshot.data!.docs;

                      // ORGANIZAR TAREFAS POR DATA
                      Map<DateTime, List<QueryDocumentSnapshot>> events = {};

                      for (var task in tasks) {
                        if (task['date'] != null) {
                          DateTime date = (task['date'] as Timestamp).toDate();

                          DateTime normalized =
                              DateTime(date.year, date.month, date.day);

                          if (events[normalized] == null) {
                            events[normalized] = [];
                          }

                          events[normalized]!.add(task);
                        }
                      }

                      List<QueryDocumentSnapshot> selectedTasks =
                          events[DateTime(
                                selectedDay.year,
                                selectedDay.month,
                                selectedDay.day,
                              )] ??
                              [];

                      return Column(
                        children: [
                          // CALENDÁRIO
                          TableCalendar(
                            firstDay: DateTime.utc(2020),
                            lastDay: DateTime.utc(2030),
                            focusedDay: selectedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(day, selectedDay),
                            onDaySelected: (selected, focused) {
                              setState(() {
                                selectedDay = selected;
                              });
                            },
                            eventLoader: (day) {
                              return events[
                                      DateTime(day.year, day.month, day.day)] ??
                                  [];
                            },
                          ),

                          SizedBox(height: 10),

                          // TAREFAS DO DIA
                          Expanded(
                            child: selectedTasks.isEmpty
                                ? Center(
                                    child: Text("Nenhuma tarefa neste dia"))
                                : ListView.builder(
                                    itemCount: selectedTasks.length,
                                    itemBuilder: (context, index) {
                                      var task = selectedTasks[index];

                                      bool completed =
                                          task['completed'] ?? false;
                                      String title =
                                          task['title'] ?? "Sem título";
                                      int pts = task['points'] ?? 0;

                                      return AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: completed
                                              ? Colors.green.shade100
                                              : Theme.of(context).cardColor,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            title,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                            ),
                                          ),
                                          subtitle: Text("$pts pontos"),
                                          trailing: completed
                                              ? Icon(Icons.check_circle,
                                                  color: Colors.green)
                                              : SizedBox(
                                                  width: 120,
                                                  child: CustomButton(
                                                    text: "Concluir",
                                                    onPressed: () async {
                                                      await taskService
                                                          .completeTask(
                                                        task.id,
                                                        userId,
                                                      );
                                                    },
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
