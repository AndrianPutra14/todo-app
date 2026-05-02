import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/todo_provider.dart';
import '../widgets/todo_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TodoProvider>().loadTodos();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showAddTodoDialog() async {
    _controller.clear();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Todo Baru'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Masukkan tugas...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _addTodo(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => _addTodo(context),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _addTodo(BuildContext context) {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    context.read<TodoProvider>().addTodo(title);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final todos = provider.todos;
    final completedCount = todos.where((t) => t.done).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadTodos(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(provider.error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => provider.loadTodos(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : todos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.task_alt, size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada todo',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          const Text('Tekan tombol + untuk menambahkan'),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${todos.length} tugas',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$completedCount selesai',
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: todos.length,
                            itemBuilder: (context, index) {
                              return TodoCard(
                                todo: todos[index],
                                onToggle: () => provider.toggleTodo(todos[index].id, todos[index].done),
                                onDelete: () => provider.deleteTodo(todos[index].id),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
