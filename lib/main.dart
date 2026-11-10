import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Лабораторная 4',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      home: const CardListPage(),
    );
  }
}

// Модель карточки города
class CityCard {
  final String name;
  final String description;
  final String fullDescription;
  final String imageUrl;
  final Color color;

  const CityCard({
    required this.name,
    required this.description,
    required this.fullDescription,
    required this.imageUrl,
    required this.color,
  });
}

class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
  // Список городов с реальными картинками
  final List<CityCard> cities = [
    CityCard(
      name: 'Москва',
      description: 'Столица России, крупнейший город страны.',
      fullDescription: 'Москва — столица Российской Федерации, город федерального значения. Население более 12 млн человек. Здесь находятся Кремль, Красная площадь, Большой театр и множество других достопримечательностей.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Moscow_City_view_from_Ostankino_TV_Tower.jpg/640px-Moscow_City_view_from_Ostankino_TV_Tower.jpg',
      color: Colors.red,
    ),
    CityCard(
      name: 'Санкт-Петербург',
      description: 'Культурная столица России, город на Неве.',
      fullDescription: 'Санкт-Петербург — второй по величине город России, основанный Петром I в 1703 году. Город известен Эрмитажем, разводными мостами и белыми ночами.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Saint_Petersburg_Winter_Palace.jpg/640px-Saint_Petersburg_Winter_Palace.jpg',
      color: Colors.blue,
    ),
    CityCard(
      name: 'Казань',
      description: 'Столица Татарстана, город тысячелетней истории.',
      fullDescription: 'Казань — столица Республики Татарстан. Город славится Казанским Кремлём, мечетью Кул-Шариф и уникальным сочетанием русской и татарской культур.',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Kazan_Kremlin.jpg/640px-Kazan_Kremlin.jpg',
      color: Colors.green,
    ),
  ];

  // Храним лайки
  final Set<int> likedCities = {};

  // Переключение лайка
  void toggleLike(int index) {
    setState(() {
      if (likedCities.contains(index)) {
        likedCities.remove(index);
      } else {
        likedCities.add(index);
      }
    });

    final city = cities[index];
    final isLiked = likedCities.contains(index);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isLiked
            ? '❤️ Вы лайкнули: ${city.name}'
            : '💔 Лайк убран: ${city.name}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Переход на детальный экран
  void openDetail(int index) {
    final city = cities[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailPage(city: city),
      ),
    );
  }

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
          final isLiked = likedCities.contains(index);

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Картинка с кнопкой лайка
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  child: Stack(
                    fit: StackFit.loose,
                    children: [
                      Image.network(
                        city.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: city.color.withOpacity(0.2),
                            child: const Icon(Icons.broken_image, size: 50),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: city.color.withOpacity(0.2),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                      // Кнопка лайка
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.black54,
                              size: 32,
                            ),
                            onPressed: () => toggleLike(index),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Текст + кнопка
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: city.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        city.description,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => openDetail(index),
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Подробнее'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: city.color,
                          foregroundColor: Colors.white,
                        ),
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

// Детальный экран города
class CityDetailPage extends StatelessWidget {
  final CityCard city;

  const CityDetailPage({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(city.name),
        backgroundColor: city.color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Большая картинка
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                city.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    width: double.infinity,
                    color: city.color.withOpacity(0.2),
                    child: const Icon(Icons.broken_image, size: 80),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              city.name,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: city.color,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Описание:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              city.fullDescription,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}