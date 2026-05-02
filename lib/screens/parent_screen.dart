import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/task_service.dart';
import '../services/reward_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_drawer.dart';

class ParentScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDark;

  ParentScreen({required this.toggleTheme, required this.isDark});

  @override
  _ParentScreenState createState() => _ParentScreenState();
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
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        String name = data['name'] ?? "Usuário";
        String familyCode = data['familyCode'] ?? "";

        return Scaffold(
          drawer: AppDrawer(
            name: name,
            isDark: widget.isDark,
            onThemeChanged: widget.toggleTheme,
            isParent: true,
          ),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text("Painel dos Pais"),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [Colors.black, Colors.grey.shade900]
                    : [Colors.blue.shade50, Colors.purple.shade50],
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 100, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TÍTULO
                  Text(
                    "Bem-vindo, $name",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),

                  SizedBox(height: 20),

                  // CÓDIGO DA FAMÍLIA
                  _card(
                    context,
                    child: Text(
                      "Código da família: $familyCode",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Cria tarefas
                  _sectionTitle(context, "Criar Tarefa"),

                  _card(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nome da tarefa"),
                        TextField(
                          controller: titleController,
                          decoration:
                              InputDecoration(hintText: "Ex: Arrumar o quarto"),
                        ),
                        SizedBox(height: 10),
                        Text("Pontuação"),
                        TextField(
                          controller: pointsController,
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(hintText: "Ex: 10 pontos"),
                        ),
                        SizedBox(height: 10),
                        Text("Data da tarefa"),
                        SizedBox(height: 5),
                        ElevatedButton(
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
                        SizedBox(height: 10),
                        CustomButton(
                          text: "Criar tarefa",
                          icon: Icons.add,
                          onPressed: () async {
                            if (titleController.text.isEmpty ||
                                pointsController.text.isEmpty) return;

                            await taskService.createTask(
                              title: titleController.text,
                              points: int.parse(pointsController.text),
                              assignedTo: familyCode,
                              date: selectedDay,
                            );

                            titleController.clear();
                            pointsController.clear();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Tarefa criada")),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Hidratação
                  _sectionTitle(context, "Hidratação dos filhos"),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('familyCode', isEqualTo: familyCode)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var users = snapshot.data!.docs;

                      return Column(
                        children: users.map((user) {
                          var u = user.data() as Map<String, dynamic>;

                          int goal = u['waterGoal'] ?? 2000;
                          int drank = u['waterDrank'] ?? 0;

                          DateTime now = DateTime.now();
                          DateTime? lastReset =
                              (u['lastReset'] as Timestamp?)?.toDate();

                          // reset automático diário
                          if (lastReset == null ||
                              now.day != lastReset.day ||
                              now.month != lastReset.month ||
                              now.year != lastReset.year) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.id)
                                .update({
                              'waterDrank': 0,
                              'lastReset': now,
                            });

                            drank = 0;
                          }

                          // limita progresso até 100%
                          double percent =
                              goal > 0 ? (drank / goal).clamp(0, 1) : 0;

                          return Container(
                            margin: EdgeInsets.only(bottom: 15),
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Text(u['name'] ?? "Filho"),
                                SizedBox(height: 10),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: CircularProgressIndicator(
                                        value: percent,
                                        strokeWidth: 8,
                                      ),
                                    ),
                                    Text("${(percent * 100).toInt()}%"),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  SizedBox(height: 20),

                  // INPUT META DE ÁGUA
                  _card(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Definir meta de água (ml)"),
                        TextField(
                          controller: waterGoalController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: "Ex: 2000 ml"),
                        ),
                        SizedBox(height: 10),
                        CustomButton(
                          text: "Salvar meta",
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .update({
                              'waterGoal': int.parse(waterGoalController.text),
                            });
                          },
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Recompensas
                  _sectionTitle(context, "Criar Recompensa"),

                  _card(
                    context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Nome da recompensa"),
                        TextField(
                          controller: rewardTitleController,
                          decoration: InputDecoration(
                              hintText: "Ex: 1 hora de videogame"),
                        ),
                        SizedBox(height: 10),
                        Text("Custo em pontos"),
                        TextField(
                          controller: rewardCostController,
                          keyboardType: TextInputType.number,
                          decoration:
                              InputDecoration(hintText: "Ex: 50 pontos"),
                        ),
                        SizedBox(height: 10),
                        CustomButton(
                          text: "Criar recompensa",
                          icon: Icons.card_giftcard,
                          onPressed: () async {
                            if (rewardTitleController.text.isEmpty ||
                                rewardCostController.text.isEmpty) return;

                            await rewardService.createReward(
                              title: rewardTitleController.text,
                              cost: int.parse(rewardCostController.text),
                              familyCode: familyCode,
                            );

                            rewardTitleController.clear();
                            rewardCostController.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}
