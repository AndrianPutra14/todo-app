import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../utils/api_service.dart';

class TodoProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTodos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todos = await _apiService.fetchTodos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(String title) async {
    try {
      final todo = await _apiService.createTodo(title);
      _todos.add(todo);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleTodo(int id, bool done) async {
    try {
      final updated = await _apiService.updateTodo(id, done: !done);
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await _apiService.deleteTodo(id);
      _todos.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
