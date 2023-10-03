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
    if (task.isEmpty) {
      return;
    } else if (completedTasks.contains(task)) {
      completedTasks.remove(task);
      pendingTasks.add(task);
      notifyListeners();
    } else {
      pendingTasks.add(task);
      notifyListeners();
    }
  }

  void completeTask(String task) {
    pendingTasks.remove(task);
    completedTasks.add(task);
    notifyListeners();
  }

  void updateTask(String oldTask, String newTask) {
    if (newTask.isEmpty) {
      return;
    } else if (completedTasks.contains(oldTask)) {
      completedTasks.remove(oldTask);
      completedTasks.add(newTask);
      notifyListeners();
    }
    pendingTasks.remove(oldTask);
    pendingTasks.add(newTask);
    notifyListeners();
  }

  void deleteTask(String task) {
    if (pendingTasks.contains(task)) {
      pendingTasks.remove(task);
      notifyListeners();
    } else if (completedTasks.contains(task)) {
      completedTasks.remove(task);
      notifyListeners();
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = PendingTasksPage();
        break;
      case 1:
        page = CompletedTasksPage();
        break;
      default:
        throw Exception('Invalid index: $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 900) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: true,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.timelapse),
                      label: Text('Pending'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.check_circle),
                      label: Text('Completed'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      } else {
        return Scaffold(
          body: page,
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.timelapse),
                label: 'Pending',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle),
                label: 'Completed',
              ),
            ],
            currentIndex: selectedIndex,
            onTap: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          ),
        );
      }
    });
  }
}

class PendingTasksPage extends StatelessWidget {
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 140,
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Pending Tasks',
            style: TextStyle(
              fontSize: 40,
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
                  leading: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      appState.completeTask(appState.pendingTasks[index]);
                    },
                  ),
                  title: Text(appState.pendingTasks[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsPage(
                          task: appState.pendingTasks[index],
                        ),
                      ),
                    );
                  },
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

class CompletedTasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 140,
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Completed Tasks',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: appState.completedTasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () {
                appState.addTask(appState.completedTasks[index]);
              },
            ),
            title: Text(appState.completedTasks[index]),
          );
        },
      ),
    );
  }
}

class TaskDetailsPage extends StatefulWidget {
  final String task;

  const TaskDetailsPage({Key? key, required this.task}) : super(key: key);

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late TextEditingController _taskController;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.task);
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(widget.task),
      ),
      body: Center(
        // text field to edit the details of a task
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Task',
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    appState.deleteTask(widget.task);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    appState.completeTask(widget.task);
                    Navigator.pop(context);
                  },
                  child: const Text('Complete'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    appState.updateTask(
                      widget.task,
                      _taskController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
