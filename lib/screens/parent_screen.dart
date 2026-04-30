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
      appBar: AppBar(title: Text("Painel dos Pais")),
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

          String name = data['name'];
          String familyCode = data['familyCode'];

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bem-vindo, $name 👋",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 10),

                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text("Código da família: $familyCode"),
                ),

                SizedBox(height: 20),

                // TAREFAS
                Text(
                  "Criar Tarefa",
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                    await taskService.createTask(
                      title: titleController.text,
                      points: int.parse(pointsController.text),
                      assignedTo: familyCode,
                    );

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Tarefa criada")));
                  },
                  child: Text("Criar tarefa"),
                ),

                SizedBox(height: 30),

                // RECOMPENSAS
                Text(
                  "Criar Recompensa",
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                    await rewardService.createReward(
                      title: rewardTitleController.text,
                      cost: int.parse(rewardCostController.text),
                      familyCode: familyCode,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Recompensa criada")),
                    );
                  },
                  child: Text("Criar recompensa"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
