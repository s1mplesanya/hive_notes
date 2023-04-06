import 'package:flutter/material.dart';

import '../widgets/group_form/group_form_widget.dart';
import '../widgets/groups/groups_widget.dart';
import '../widgets/task_form/task_form_widget.dart';
import '../widgets/tasks/tasks_widget.dart';

class MainNavigationRoutesName {
  static const groups = '/'; // '/groups'
  static const groupsForm = '/groupsForm';
  static const tasks = '/tasks';
  static const tasksForm = '/tasks/form';
}

class MainNavigation {
  final initialRoute = MainNavigationRoutesName.groups;
  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRoutesName.groups: (context) => const GroupsWidget(),
    MainNavigationRoutesName.groupsForm: (context) => const GroupFormWidget(),
    // MainNavigationRoutesName.tasks: (context) => const TasksWidget(),
    // MainNavigationRoutesName.tasksForm: (context) => const TaskFormWidget(),
  };

  Route<Object>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRoutesName.tasks:
        final configuration = settings.arguments as TaskWidgetConfiguration;
        return MaterialPageRoute(
            builder: (context) => TasksWidget(configuration: configuration));
      case MainNavigationRoutesName.tasksForm:
        int groupKey = settings.arguments as int;
        return MaterialPageRoute(
            builder: (context) => TaskFormWidget(groupKey: groupKey));
      default:
        const widget = Text('Nagivation error!');
        return MaterialPageRoute(builder: (context) => widget);
    }
  }
}
