import 'dart:async';

// 1. ENUMS (Перечисления)
enum TaskStatus { pending, inProgress, completed }

// 2. CLASSES (Классы с полями и методами)
class Task {
  final String title;
  final TaskStatus status;

  Task(this.title, this.status);

  void printInfo() {
    print('Задача: $title | Статус: $status');
  }
}

// 3. GENERICS (Дженерики)
class DataWrapper<T> {
  final List<T> items;

  DataWrapper(this.items);

  int get count => items.length;
}

// 4. EXTENSION (Расширения)
extension StringExtension on String {
  String get capitalized => '${this[0].toUpperCase()}${substring(1)}';
}

// 5. FUTURE + 6. ANONYMOUS FUNCTIONS + 7. LOOPS
Future<void> main() async {
  print('=== Лабораторная 2: Знакомство с Dart ===\n');

  print('--- 1. Future (асинхронность) ---');
  await Future.delayed(const Duration(seconds: 1), () {
    print('Данные успешно загружены!\n');
  });

  List<Task> tasks = [
    Task('изучить dart', TaskStatus.completed),
    Task('написать лабу по РМП', TaskStatus.inProgress),
    Task('сдать проект', TaskStatus.pending),
  ];

  print('--- 2. Generics (дженерики) ---');
  DataWrapper<Task> wrapper = DataWrapper(tasks);
  print('Всего задач в контейнере: ${wrapper.count}\n');

  print('--- 3. Loops + Anonymous functions ---');
  var activeTasks = tasks.where((task) => task.status != TaskStatus.completed).toList();

  for (var task in activeTasks) {
    task.printInfo();
  }

  print('\n--- 4. Extension ---');
  String rawTitle = "мобильная разработка";
  print('Оригинал: $rawTitle -> Формат: ${rawTitle.capitalized}');

  print('\n--- 5. Anonymous function в forEach ---');
  tasks.map((t) => t.title).toList().forEach((title) {
    print('Обработанная задача: $title');
  });

