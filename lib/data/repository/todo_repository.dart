import 'dart:collection';

import '../model/todo_model.dart';

abstract interface class ToDoRepository {
  Future<LinkedHashMap<DateTime, List<Event>>> getTodoEvents();
}