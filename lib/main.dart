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

String formatDate(DateTime dateTime) {
  String day = dateTime.day.toString().padLeft(2, '0');
  String month = dateTime.month.toString().padLeft(2, '0');
  String year = dateTime.year.toString();
  String hour = dateTime.hour.toString().padLeft(2, '0');
  String minute = dateTime.minute.toString().padLeft(2, '0');

  return '$day/$month/$year $hour:$minute';
}

class Task {
  final String name;
  final String description;
  DateTime dateTime;

  Task({required this.name, required this.description, required this.dateTime});
}

class MyAppState extends ChangeNotifier {
  var pendingTasks = <Task>[];
  var completedTasks = <Task>[];

  void addTask(String name, String description, DateTime dateTime) {
    Task task = Task(name: name, description: description, dateTime: dateTime);
    pendingTasks.add(task);
    notifyListeners();
  }

  void completeTask(Task task) {
    pendingTasks.remove(task);
    completedTasks.add(task);
    notifyListeners();
  }

  void uncompleteTask(Task task) {
    completedTasks.remove(task);
    pendingTasks.add(task);
    notifyListeners();
  }

  void updateTask(Task oldTask, Task newTask) {
    if (completedTasks.contains(oldTask)) {
      completedTasks.remove(oldTask);
      completedTasks.add(newTask);
      notifyListeners();
    }
    pendingTasks.remove(oldTask);
    pendingTasks.add(newTask);
    notifyListeners();
  }

  void deleteTask(Task task) {
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();

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
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.pendingTasks[index].name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                          'Description: ${appState.pendingTasks[index].description}'),
                      Text(
                          'Date and Time: ${formatDate(appState.pendingTasks[index].dateTime)}'),
                    ],
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      appState.completeTask(appState.pendingTasks[index]);
                    },
                  ),
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
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _dateTimeController,
                                decoration: const InputDecoration(
                                  labelText: 'Date and Time',
                                ),
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );

                                  if (pickedDate != null) {
                                    TimeOfDay? pickedTime =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );

                                    if (pickedTime != null) {
                                      DateTime selectedDateTime = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );

                                      _dateTimeController.text =
                                          selectedDateTime.toString();
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                if (_nameController.text.isNotEmpty &&
                                    _descriptionController.text.isNotEmpty &&
                                    _dateTimeController.text.isNotEmpty) {
                                  DateTime dateTime =
                                      DateTime.parse(_dateTimeController.text);
                                  appState.addTask(_nameController.text,
                                      _descriptionController.text, dateTime);
                                  Navigator.pop(context);
                                  _nameController.clear();
                                  _descriptionController.clear();
                                  _dateTimeController.clear();
                                }
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.completedTasks[index].name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                    'Description: ${appState.completedTasks[index].description}'),
                Text(
                    'Date and Time: ${formatDate(appState.completedTasks[index].dateTime)}'),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () {
                appState.uncompleteTask(appState.completedTasks[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class TaskDetailsPage extends StatefulWidget {
  final Task task;

  const TaskDetailsPage({Key? key, required this.task}) : super(key: key);

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateTimeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _dateTimeController =
        TextEditingController(text: widget.task.dateTime.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(widget.task.name),
      ),
      body: Center(
        // form to edit the details of a task
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _dateTimeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Date and Time',
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.task.dateTime,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(widget.task.dateTime),
                    );

                    if (pickedTime != null) {
                      setState(() {
                        widget.task.dateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                        _dateTimeController.text =
                            formatDate(widget.task.dateTime);
                      });
                    }
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                    appState.deleteTask(widget.task);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Task updatedTask = Task(
                      name: _nameController.text,
                      description: _descriptionController.text,
                      dateTime: widget.task.dateTime,
                    );
                    appState.updateTask(widget.task, updatedTask);
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
