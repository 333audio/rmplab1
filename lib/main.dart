import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

// ==========================================
// ЛОКАЛИЗАЦИЯ
// ==========================================
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'My Favorites',
      'add_item': 'Add',
      'hint': 'Enter item name...',
      'saved': 'Saved items:',
      'empty': 'No items yet',
      'delete': 'Delete',
    },
    'ru': {
      'title': 'Моё Избранное',
      'add_item': 'Добавить',
      'hint': 'Введите название...',
      'saved': 'Сохраненные элементы:',
      'empty': 'Список пуст',
      'delete': 'Удалить',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'ru'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// ==========================================
// ПРИЛОЖЕНИЕ
// ==========================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('ru');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 7',
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ru')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: FavoritesPage(onLocaleChange: setLocale),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  const FavoritesPage({super.key, required this.onLocaleChange});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> _items = [];
  final TextEditingController _controller = TextEditingController();

  void _addItem() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _items.add(_controller.text);
        _controller.clear();
      });
    }
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(loc.translate('title')),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            itemBuilder: (context) => [
              const PopupMenuItem(value: Locale('ru'), child: Text('Русский')),
              const PopupMenuItem(value: Locale('en'), child: Text('English')),
            ],
            onSelected: (locale) {
              widget.onLocaleChange(locale);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: loc.translate('hint'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItem,
                  child: Text(loc.translate('add_item')),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.translate('saved'), style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _items.isEmpty
                      ? Center(child: Text(loc.translate('empty'), style: TextStyle(color: Colors.grey[600])))
                      : Expanded(
                    child: ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(_items[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteItem(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}