import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarScreen extends StatefulWidget {
  final bool isParent;

  CalendarScreen({required this.isParent});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  Map<DateTime, List> tasksByDay = {};

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    String familyCode = userDoc['familyCode'];

    var snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('assignedTo', isEqualTo: familyCode)
        .get();

    Map<DateTime, List> temp = {};

    for (var doc in snapshot.docs) {
      if (doc['date'] != null) {
        DateTime date = (doc['date'] as Timestamp).toDate();
        DateTime key = DateTime(date.year, date.month, date.day);

        temp.putIfAbsent(key, () => []);
        temp[key]!.add(doc);
      }
    }

    setState(() {
      tasksByDay = temp;
    });
  }

  List getTasksForDay(DateTime day) {
    return tasksByDay[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendário"),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
                focusedDay = focused;
              });
            },
            eventLoader: (day) {
              return getTasksForDay(day);
            },
          ),

          SizedBox(height: 10),

          Expanded(
            child: ListView(
              children: getTasksForDay(selectedDay).map((task) {
                return ListTile(
                  title: Text(task['title']),
                  subtitle: Text("${task['points']} pontos"),
                );
              }).toList(),
            ),
          ),

          // APENAS PARENT PODE ADICIONAR
          if (widget.isParent)
            Padding(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                child: Text("Adicionar tarefa neste dia"),
                onPressed: () {
                  _showAddTaskDialog();
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    TextEditingController title = TextEditingController();
    TextEditingController points = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Nova tarefa"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title),
              TextField(controller: points),
            ],
          ),
          actions: [
            ElevatedButton(
              child: Text("Salvar"),
              onPressed: () async {
                String userId = FirebaseAuth.instance.currentUser!.uid;

                var userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get();

                String familyCode = userDoc['familyCode'];

                await FirebaseFirestore.instance.collection('tasks').add({
                  'title': title.text,
                  'points': int.parse(points.text),
                  'assignedTo': familyCode,
                  'completed': false,
                  'date': selectedDay,
                });

                Navigator.pop(context);
                loadTasks();
              },
            )
          ],
        );
      },
    );
  }
}
