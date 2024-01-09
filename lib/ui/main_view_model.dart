import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todolist/data/model/todo_model.dart';
import 'package:todolist/data/repository/todo_repository.dart';

import '../data/repository/todo_repository_impl.dart';

class MainViewModel extends ChangeNotifier {
  final ToDoRepository _repository;

  DateTime _focusedDay = DateTime.now().toUtc();

  // DateTime? _selectedDay;
  ValueNotifier<List<Event>> _selectedEvents = ValueNotifier([]);

  //TODO 뭔가 이상함
  LinkedHashMap<DateTime, List<Event>> _events =
      LinkedHashMap<DateTime, List<Event>>(); // 초기화

  //Main State 적용 실패... => getter 사용
  get focusedDay => _focusedDay;

  // get selectedDay => _selectedDay;

  get selectedEvents => _selectedEvents;

  get onDaySelected => _onDaySelected;

  get events => _events;

  get getEventsForDay => _getEventsForDay;

  final _debounce = Debounce(const Duration(milliseconds: 500));

  MainViewModel({
    required ToDoRepository repository,
  }) : _repository = repository {
    getTodoList();
    _selectedEvents.value = _getEventsForDays(selectedDays);
    notifyListeners();
  }

  _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _focusedDay = focusedDay;
    // Update values in a Set
    if (selectedDays.contains(selectedDay)) {
      selectedDays.remove(selectedDay);
    } else {
      selectedDays.add(selectedDay);
    }
    //TODO _selectedEvents 처리
    _selectedEvents.value = _getEventsForDays(selectedDays);
    notifyListeners();
  }

  final Set<DateTime> selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  List<Event> _getEventsForDays(Set<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  //TODO 뭔가 이상함
  Future<void> getTodoList() async {
    _events = await _repository.getTodoEvents();
    notifyListeners();
  }

  resetSelectedEvents() {
    selectedDays.clear();
    _selectedEvents.value = [];
    notifyListeners();
  }}



class Debounce {
  final Duration duration;
  Timer? _timer;

  Debounce(this.duration);

  void onEvent(void Function() callback) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(duration, () => callback());
  }
}
