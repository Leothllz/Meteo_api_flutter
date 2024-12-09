import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/json_file_manager.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> _favorites = [];
  Map<String, WeatherModel> _weatherData = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _favorites = [];
      _weatherData = {};
    });
    _favorites = await JsonFileManager.readFavorites();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    final weatherService = WeatherService();
    for (var city in _favorites) {
      try {
        final weatherData = await weatherService.getWeather(city);
        setState(() {
          _weatherData[city] = WeatherModel.fromJson(weatherData);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erreur lors de la récupération des données météo pour $city: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoris'),
      ),
      body: _favorites.isEmpty
          ? Center(child: Text('Aucun favori'))
          : ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: ListView.builder(
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final city = _favorites[index];
                  final weather = _weatherData[city];
                  return ListTile(
                    title: Text(city),
                    subtitle: weather != null
                        ? Row(
                            children: [
                              Text(
                                  'Température: ${weather.temperature}°C, Condition: ${weather.description}'),
                              SizedBox(width: 10),
                              Icon(
                                _getWeatherIcon(weather.description),
                                size: 24,
                              ),
                            ],
                          )
                        : Text('Chargement...'),
                  );
                },
              ),
            ),
    );
  }

  IconData _getWeatherIcon(String description) {
    if (description.contains('sunny') || description.contains('clear')) {
      return WeatherIcons.day_sunny;
    } else if (description.contains('rain')) {
      return WeatherIcons.rain;
    } else if (description.contains('cloud')) {
      return WeatherIcons.cloudy;
    } else if (description.contains('snow')) {
      return WeatherIcons.snow;
    } else {
      return WeatherIcons.day_sunny;
    }
  }
}
