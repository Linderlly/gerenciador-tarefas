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
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    try {
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
      debugPrint("Erro ao resetar água: $e");
    }
  }

  // MOSTRAR MENSAGEM DE ÁGUA
  void showWaterSnackBar(BuildContext context, Color primary) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.water_drop,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "+200ml adicionados",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: primary,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // MOSTRAR MENSAGEM DE TAREFA CONCLUÍDA
  void showTaskCompletedSnackBar(
    BuildContext context,
    Color primary,
    int points,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Tarefa concluída! +$points pontos",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: primary,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("Usuário não autenticado"),
        ),
      );
    }

    String userId = currentUser.uid;

    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;
    final background = theme.scaffoldBackgroundColor;
    final surface = theme.cardColor;

    double width = MediaQuery.of(context).size.width;

    // RESET AUTOMÁTICO DA ÁGUA
    resetDailyWaterIfNeeded(userId);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return Scaffold(
            backgroundColor: background,
            body: Center(
              child: Text(
                "Erro ao carregar usuário",
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          );
        }

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
            body: Center(
              child: Text(
                "Usuário não encontrado",
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
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
            title: const Text(
              "Minhas Tarefas",
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.card_giftcard,
                ),
                tooltip: "Recompensas",
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

          // TELA INTEIRA ROLÁVEL
          body: SafeArea(
            top: false,
            child: StreamBuilder<QuerySnapshot>(
              stream: taskService.getTasks(familyCode),
              builder: (context, taskSnapshot) {
                if (taskSnapshot.hasError) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(
                          context,
                          primary,
                          name,
                          points,
                          waterGoal,
                          waterDrank,
                          percent,
                          width,
                          userId,
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "Erro ao carregar tarefas",
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (taskSnapshot.connectionState == ConnectionState.waiting) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(
                          context,
                          primary,
                          name,
                          points,
                          waterGoal,
                          waterDrank,
                          percent,
                          width,
                          userId,
                        ),
                        const SizedBox(height: 30),
                        CircularProgressIndicator(
                          color: primary,
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                }

                if (!taskSnapshot.hasData) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(
                          context,
                          primary,
                          name,
                          points,
                          waterGoal,
                          waterDrank,
                          percent,
                          width,
                          userId,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Nenhuma tarefa encontrada",
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                }

                var tasks = taskSnapshot.data!.docs;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      _buildHeader(
                        context,
                        primary,
                        name,
                        points,
                        waterGoal,
                        waterDrank,
                        percent,
                        width,
                        userId,
                      ),

                      const SizedBox(height: 22),

                      // TÍTULO DAS TAREFAS
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.task_alt,
                              color: primary,
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Tarefas",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (tasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            30,
                            20,
                            40,
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 60,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Nenhuma tarefa encontrada",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(
                            bottom: 30,
                          ),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            var task = tasks[index];

                            bool completed = task['completed'] ?? false;

                            String title = task['title'] ?? "Sem título";

                            int pts = task['points'] ?? 0;

                            return AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 300,
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 7,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: completed
                                    ? Colors.green.withOpacity(0.15)
                                    : surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: completed
                                      ? Colors.green.withOpacity(0.25)
                                      : primary.withOpacity(0.06),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withOpacity(0.07),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: theme
                                                .textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primary.withOpacity(0.10),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "+$pts",
                                          style: TextStyle(
                                            color: primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    "$pts pontos",
                                    style: TextStyle(
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  // TAREFA CONCLUÍDA
                                  if (completed)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 22,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Concluída",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )

                                  // BOTÃO CONCLUIR
                                  else
                                    SizedBox(
                                      width: double.infinity,
                                      child: CustomButton(
                                        text: "Concluir",
                                        icon: Icons.check,
                                        onPressed: () async {
                                          try {
                                            // SOM DE SUCESSO
                                            await AudioService
                                                .playTaskComplete();

                                            // VIBRAÇÃO
                                            if (await Vibration.hasVibrator() ??
                                                false) {
                                              Vibration.vibrate(
                                                duration: 180,
                                              );
                                            }

                                            // CONCLUI A TAREFA
                                            await taskService.completeTask(
                                              task.id,
                                              userId,
                                            );

                                            if (!mounted) {
                                              return;
                                            }

                                            // MENSAGEM
                                            showTaskCompletedSnackBar(
                                              context,
                                              primary,
                                              pts,
                                            );
                                          } catch (e) {
                                            debugPrint(
                                              "Erro ao concluir tarefa: $e",
                                            );

                                            if (!mounted) {
                                              return;
                                            }

                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar();

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  "Erro ao concluir tarefa",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                backgroundColor: Colors.red,
                                                duration: const Duration(
                                                  seconds: 5,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                  16,
                                                  0,
                                                  16,
                                                  20,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    14,
                                                  ),
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
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // HEADER DA TELA
  Widget _buildHeader(
    BuildContext context,
    Color primary,
    String name,
    int points,
    int waterGoal,
    int waterDrank,
    double percent,
    double width,
    String userId,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        85,
        20,
        20,
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
          // SAUDAÇÃO
          Text(
            "Olá, $name",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.055,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // PONTOS
          Text(
            "$points pontos",
            style: TextStyle(
              color: Colors.white70,
              fontSize: width * 0.043,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // HIDRATAÇÃO
          const Text(
            "Hidratação diária",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          // CÍRCULO DE HIDRATAÇÃO
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(percent * 100).toInt()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "$waterDrank / $waterGoal ml",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // BOTÃO BEBER ÁGUA
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              minimumSize: const Size(0, 42),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(
              Icons.water_drop,
              size: 20,
            ),
            label: const Text(
              "Beber 200ml",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () async {
              try {
                // SOM
                await AudioService.playWater();

                // VIBRAÇÃO
                if (await Vibration.hasVibrator() ?? false) {
                  Vibration.vibrate(
                    duration: 120,
                  );
                }

                // ADICIONA ÁGUA
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'waterDrank': FieldValue.increment(200),
                });

                if (!mounted) return;

                // MENSAGEM DE 5 SEGUNDOS
                showWaterSnackBar(
                  context,
                  primary,
                );
              } catch (e) {
                debugPrint(
                  "Erro ao adicionar água: $e",
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).hideCurrentSnackBar();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "Erro ao registrar água",
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
