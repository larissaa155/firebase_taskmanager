
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/auth_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _taskController = TextEditingController();
  final _database = FirebaseDatabase.instance.reference();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser!.uid;
    final tasksRef = _database.child('tasks').child(uid);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(labelText: 'Add a task'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    final taskText = _taskController.text.trim();
                    if (taskText.isNotEmpty) {
                      tasksRef.push().set({
                        'title': taskText,
                        'done': false,
                      });
                      _taskController.clear();
                    }
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: tasksRef.onValue,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData && !snapshot.hasError && snapshot.data.snapshot.value != null) {
                  Map data = snapshot.data.snapshot.value;
                  List taskKeys = data.keys.toList();

                  return ListView.builder(
                    itemCount: taskKeys.length,
                    itemBuilder: (context, index) {
                      String key = taskKeys[index];
                      Map task = data[key];
                      return ListTile(
                        title: Text(
                          task['title'],
                          style: TextStyle(
                            decoration: task['done'] ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        leading: Checkbox(
                          value: task['done'],
                          onChanged: (val) {
                            tasksRef.child(key).update({'done': val});
                          },
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => tasksRef.child(key).remove(),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No tasks yet.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
