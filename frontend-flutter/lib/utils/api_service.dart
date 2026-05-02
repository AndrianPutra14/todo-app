import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class ApiService {
  // Change this to your machine's local IP when testing on real device
  // For iOS Simulator or Android Emulator, use 10.0.2.2 (Android) or localhost (iOS)
  static const String baseUrl = 'http://localhost:8080/api';

  Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/todos'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Todo.fromJson(json)).toList();
    }
    throw Exception('Failed to load todos');
  }

  Future<Todo> createTodo(String title) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title}),
    );
    if (response.statusCode == 201) {
      return Todo.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create todo');
  }

  Future<Todo> updateTodo(int id, {String? title, bool? done}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/todos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        if (title != null) 'title': title,
        if (done != null) 'done': done,
      }),
    );
    if (response.statusCode == 200) {
      return Todo.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update todo');
  }

  Future<void> deleteTodo(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/todos/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete todo');
    }
  }
}
