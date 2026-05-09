import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  final CollectionReference tasks =
      FirebaseFirestore.instance.collection('tasks');

  // CRIAR TAREFA
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

      // DATA DA TAREFA
      'date': date != null ? Timestamp.fromDate(date) : Timestamp.now(),

      // DATA DE CRIAÇÃO
      'createdAt': Timestamp.now(),
    });
  }

  // BUSCAR TAREFAS
  Stream<QuerySnapshot> getTasks(String familyCode) {
    return tasks
        .where(
          'assignedTo',
          isEqualTo: familyCode,
        )
        .snapshots();
  }

  // CONCLUIR TAREFA
  Future<void> completeTask(
    String taskId,
    String userId,
  ) async {
    final taskDoc = await tasks.doc(taskId).get();

    if (!taskDoc.exists) return;

    final data = taskDoc.data() as Map<String, dynamic>;

    int points = data['points'] ?? 0;

    // MARCA COMO CONCLUÍDA
    await tasks.doc(taskId).update({
      'completed': true,
    });

    // ADICIONA PONTOS
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'points': FieldValue.increment(points),
    });
  }
}
