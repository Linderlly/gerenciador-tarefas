import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //CRIAR TAREFA
  Future<void> createTask({
    required String title,
    required int points,
    required String assignedTo,
  }) async {
    await _db.collection('tasks').add({
      'title': title,
      'points': points,
      'assignedTo': assignedTo,
      'completed': false,
      'createdAt': Timestamp.now(),
    });
  }

  //LISTAR TAREFAS
  Stream<QuerySnapshot> getTasks(String userId) {
    return _db
        .collection('tasks')
        .where('assignedTo', isEqualTo: userId)
        .snapshots();
  }

  //CONCLUIR TAREFA + SOMAR PONTOS
  Future<void> completeTask(String taskId, String userId) async {
    var taskRef = _db.collection('tasks').doc(taskId);
    var userRef = _db.collection('users').doc(userId);

    await _db.runTransaction((transaction) async {
      var taskDoc = await transaction.get(taskRef);
      var userDoc = await transaction.get(userRef);

      if (!taskDoc.exists || !userDoc.exists) return;

      bool completed = taskDoc['completed'] ?? false;

      if (!completed) {
        int points = taskDoc['points'] ?? 0;
        int currentPoints = userDoc['points'] ?? 0;

        transaction.update(taskRef, {'completed': true});
        transaction.update(userRef, {'points': currentPoints + points});
      }
    });
  }
}
