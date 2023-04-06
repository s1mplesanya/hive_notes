import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo/domain/data_provider/box_manager.dart';
import 'package:todo/domain/entity/group.dart';
import 'package:todo/ui/widgets/tasks/tasks_widget.dart';

import '../../navigation/main_navigation.dart';

class GroupWidgetModel extends ChangeNotifier {
  var _groups = <Group>[];

  ValueListenable<Object>? _listenableBox;

  List<Group> get groups => _groups.toList();

  late final Future<Box<Group>> _box;

  GroupWidgetModel() {
    _setUp();
  }

  void openForm(BuildContext context) {
    Navigator.of(context).pushNamed(MainNavigationRoutesName.groupsForm);
  }

  Future<void> showTasks(BuildContext context, int groupIndex) async {
    final group = (await _box).getAt(groupIndex);
    if (group != null) {
      final configuration = TaskWidgetConfiguration(
        group.key as int,
        group.name,
      );
      unawaited(Navigator.of(context)
          .pushNamed(MainNavigationRoutesName.tasks, arguments: configuration));
    }
  }

  Future<void> _readGroupFromHive() async {
    _groups = (await _box).values.toList();
    notifyListeners();
  }

  Future<void> _setUp() async {
    _box = BoxManager.instance.openGroupBox();
    await _readGroupFromHive();

    _listenableBox = (await _box).listenable();
    _listenableBox?.addListener(_readGroupFromHive);
  }

  Future<void> deleteGroup(int index) async {
    final box = await _box;
    final groupKey = (await _box).keyAt(index) as int;
    final taskBoxName = BoxManager.instance.makeTaskBoxName(groupKey);
    Hive.deleteBoxFromDisk(taskBoxName);
    await box.deleteAt(index);
  }

  @override
  Future<void> dispose() async {
    _listenableBox?.removeListener(_readGroupFromHive);
    await BoxManager.instance.closeBox(await _box);
    super.dispose();
  }
}

class GroupWidgetModelProvider extends InheritedNotifier {
  final GroupWidgetModel model;
  const GroupWidgetModelProvider({
    Key? key,
    required this.model,
    required Widget child,
  }) : super(
          key: key,
          notifier: model,
          child: child,
        );

  static GroupWidgetModelProvider? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GroupWidgetModelProvider>();
  }

  static GroupWidgetModelProvider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<GroupWidgetModelProvider>()
        ?.widget;
    return widget is GroupWidgetModelProvider ? widget : null;
  }
}
