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
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),

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

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = userSnapshot.data!.data() as Map<String, dynamic>;

          String? familyCode = userData['familyCode'];
          String name = userData['name'] ?? "Usuário";
          int points = userData['points'] ?? 0;

          if (familyCode == null || familyCode.isEmpty) {
            return Center(child: Text("Família não encontrada"));
          }

          return Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Olá, $name 👋",
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
                  ],
                ),
              ),

              SizedBox(height: 10),

              // TAREFAS
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: taskService.getTasks(familyCode),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var tasks = snapshot.data?.docs ?? [];

                    if (tasks.isEmpty) {
                      return Center(child: Text("Nenhuma tarefa"));
                    }

                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        var task = tasks[index];

                        bool completed = task['completed'] ?? false;
                        String title = task['title'] ?? "Sem título";
                        int pts = task['points'] ?? 0;

                        return Container(
                          key: ValueKey(task.id), // ESSENCIAL
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: completed ? Colors.green[100] : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(title),
                            subtitle: Text("$pts pontos"),
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
          );
        },
      ),
    );
  }
}
