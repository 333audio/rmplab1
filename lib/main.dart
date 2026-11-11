import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Для Timer (Debounce)
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Лабораторная 6',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow)),
      home: BlocProvider(
        create: (context) => PokemonBloc(PokemonRepositoryImpl()),
        child: const PokemonSearchPage(),
      ),
    );
  }
}

// ==========================================
// 1. DTO (Data Transfer Object)
// ==========================================
class PokemonDto {
  final String name;
  final String imageUrl;
  final int height;
  final int weight;
  final List<String> types;

  PokemonDto({
    required this.name,
    required this.imageUrl,
    required this.height,
    required this.weight,
    required this.types,
  });

  factory PokemonDto.fromJson(Map<String, dynamic> json) {
    return PokemonDto(
      name: json['name'].toString().toUpperCase(),
      imageUrl: json['sprites']['front_default'] ?? '',
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      types: (json['types'] as List)
          .map((e) => e['type']['name'].toString().toUpperCase())
          .toList(),
    );
  }
}

// ==========================================
// 2. Интерфейс репозитория
// ==========================================
abstract class PokemonRepository {
  Future<PokemonDto?> searchPokemon(String name);
}

// ==========================================
// 3. Реализация репозитория
// ==========================================
class PokemonRepositoryImpl implements PokemonRepository {
  @override
  Future<PokemonDto?> searchPokemon(String name) async {
    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/${name.toLowerCase().trim()}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PokemonDto.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Ошибка сети: $e');
      return null;
    }
  }
}

// ==========================================
// 4. BLoC: События (Events)
// ==========================================
abstract class PokemonEvent extends Equatable {
  const PokemonEvent();
  @override
  List<Object> get props => [];
}

class SearchPokemonEvent extends PokemonEvent {
  final String query;
  const SearchPokemonEvent(this.query);
  @override
  List<Object> get props => [query];
}

class RefreshPokemonEvent extends PokemonEvent {}

// ==========================================
// 5. BLoC: Состояния (States)
// ==========================================
abstract class PokemonState extends Equatable {
  const PokemonState();
  @override
  List<Object> get props => [];
}

class PokemonInitial extends PokemonState {}

class PokemonLoading extends PokemonState {}

class PokemonLoaded extends PokemonState {
  final PokemonDto pokemon;
  const PokemonLoaded(this.pokemon);
  @override
  List<Object> get props => [pokemon];
}

class PokemonError extends PokemonState {
  final String message;
  const PokemonError(this.message);
  @override
  List<Object> get props => [message];
}

// ==========================================
// 6. BLoC: Логика
// ==========================================
class PokemonBloc extends Bloc<PokemonEvent, PokemonState> {
  final PokemonRepository repository;
  String _lastQuery = '';

  PokemonBloc(this.repository) : super(PokemonInitial()) {
    on<SearchPokemonEvent>(_onSearch);
    on<RefreshPokemonEvent>(_onRefresh);
  }

  Future<void> _onSearch(SearchPokemonEvent event, Emitter<PokemonState> emit) async {
    if (event.query.trim().isEmpty) return;
    _lastQuery = event.query.trim();

    emit(PokemonLoading());
    final result = await repository.searchPokemon(_lastQuery);

    if (result != null) {
      emit(PokemonLoaded(result));
    } else {
      emit(PokemonError('Покемон "$_lastQuery" не найден. Попробуй "pikachu" или "charizard".'));
    }
  }

  Future<void> _onRefresh(RefreshPokemonEvent event, Emitter<PokemonState> emit) async {
    if (_lastQuery.isNotEmpty) {
      add(SearchPokemonEvent(_lastQuery));
    }
  }
}

// ==========================================
// 7. UI (Экран с BLoC, Debounce и Refresh)
// ==========================================
class PokemonSearchPage extends StatefulWidget {
  const PokemonSearchPage({super.key});

  @override
  State<PokemonSearchPage> createState() => _PokemonSearchPageState();
}

class _PokemonSearchPageState extends State<PokemonSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Метод для обновления страницы (Pull-to-refresh)
  Future<void> _onRefresh() async {
    debugPrint('Pull-to-refresh triggered!');
    context.read<PokemonBloc>().add(RefreshPokemonEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сайгушев Данил Андреевич, Группа Пдо-37'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: BlocBuilder<PokemonBloc, PokemonState>(
          builder: (context, state) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(), // ← Позволяет свайпать всегда
              padding: const EdgeInsets.all(16.0),
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Введите имя (напр. pikachu)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: Icon(Icons.clear),
                  ),
                  // DEBOUNCE: задержка 500 мс перед отправкой запроса
                  onChanged: (value) {
                    if (_debounceTimer?.isActive ?? false) {
                      _debounceTimer!.cancel();
                    }
                    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                      context.read<PokemonBloc>().add(SearchPokemonEvent(value));
                    });
                  },
                  onSubmitted: (value) {
                    _debounceTimer?.cancel();
                    context.read<PokemonBloc>().add(SearchPokemonEvent(value));
                  },
                ),
                const SizedBox(height: 24),
                _buildBody(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(PokemonState state) {
    if (state is PokemonInitial) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          'Введите имя покемона для поиска',
          style: TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (state is PokemonLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state is PokemonError) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          state.message,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (state is PokemonLoaded) {
      final pokemon = state.pokemon;
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              pokemon.imageUrl.isNotEmpty
                  ? Image.network(
                pokemon.imageUrl,
                height: 150,
                errorBuilder: (_, __, ___) => const Icon(Icons.pets, size: 100, color: Colors.grey),
              )
                  : const Icon(Icons.pets, size: 100, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                pokemon.name,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn('Рост', '${pokemon.height} дм'),
                  _buildStatColumn('Вес', '${pokemon.weight} г'),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: pokemon.types
                    .map((type) => Chip(label: Text(type), backgroundColor: Colors.yellow.shade100))
                    .toList(),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}