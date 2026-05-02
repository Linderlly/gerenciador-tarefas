import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  final CollectionReference tasks =
      FirebaseFirestore.instance.collection('tasks');

  // CRIAR TAREFA COM DATA
  Future<void> createTask({
    required String title,
    required int points,
    required String assignedTo,
    DateTime? date,
  }) async {
    await tasks.add({
      'title': title,
      'points': points,
      'assignedTo': assignedTo,
      'completed': false,
      'date': date != null ? Timestamp.fromDate(date) : null,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // BUSCAR TAREFAS POR FAMÍLIA
  Stream<QuerySnapshot> getTasks(String familyCode) {
    return tasks
        .where('assignedTo', isEqualTo: familyCode)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // CONCLUIR TAREFA + DAR PONTOS
  Future<void> completeTask(String taskId, String userId) async {
    final taskDoc = await tasks.doc(taskId).get();

    if (!taskDoc.exists) return;

    final data = taskDoc.data() as Map<String, dynamic>;

    int points = data['points'] ?? 0;

    // Atualiza tarefa
    await tasks.doc(taskId).update({
      'completed': true,
    });

    // Atualiza pontos do usuário
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'points': FieldValue.increment(points),
    });
  }
}
