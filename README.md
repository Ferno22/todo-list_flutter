# To Do List

A new Flutter project for a to do list.

## General information

- The app has 2 screens:
  - Pending tasks screen.
    - It contains a list of pending tasks and a button to create new tasks:
      - When new task is button is pressed, the interface brings you a dialog or bottom sheet that allows you to enter all the details of the task. Required details:
        - Task title
        - Task description
        - Task due date (day)
        - Task due time
      - A button or an option to complete a task.
      - When the user clicks on a task, it navigates to a third page with details of the task.
  - Task details screen:
    - Here, the user can edit the task details, complete, or delete de task.
  - Completed tasks screen:
    - A simple screen that contains all completed tasks. 
    - The user can "uncomplete" the tasks in this page 
- The app uses a railbar in horizontal screens (Tablet, Computer) and a NavBar when in vertical screens (Tablet, Mobile)

