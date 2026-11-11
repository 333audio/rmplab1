import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Лабораторная 5',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow)),
      home: const PokemonSearchPage(),
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
        return null; // Покемон не найден
      }
    } catch (e) {
      debugPrint('Ошибка сети: $e');
      return null;
    }
  }
}

// ==========================================
// 4. UI (Экран поиска)
// ==========================================
class PokemonSearchPage extends StatefulWidget {
  const PokemonSearchPage({super.key});

  @override
  State<PokemonSearchPage> createState() => _PokemonSearchPageState();
}

class _PokemonSearchPageState extends State<PokemonSearchPage> {
  final PokemonRepository _repository = PokemonRepositoryImpl();
  final TextEditingController _searchController = TextEditingController();

  PokemonDto? _pokemon;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _searchPokemon() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _pokemon = null;
    });

    final result = await _repository.searchPokemon(query);

    setState(() {
      _isLoading = false;
      if (result != null) {
        _pokemon = result;
      } else {
        _errorMessage = 'Покемон "$query" не найден. Попробуй "pikachu" или "charizard".';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сайгушев Данил Андреевич, Группа Пдо-37'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Введите имя (напр. pikachu)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _searchPokemon(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchPokemon,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Найти'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Center(
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
              )
            else if (_pokemon != null)
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _pokemon!.imageUrl.isNotEmpty
                              ? Image.network(_pokemon!.imageUrl, height: 150, errorBuilder: (_, __, ___) => const Icon(Icons.pets, size: 100, color: Colors.grey))
                              : const Icon(Icons.pets, size: 100, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(_pokemon!.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn('Рост', '${_pokemon!.height} дм'),
                              _buildStatColumn('Вес', '${_pokemon!.weight} г'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            alignment: WrapAlignment.center,
                            children: _pokemon!.types.map((type) => Chip(label: Text(type), backgroundColor: Colors.yellow.shade100)).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
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