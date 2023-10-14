// Import necessary packages
import 'package:flutter/material.dart'; // Flutter framework for building UI
import 'package:provider/provider.dart'; // Provider package for state management

// Entry point of the application
void main() {
  runApp(const MyApp()); // Run the MyApp widget as the root of the app
}

// MyApp class, a StatelessWidget representing the root of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Use Provider to manage state changes
      create: (context) => MyAppState(), // Create an instance of MyAppState
      child: MaterialApp(
        title: 'To-Do List', // Set the title for the app
        theme: ThemeData(
          useMaterial3: true, // Enable Material3 design
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple), // Set the color scheme
        ),
        home: const MyHomePage(
            title: "Pending Tasks"), // Set the home page as MyHomePage
      ),
    );
  }
}

// Function to format a DateTime into a specific string format
String formatDate(DateTime dateTime) {
  String day =
      dateTime.day.toString().padLeft(2, '0'); // Format day with leading zeros
  String month = dateTime.month
      .toString()
      .padLeft(2, '0'); // Format month with leading zeros
  String year = dateTime.year.toString(); // Get the year as a string
  String hour = dateTime.hour
      .toString()
      .padLeft(2, '0'); // Format hour with leading zeros
  String minute = dateTime.minute
      .toString()
      .padLeft(2, '0'); // Format minute with leading zeros

  return '$day/$month/$year $hour:$minute'; // Return formatted date and time string
}

// Task class to represent a task with a name, description, and due date
class Task {
  final String name; // Task name
  final String description; // Task description
  DateTime dateTime; // Task due date and time

  Task(
      {required this.name,
      required this.description,
      required this.dateTime}); // Constructor for Task
}

// MyAppState class, extends ChangeNotifier for state management
class MyAppState extends ChangeNotifier {
  var pendingTasks = <Task>[]; // List to store pending tasks
  var completedTasks = <Task>[]; // List to store completed tasks

  // Method to add a task to the pending tasks list
  void addTask(String name, String description, DateTime dateTime) {
    Task task = Task(
        name: name,
        description: description,
        dateTime: dateTime); // Create a new task
    pendingTasks.add(task); // Add the task to pending tasks
    notifyListeners(); // Notify listeners of state change
  }

  // Method to mark a task as completed
  void completeTask(Task task) {
    pendingTasks.remove(task); // Remove task from pending tasks
    completedTasks.add(task); // Add task to completed tasks
    notifyListeners(); // Notify listeners of state change
  }

  // Method to mark a completed task as pending
  void uncompleteTask(Task task) {
    completedTasks.remove(task); // Remove task from completed tasks
    pendingTasks.add(task); // Add task to pending tasks
    notifyListeners(); // Notify listeners of state change
  }

  // Method to update a task
  void updateTask(Task oldTask, Task newTask) {
    if (completedTasks.contains(oldTask)) {
      completedTasks.remove(oldTask); // Remove old task from completed tasks
      completedTasks.add(newTask); // Add new task to completed tasks
      notifyListeners(); // Notify listeners of state change
    }
    pendingTasks.remove(oldTask); // Remove old task from pending tasks
    pendingTasks.add(newTask); // Add new task to pending tasks
    notifyListeners(); // Notify listeners of state change
  }

  // Method to delete a task
  void deleteTask(Task task) {
    if (pendingTasks.contains(task)) {
      pendingTasks.remove(task); // Remove task from pending tasks
      notifyListeners(); // Notify listeners of state change
    } else if (completedTasks.contains(task)) {
      completedTasks.remove(task); // Remove task from completed tasks
      notifyListeners(); // Notify listeners of state change
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {super.key, required this.title}); // Constructor for MyHomePage

  final String title; // Title of the home page

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState(); // Create a state for MyHomePage
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex =
      0; // Variable to keep track of the selected index for navigation.

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = PendingTasksPage(); // Display PendingTasksPage for index 0.
        break;
      case 1:
        page =
            const CompletedTasksPage(); // Display CompletedTasksPage for index 1.
        break;
      default:
        throw Exception(
            'Invalid index: $selectedIndex'); // Throw an exception for an invalid index.
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 900) {
        // Display a layout with NavigationRail for wider screens.
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  // Display a NavigationRail on the left side of the screen.
                  extended: true,
                  destinations: const [
                    NavigationRailDestination(
                      // Display a NavigationRailDestination for PendingTasksPage.
                      icon: Icon(Icons.timelapse),
                      label: Text('Pending'),
                    ),
                    NavigationRailDestination(
                      // Display a NavigationRailDestination for CompletedTasksPage.
                      icon: Icon(Icons.check_circle),
                      label: Text('Completed'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex =
                          value; // Update the selected index on rail item selection.
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
        // Display a layout with BottomNavigationBar for smaller screens.
        return Scaffold(
          body: page,
          bottomNavigationBar: BottomNavigationBar(
            // Display a BottomNavigationBar at the bottom of the screen.
            items: const [
              BottomNavigationBarItem(
                // Display a BottomNavigationBarItem for PendingTasksPage.
                icon: Icon(Icons.timelapse),
                label: 'Pending',
              ),
              BottomNavigationBarItem(
                // Display a BottomNavigationBarItem for CompletedTasksPage.
                icon: Icon(Icons.check_circle),
                label: 'Completed',
              ),
            ],
            currentIndex: selectedIndex, // Set the selected index.
            onTap: (value) {
              setState(() {
                selectedIndex =
                    value; // Update the selected index on bottom navigation item tap.
              });
            },
          ),
        );
      }
    });
  }
}

