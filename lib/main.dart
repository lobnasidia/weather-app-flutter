import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyWeatherApp());
}

class MyWeatherApp extends StatelessWidget {
  const MyWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherHomePage(title: 'Météo Actuelle'),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key, required this.title});

  final String title;

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  String _weather = 'Chargement...';
  double _temperature = 0.0;
  String _city = 'Paris'; // Ville par défaut

  // Remplacez par votre clé API OpenWeatherMap
  final String _apiKey = 'b4559872cd0737a0752642ca5f92a0e5';

  Future<void> _getWeather(String city) async {
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weather = data['weather'][0]['description'];
          _temperature = data['main']['temp'];
        });
      } else {
        setState(() {
          _weather = 'Erreur : ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _weather = 'Erreur de connexion';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getWeather(_city); // Charger la météo par défaut au démarrage
  }

  void _goToSettingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          onCityChanged: (newCity) {
            setState(() {
              _city = newCity;
              _getWeather(_city); // Mettre à jour la météo pour la nouvelle ville
            });
          },
        ),
      ),
    );
  }

  void _goToAproposPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AproposPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Ville : $_city',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Météo : $_weather',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Température : ${_temperature.toStringAsFixed(1)}°C',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: const Text('Menu', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: _goToSettingsPage,
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('À propos'),
              onTap: _goToAproposPage,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final Function(String) onCityChanged;

  const SettingsPage({super.key, required this.onCityChanged});

  @override
  Widget build(BuildContext context) {
    final TextEditingController cityController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: 'Entrez une ville'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newCity = cityController.text;
                if (newCity.isNotEmpty) {
                  onCityChanged(newCity);
                  Navigator.pop(context);
                }
              },
              child: const Text('Changer de ville'),
            ),
          ],
        ),
      ),
    );
  }
}

class AproposPage extends StatelessWidget {
  const AproposPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: const Center(
        child: Text('Application météo simple avec Flutter.'),
      ),
    );
  }
}
