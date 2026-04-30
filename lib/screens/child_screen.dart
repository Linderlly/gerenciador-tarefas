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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Minhas Tarefas"),
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = userSnapshot.data!.data() as Map<String, dynamic>;

          String familyCode = userData['familyCode'];
          String name = userData['name'] ?? "Usuário";

          return Column(
            children: [
              //HEADER
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

                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.blueAccent],
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
                  );
                },
              ),

              SizedBox(height: 10),

              //LISTA
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: taskService.getTasks(familyCode),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var tasks = snapshot.data!.docs;

                    if (tasks.isEmpty) {
                      return Center(child: Text("Nenhuma tarefa"));
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        var task = tasks[index];
                        bool completed = task['completed'] ?? false;

                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: completed ? Colors.green[100] : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 5),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(15),
                            title: Text(
                              task['title'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("${task['points']} pontos"),
                            trailing: completed
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
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
