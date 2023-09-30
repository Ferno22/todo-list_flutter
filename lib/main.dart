import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'To-Do List',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MyHomePage(title: "Pending Tasks"),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var pendingTasks = [];
  var completedTasks = [];

  void addTask(String task) {
    pendingTasks.add(task);
    notifyListeners();
  }

  void completeTask(String task) {
    pendingTasks.remove(task);
    completedTasks.add(task);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: appState.pendingTasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(appState.pendingTasks[index]),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 70,
                height: 70,
                child: FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Add Task'),
                          content: TextField(
                            controller: _taskController,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                appState.addTask(_taskController.text);
                                Navigator.pop(context);
                                _taskController.clear();
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(
                    '+',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
