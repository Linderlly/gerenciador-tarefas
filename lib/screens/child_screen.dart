import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/task_service.dart';
import 'reward_screen.dart';

class ChildScreen extends StatelessWidget {
  final TaskService taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Tarefas"),
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
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return SizedBox();
              }

              var data = snapshot.data!.data() as Map<String, dynamic>;

              int points = data['points'] ?? 0;
              String name = data['name'] ?? "Usuário";

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      "Bem-vindo, $name 👋",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "Pontos: $points",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          //TAREFAS
          Expanded(
            child: StreamBuilder(
              stream: taskService.getTasks(userId),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var tasks = snapshot.data.docs;

                if (tasks.isEmpty) {
                  return Center(child: Text("Nenhuma tarefa"));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    var task = tasks[index];
                    bool completed = task['completed'] ?? false;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          task['title'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Pontos: ${task['points']}"),
                        trailing: completed
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : ElevatedButton(
                                onPressed: () async {
                                  await taskService.completeTask(
                                    task.id,
                                    userId,
                                  );
                                },
                                child: Text("Concluir"),
                              ),
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
  }
}
