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
  final TextEditingController userIdController = TextEditingController();

  final TextEditingController rewardTitleController = TextEditingController();
  final TextEditingController rewardCostController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text("Painel dos Pais")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 BEM-VINDO COM NOME
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return SizedBox();
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;

                String name = data['name'] ?? "Pai";

                return Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Bem-vindo, $name 👋",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),

            // 🔹 CRIAR TAREFA
            Text(
              "Criar Tarefa",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Nome da tarefa"),
            ),

            SizedBox(height: 10),

            TextField(
              controller: pointsController,
              decoration: InputDecoration(labelText: "Pontos"),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 10),

            TextField(
              controller: userIdController,
              decoration: InputDecoration(labelText: "ID do filho"),
            ),

            SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await taskService.createTask(
                    title: titleController.text,
                    points: int.parse(pointsController.text),
                    assignedTo: userIdController.text,
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Tarefa criada!")));
                },
                child: Text("Criar Tarefa"),
              ),
            ),

            SizedBox(height: 30),

            // 🔹 CRIAR RECOMPENSA
            Text(
              "Criar Recompensa",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            TextField(
              controller: rewardTitleController,
              decoration: InputDecoration(labelText: "Nome da recompensa"),
            ),

            SizedBox(height: 10),

            TextField(
              controller: rewardCostController,
              decoration: InputDecoration(labelText: "Custo em pontos"),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await rewardService.createReward(
                    title: rewardTitleController.text,
                    cost: int.parse(rewardCostController.text),
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Recompensa criada!")));
                },
                child: Text("Criar Recompensa"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
