import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/task_service.dart';
import '../services/reward_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_drawer.dart';

class ParentScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDark;

  const ParentScreen({
    super.key,
    required this.toggleTheme,
    required this.isDark,
  });

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final TaskService taskService = TaskService();
  final RewardService rewardService = RewardService();

  final TextEditingController titleController = TextEditingController();

  final TextEditingController pointsController = TextEditingController();

  final TextEditingController rewardTitleController = TextEditingController();

  final TextEditingController rewardCostController = TextEditingController();

  final TextEditingController waterGoalController = TextEditingController();

  DateTime selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // CORES VINDO DIRETAMENTE DO THEME.DART
    final Color primary = colorScheme.primary;
    final Color background = theme.scaffoldBackgroundColor;
    final Color cardColor = theme.cardColor;
    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: background,
            body: Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final String name = data['name'] ?? 'Usuário';

        final String familyCode = data['familyCode'] ?? '';

        return Scaffold(
          backgroundColor: background,
          drawer: AppDrawer(
            name: name,
            isDark: widget.isDark,
            onThemeChanged: widget.toggleTheme,
            isParent: true,
          ),
          appBar: AppBar(
            title: const Text("Painel dos Pais"),
            centerTitle: true,
            backgroundColor: background,
            foregroundColor: textColor,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TÍTULO
                Text(
                  "Bem-vindo, $name",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 20),

                // CARD FAMÍLIA
                _card(
                  context,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.family_restroom,
                          color: primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Código da família: $familyCode",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // CRIAR TAREFA
                _sectionTitle(
                  context,
                  "Criar Tarefa",
                ),

                _card(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(
                        context,
                        "Nome da tarefa",
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: "Ex: Arrumar o quarto",
                          prefixIcon: Icon(
                            Icons.task_alt,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _label(
                        context,
                        "Pontuação",
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: pointsController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: "Ex: 10 pontos",
                          prefixIcon: Icon(
                            Icons.stars_rounded,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _label(
                        context,
                        "Data da tarefa",
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setState(() {
                              selectedDay = picked;
                            });
                          }
                        },
                        child: Text(
                          "${selectedDay.day}/${selectedDay.month}/${selectedDay.year}",
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomButton(
                        text: "Criar tarefa",
                        icon: Icons.add,
                        onPressed: () async {
                          if (titleController.text.isEmpty ||
                              pointsController.text.isEmpty) {
                            return;
                          }

                          await taskService.createTask(
                            title: titleController.text,
                            points: int.parse(
                              pointsController.text,
                            ),
                            assignedTo: familyCode,
                            date: selectedDay,
                          );

                          titleController.clear();
                          pointsController.clear();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: primary,
                              content: const Text(
                                "Tarefa criada",
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // HIDRATAÇÃO
                _sectionTitle(
                  context,
                  "Hidratação dos filhos",
                ),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where(
                        'familyCode',
                        isEqualTo: familyCode,
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: primary,
                        ),
                      );
                    }

                    final users = snapshot.data!.docs.where(
                      (doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        return data['role'] == 'child';
                      },
                    ).toList();

                    return Column(
                      children: users.map((user) {
                        final u = user.data() as Map<String, dynamic>;

                        final int goal = u['waterGoal'] ?? 2000;

                        final int drank = u['waterDrank'] ?? 0;

                        final double percent =
                            goal > 0 ? (drank / goal).clamp(0, 1) : 0;

                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: 15,
                          ),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(
                              22,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(
                                  0.06,
                                ),
                                blurRadius: 10,
                                offset: const Offset(
                                  0,
                                  4,
                                ),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.water_drop,
                                    color: primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    u['name'] ?? "Filho",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: 95,
                                height: 95,
                                child: CircularProgressIndicator(
                                  value: percent,
                                  strokeWidth: 9,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation(
                                    primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "${(percent * 100).toInt()}%",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                "$drank ml",
                                style: TextStyle(
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Meta diária: $goal ml",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // META ÁGUA
                _sectionTitle(
                  context,
                  "Definir meta de água",
                ),

                _card(
                  context,
                  child: Column(
                    children: [
                      TextField(
                        controller: waterGoalController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: "Ex: 2000 ml",
                          prefixIcon: Icon(
                            Icons.local_drink,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomButton(
                        text: "Salvar meta",
                        onPressed: () async {
                          QuerySnapshot children =
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .where(
                                    'familyCode',
                                    isEqualTo: familyCode,
                                  )
                                  .where(
                                    'role',
                                    isEqualTo: 'child',
                                  )
                                  .get();

                          for (var child in children.docs) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(child.id)
                                .update({
                              'waterGoal': int.parse(
                                waterGoalController.text,
                              ),
                            });
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: primary,
                              content: const Text(
                                "Meta atualizada",
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // RECOMPENSAS
                _sectionTitle(
                  context,
                  "Criar Recompensa",
                ),

                _card(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(
                        context,
                        "Nome da recompensa",
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: rewardTitleController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: "Ex: 1 hora de videogame",
                          prefixIcon: Icon(
                            Icons.card_giftcard,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _label(
                        context,
                        "Custo em pontos",
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: rewardCostController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: "Ex: 50 pontos",
                          prefixIcon: Icon(
                            Icons.stars,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomButton(
                        text: "Criar recompensa",
                        icon: Icons.card_giftcard,
                        onPressed: () async {
                          if (rewardTitleController.text.isEmpty ||
                              rewardCostController.text.isEmpty) {
                            return;
                          }

                          await rewardService.createReward(
                            title: rewardTitleController.text,
                            cost: int.parse(
                              rewardCostController.text,
                            ),
                            familyCode: familyCode,
                          );

                          rewardTitleController.clear();

                          rewardCostController.clear();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: primary,
                              content: const Text(
                                "Recompensa criada",
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _card(
    BuildContext context, {
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.10),
        ),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        ),
      ),
    );
  }

  Widget _label(
    BuildContext context,
    String text,
  ) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
      ),
    );
  }
}
