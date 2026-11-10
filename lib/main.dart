import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Лабораторная 3',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      home: const CardListPage(),
    );
  }
}

// 1. Модель данных (ОБЯЗАТЕЛЬНО с const конструктором)
class CityCard {
  final String name;
  final String description;
  final String imageUrl;

  const CityCard({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
  // 2. Список данных (обычный final, без const, чтобы избежать ошибок)
  final List<CityCard> cities = [
    CityCard(
      name: 'Москва',
      description: 'Столица России, крупнейший город страны.',
      imageUrl: 'https://images.unsplash.com/photo-1513326738677-b964603b136d?w=400',
    ),
    CityCard(
      name: 'Санкт-Петербург',
      description: 'Культурная столица России, город на Неве.',
      imageUrl: 'https://images.unsplash.com/photo-1556610961-2fecc5927173?w=400',
    ),
    CityCard(
      name: 'Казань',
      description: 'Столица Татарстана, город тысячелетней истории.',
      imageUrl: 'https://images.unsplash.com/photo-1596484552834-6a58f850e0a1?w=400',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сайгушев Данил Андреевич, Группа Пдо-37'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final city = cities[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Картинка
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  child: Image.network(
                    city.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50),
                      );
                    },
                  ),
                ),
                // Текст
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        city.description,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}