// Maybe add input validation here, it is true that when you add a task with empty fields you cannot do it
// but it would be better to show a message to the user.
class PendingTasksPage extends StatelessWidget {

  //  to truly reduce the scope of these variables, you can encapsulate them within a custom widget or class

  final TextEditingController _nameController =
      TextEditingController(); // Controller for the name text field
  final TextEditingController _descriptionController =
      TextEditingController(); // Controller for the description text field
  final TextEditingController _dateTimeController =
      TextEditingController(); // Controller for the date and time text field

  PendingTasksPage({super.key}); // Constructor for PendingTasksPage

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Get the app state

    // Optimization to have a better look on chrome would be good.
    // It is user friendly but it is not very good looking.
    
    return Scaffold(
      appBar: AppBar(
        // Display an AppBar at the top of the screen
        toolbarHeight: 140, // Set the height of the toolbar
        title: const Padding(
          // Display a title for the app bar
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
        // Display a column of widgets
        children: [
          Expanded(
            child: ListView.builder(
              // Display a list view of pending tasks
              itemCount: appState.pendingTasks
                  .length, // Set the number of items in the list view
              itemBuilder: (context, index) {
                // Build the list view
                return ListTile(
                  // Display a list tile for each task
                  title: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align the text to the left
                    children: [
                      Text(
                        appState.pendingTasks[index]
                            .name, // Display the name of the task
                        style: const TextStyle(
                            fontWeight:
                                FontWeight.bold), // Set the font weight to bold
                      ),
                      Text(
                          'Description: ${appState.pendingTasks[index].description}'), // Display the description of the task
                      Text(
                          'Date and Time: ${formatDate(appState.pendingTasks[index].dateTime)}'), // Display the date and time of the task
                    ],
                  ),
                  leading: IconButton(
                    // Display an icon button to complete the task
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      appState.completeTask(
                          appState.pendingTasks[index]); // Complete the task
                    },
                  ),
                  onTap: () {
                    // Display the task details page on tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsPage(
                          task: appState.pendingTasks[
                              index], // Pass the task to the task details page
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Align(
            // Align the floating action button to the bottom right
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                // Set the size of the floating action button
                width: 70,
                height: 70,
                child: FloatingActionButton(
                  // Display a floating action button to add a task
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          // Display an alert dialog to add a task
                          title: const Text('Add Task'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              // Consider creating custom widgets or functions for these shared elements to reduce redundancy.

                              TextField(
                                // Display a text field to enter the name of the task
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                // Display a text field to enter the description of the task
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                // Display a text field to enter the date and time of the task
                                controller: _dateTimeController,
                                decoration: const InputDecoration(
                                  labelText: 'Date and Time',
                                ),
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    // Display a date picker to select the date of the task
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );

                                  if (pickedDate != null) {
                                    // Display a time picker to select the time of the task
                                    TimeOfDay? pickedTime =
                                        // ignore: use_build_context_synchronously
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );

                                    if (pickedTime != null) {
                                      // Set the date and time of the task
                                      DateTime selectedDateTime = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );

                                      _dateTimeController.text = selectedDateTime
                                          .toString(); // Set the text of the date and time text field
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                          actions: [
                            // Display buttons to add or cancel the task
                            TextButton(
                              onPressed: () {
                                if (_nameController.text.isNotEmpty &&
                                    _descriptionController.text.isNotEmpty &&
                                    _dateTimeController.text.isNotEmpty) {
                                  // Check if all the fields are filled
                                  DateTime dateTime = DateTime.parse(
                                      _dateTimeController
                                          .text); // Parse the date and time string to a DateTime object
                                  appState.addTask(
                                      _nameController.text,
                                      _descriptionController.text,
                                      dateTime); // Add the task
                                  Navigator.pop(context); // Close the dialog
                                  _nameController.clear();
                                  _descriptionController.clear();
                                  _dateTimeController
                                      .clear(); // Clear the text fields
                                }
                              },
                              child: const Text(
                                  'Add'), // Display a button to add the task
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(
                    '+',
                    style: TextStyle(
                        fontSize: 24), // Set the font size of the text
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
  const CompletedTasksPage({super.key}); // Constructor for CompletedTasksPage

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Get the app state

    return Scaffold(
      appBar: AppBar(
        // Display an AppBar at the top of the screen
        toolbarHeight: 140,
        title: const Padding(
          // Display a title for the app bar
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
        // Display a list view of completed tasks
        itemCount: appState
            .completedTasks.length, // Set the number of items in the list view
        itemBuilder: (context, index) {
          // Build the list view
          return ListTile(
            // Display a list tile for each task
            title: Column(
              // Display the details of the task
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align the text to the left
              children: [
                Text(
                  appState.completedTasks[index]
                      .name, // Display the name of the task
                  style: const TextStyle(
                      fontWeight:
                          FontWeight.bold), // Set the font weight to bold
                ),
                Text(
                    'Description: ${appState.completedTasks[index].description}'), // Display the description of the task
                Text(
                    'Date and Time: ${formatDate(appState.completedTasks[index].dateTime)}'), // Display the date and time of the task
              ],
            ),
            leading: IconButton(
              // Display an icon button to mark the task as pending
              icon: const Icon(Icons.undo),
              onPressed: () {
                appState.uncompleteTask(
                    appState.completedTasks[index]); // Mark the task as pending
              },
            ),
          );
        },
      ),
    );
  }
}

class TaskDetailsPage extends StatefulWidget {
  final Task task; // Task to display the details of

  const TaskDetailsPage({Key? key, required this.task})
      : super(key: key); // Constructor for TaskDetailsPage

  @override
  // ignore: library_private_types_in_public_api
  _TaskDetailsPageState createState() =>
      _TaskDetailsPageState(); // Create a state for TaskDetailsPage
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late TextEditingController
      _nameController; // Controller for the name text field
  late TextEditingController
      _descriptionController; // Controller for the description text field
  late TextEditingController
      _dateTimeController; // Controller for the date and time text field

  @override
  void initState() {
    super.initState(); // Call the super class initState method
    _nameController = TextEditingController(
        text: widget.task.name); // Set the text of the name text field
    _descriptionController = TextEditingController(
        text: widget
            .task.description); // Set the text of the description text field
    _dateTimeController = TextEditingController(
        text: widget.task.dateTime
            .toString()); // Set the text of the date and time text field
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dateTimeController.dispose(); // Dispose the controllers
    super.dispose(); // Call the super class dispose method
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Get the app state

    return Scaffold(
      appBar: AppBar(
        // Display an AppBar at the top of the screen
        toolbarHeight: 100,
        title: Text(widget.task.name),
      ),
      body: Center(
        // form to edit the details of a task
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Align the widgets to the center
          children: [
            Padding(
              // Display a text field to edit the name of the task
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
              // Display a text field to edit the description of the task
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
              // Display a text field to edit the date and time of the task
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
                  ); // Display a date picker to select the date of the task

                  if (pickedDate != null) {
                    // ignore: use_build_context_synchronously
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(widget.task.dateTime),
                    ); // Display a time picker to select the time of the task

                    if (pickedTime != null) {
                      setState(() {
                        widget.task.dateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        ); // Set the date and time of the task
                        _dateTimeController.text = formatDate(widget.task
                            .dateTime); // Set the text of the date and time text field
                      });
                    }
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Align the widgets to the center
              children: [
                ElevatedButton(
                  // Display a button to complete the task
                  onPressed: () {
                    appState.completeTask(widget.task);
                    Navigator.pop(context);
                  },
                  child: const Text('Complete'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  // Display a button to delete the task
                  onPressed: () {
                    appState.deleteTask(widget.task);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  // Display a button to update the task
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
