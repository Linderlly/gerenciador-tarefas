import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibration/vibration.dart';

import '../services/task_service.dart';
import '../services/audio_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_drawer.dart';
import 'reward_screen.dart';

class ChildScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDark;

  const ChildScreen({
    super.key,
    required this.toggleTheme,
    required this.isDark,
  });

  @override
  State<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> {
  final TaskService taskService = TaskService();

  // RESET AUTOMÁTICO DA ÁGUA
  Future<void> resetDailyWaterIfNeeded(String userId) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      DocumentSnapshot snapshot = await userRef.get();

      if (!snapshot.exists) return;

      var data = snapshot.data() as Map<String, dynamic>;

      Timestamp? lastResetTimestamp = data['lastWaterReset'];

      DateTime now = DateTime.now();

      if (lastResetTimestamp == null) {
        await userRef.update({
          'lastWaterReset': Timestamp.fromDate(now),
        });

        return;
      }

      DateTime lastReset = lastResetTimestamp.toDate();

      bool isDifferentDay = lastReset.day != now.day ||
          lastReset.month != now.month ||
          lastReset.year != now.year;

      if (isDifferentDay) {
        await userRef.update({
          'waterDrank': 0,
          'lastWaterReset': Timestamp.fromDate(now),
        });
      }
    } catch (e) {
      debugPrint("Erro reset água: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;
    final background = theme.scaffoldBackgroundColor;
    final surface = theme.cardColor;

    resetDailyWaterIfNeeded(userId);

    double width = MediaQuery.of(context).size.width;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: background,
            body: Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            ),
          );
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return Scaffold(
            backgroundColor: background,
            body: const Center(
              child: Text("Usuário não encontrado"),
            ),
          );
        }

        var userData = userSnapshot.data!.data() as Map<String, dynamic>;

        String familyCode = userData['familyCode'] ?? "";

        String name = userData['name'] ?? "Usuário";

        int points = userData['points'] ?? 0;

        int waterGoal = userData['waterGoal'] ?? 2000;

        int waterDrank = userData['waterDrank'] ?? 0;

        double percent =
            waterGoal > 0 ? (waterDrank / waterGoal).clamp(0.0, 1.0) : 0;

        return Scaffold(
          backgroundColor: background,
          drawer: AppDrawer(
            name: name,
            isDark: widget.isDark,
            onThemeChanged: widget.toggleTheme,
            isParent: false,
          ),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text("Minhas Tarefas"),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.card_giftcard),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RewardScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  100,
                  20,
                  30,
                ),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
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
                    const SizedBox(height: 10),
                    Text(
                      "$points pontos",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: width * 0.05,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Hidratação diária",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 10,
                            color: Colors.white,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "${(percent * 100).toInt()}%",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$waterDrank / $waterGoal ml",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.water_drop),
                      label: const Text("Beber 200ml"),
                      onPressed: () async {
                        try {
                          await AudioService.playWater();

                          if (await Vibration.hasVibrator() ?? false) {
                            Vibration.vibrate(duration: 120);
                          }

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .update({
                            'waterDrank': FieldValue.increment(200),
                          });

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: primary,
                              content: const Text(
                                "+200ml adicionados",
                              ),
                            ),
                          );
                        } catch (e) {
                          debugPrint("Erro água: $e");
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Tarefas",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // TASKS
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: taskService.getTasks(familyCode),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: primary,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Erro: ${snapshot.error}",
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(
                          "Nenhuma tarefa encontrada",
                        ),
                      );
                    }

                    final tasks = snapshot.data!.docs;

                    if (tasks.isEmpty) {
                      return const Center(
                        child: Text(
                          "Nenhuma tarefa encontrada",
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        var task = tasks[index];

                        bool completed = task['completed'] ?? false;

                        String title = task['title'] ?? "Sem título";

                        int pts = task['points'] ?? 0;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: completed
                                ? Colors.green.withOpacity(0.15)
                                : surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "$pts pontos",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              completed
                                  ? Row(
                                      children: const [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Concluída",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(
                                      width: double.infinity,
                                      child: CustomButton(
                                        text: "Concluir",
                                        icon: Icons.check,
                                        onPressed: () async {
                                          try {
                                            // SOM
                                            await AudioService
                                                .playTaskComplete();

                                            // VIBRAÇÃO
                                            if (await Vibration.hasVibrator() ??
                                                false) {
                                              Vibration.vibrate(
                                                duration: 180,
                                              );
                                            }

                                            // CONCLUI TASK
                                            await taskService.completeTask(
                                              task.id,
                                              userId,
                                            );

                                            if (!mounted) {
                                              return;
                                            }

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor: primary,
                                                content: Text(
                                                  "Tarefa concluída! +$pts pontos",
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            debugPrint(
                                              "Erro concluir task: $e",
                                            );

                                            if (!mounted) {
                                              return;
                                            }

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                  "Erro ao concluir tarefa",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
