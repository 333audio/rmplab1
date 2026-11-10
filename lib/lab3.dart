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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CardListPage(),
    );
  }
}

// Модель данных для карточки
class CityCard {
  final String name;
  final String description;
  final String imageUrl;
  final int population;

  CityCard({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.population,
  });
}

class CardListPage extends StatelessWidget {
  const CardListPage({super.key});

  // Список городов с данными
  final List<CityCard> cities = [
    CityCard(
      name: 'Москва',
      description: 'Столица России, крупнейший город страны',
      imageUrl: 'https://images.unsplash.com/photo-1513326738677-b964603b136d?w=400',
      population: 12_500_000,
    ),
    CityCard(
      name: 'Санкт-Петербург',
      description: 'Культурная столица России, город на Неве',
      imageUrl: 'https://images.unsplash.com/photo-1556610961-2fecc5927173?w=400',
      population: 5_400_000,
    ),
    CityCard(
      name: 'Казань',
      description: 'Столица Татарстана, город тысячелетней истории',
      imageUrl: 'https://images.unsplash.com/photo-1596484552834-6a58f850e0a1?w=400',
      population: 1_300_000,
    ),
    CityCard(
      name: 'Новосибирск',
      description: 'Крупнейший город Сибири, научный центр',
      imageUrl: 'https://images.unsplash.com/photo-1565008576549-57569a49371d?w=400',
      population: 1_600_000,
    ),
    CityCard(
      name: 'Екатеринбург',
      description: 'Город на границе Европы и Азии',
      imageUrl: 'https://images.unsplash.com/photo-1571127236794-81c0bbfe1ce3?w=400',
      population: 1_500_000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Сайгушев Данил Андреевич, Группа Пдо-37'),
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
                // Картинка города
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
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
                // Текст с информацией
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        city.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 20, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Население: ${city.population.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]} ',
                            )} чел.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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