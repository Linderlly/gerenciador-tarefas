import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/task_service.dart';
import '../services/reward_service.dart';

class ParentScreen extends StatelessWidget {
  final TaskService taskService = TaskService();
  final RewardService rewardService = RewardService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();

  final TextEditingController rewardTitleController = TextEditingController();
  final TextEditingController rewardCostController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Painel dos Pais"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          String name = data['name'] ?? "Usuário";
          String familyCode = data['familyCode'] ?? "Sem código";

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BOAS-VINDAS
                Text(
                  "Bem-vindo, $name 👋",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 15),

                // 🔑 CÓDIGO DA FAMÍLIA
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade200, Colors.blue.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Código da família: $familyCode",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 25),

                // CRIAR TAREFA
                Text(
                  "Criar Tarefa",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Nome da tarefa"),
                ),

                TextField(
                  controller: pointsController,
                  decoration: InputDecoration(labelText: "Pontos"),
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty ||
                        pointsController.text.isEmpty)
                      return;

                    await taskService.createTask(
                      title: titleController.text,
                      points: int.parse(pointsController.text),
                      assignedTo: familyCode,
                    );

                    titleController.clear();
                    pointsController.clear();

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Tarefa criada")));
                  },
                  child: Text("Criar tarefa"),
                ),

                SizedBox(height: 30),

                // CRIAR RECOMPENSA
                Text(
                  "Criar Recompensa",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                TextField(
                  controller: rewardTitleController,
                  decoration: InputDecoration(labelText: "Nome da recompensa"),
                ),

                TextField(
                  controller: rewardCostController,
                  decoration: InputDecoration(labelText: "Custo"),
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () async {
                    if (rewardTitleController.text.isEmpty ||
                        rewardCostController.text.isEmpty)
                      return;

                    await rewardService.createReward(
                      title: rewardTitleController.text,
                      cost: int.parse(rewardCostController.text),
                      familyCode: familyCode,
                    );

                    rewardTitleController.clear();
                    rewardCostController.clear();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Recompensa criada")),
                    );
                  },
                  child: Text("Criar recompensa"),
                ),

                SizedBox(height: 30),

                // LISTA DE RECOMPENSAS
                Text(
                  "Minhas Recompensas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('rewards')
                      .where('familyCode', isEqualTo: familyCode)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      );
                    }

                    var rewards = snapshot.data!.docs;

                    if (rewards.isEmpty) {
                      return Text("Nenhuma recompensa criada");
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        var reward = rewards[index];

                        String title = reward['title'] ?? "Sem nome";
                        int cost = reward['cost'] ?? 0;

                        return Card(
                          key: ValueKey(reward.id),
                          margin: EdgeInsets.only(top: 10),
                          child: ListTile(
                            title: Text(title),
                            subtitle: Text("$cost pontos"),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // EDITAR
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _showEditDialog(
                                      context,
                                      reward.id,
                                      title,
                                      cost,
                                    );
                                  },
                                ),

                                // EXCLUIR
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await rewardService.deleteReward(reward.id);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Recompensa excluída"),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // DIALOG EDITAR
  void _showEditDialog(
    BuildContext context,
    String rewardId,
    String currentTitle,
    int currentCost,
  ) {
    TextEditingController titleController = TextEditingController(
      text: currentTitle,
    );

    TextEditingController costController = TextEditingController(
      text: currentCost.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar Recompensa"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Título"),
              ),
              TextField(
                controller: costController,
                decoration: InputDecoration(labelText: "Pontos"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Salvar"),
              onPressed: () async {
                await RewardService().updateReward(
                  rewardId,
                  title: titleController.text,
                  cost: int.parse(costController.text),
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Recompensa atualizada")),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
