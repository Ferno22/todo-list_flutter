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
        title: Text(widget.title),
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
          TextField(
            controller: _taskController,
            decoration: InputDecoration(
              hintText: 'Enter a new task',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              appState.addTask(_taskController.text);
              _taskController.clear();
            },
            child: Text('Add Task'),
          ),
        ],
      ),
    );
  }
}
