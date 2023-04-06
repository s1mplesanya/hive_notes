import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo/ui/navigation/main_navigation.dart';
import 'package:todo/ui/widgets/tasks/tasks_widget.dart';

import '../../../domain/data_provider/box_manager.dart';
import '../../../domain/entity/task.dart';

class TasksWidgetModel extends ChangeNotifier {
  TaskWidgetConfiguration configuration;
  late final Future<Box<Task>> _box;

  ValueListenable<Object>? _listenableBox;

  var _tasks = <Task>[];
  List<Task> get tasks => _tasks.toList();

  TasksWidgetModel({required this.configuration}) {
    _setUp();
  }

  Future<void> _readTasks() async {
    _tasks = (await _box).values.toList();
    notifyListeners();
  }

  void openForm(BuildContext context) {
    Navigator.of(context).pushNamed(MainNavigationRoutesName.tasksForm,
        arguments: configuration.groupKey);
  }

  Future<void> _setUp() async {
    _box = BoxManager.instance.openTaskBox(configuration.groupKey);

    await _readTasks();
    _listenableBox = (await _box).listenable();
    _listenableBox?.addListener(_readTasks);
  }

  Future<void> deleteTask(int taskIndex) async {
    (await _box).deleteAt(taskIndex);
  }

  Future<void> toggleDone(int taskIndex) async {
    final task = (await _box).getAt(taskIndex);
    task?.isDone = !task.isDone;
    await task?.save();
  }

  @override
  Future<void> dispose() async {
    _listenableBox?.removeListener(_readTasks);
    await BoxManager.instance.closeBox(await _box);
    super.dispose();
  }
}

class TaskWidgetModelProvider extends InheritedNotifier {
  final TasksWidgetModel model;
  const TaskWidgetModelProvider({
    Key? key,
    required this.model,
    required Widget child,
  }) : super(
          key: key,
          notifier: model,
          child: child,
        );

  static TaskWidgetModelProvider? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TaskWidgetModelProvider>();
  }

  static TaskWidgetModelProvider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<TaskWidgetModelProvider>()
        ?.widget;
    return widget is TaskWidgetModelProvider ? widget : null;
  }
}
