import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:weather_icons/weather_icons.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'forecast_screen.dart';
import '../services/json_file_manager.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _cityController = TextEditingController();
  WeatherModel? _weatherData;
  bool _isLoading = false;

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final weatherService = WeatherService();
      final weatherData = await weatherService.getWeather(_cityController.text);
      setState(() {
        _weatherData = WeatherModel.fromJson(weatherData);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erreur lors de la récupération des données météo: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addToFavorites() async {
    if (_weatherData != null) {
      List<String> favorites = await JsonFileManager.readFavorites();
      if (!favorites.contains(_cityController.text)) {
        favorites.add(_cityController.text);
        await JsonFileManager.writeFavorites(favorites);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ville ajoutée aux favoris')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ville déjà dans les favoris')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application Météo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Entrez la ville',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchWeather,
              child: Text('Obtenir la Météo'),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              SpinKitFadingCircle(
                color: Colors.blue,
                size: 50.0,
              )
            else if (_weatherData != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Ville: ${_cityController.text}'),
                      Text('Température: ${_weatherData!.temperature}°C'),
                      Text('Condition: ${_weatherData!.description}'),
                      Icon(
                        _getWeatherIcon(_weatherData!.description),
                        size: 48,
                      ),
                      ElevatedButton(
                        onPressed: _addToFavorites,
                        child: Text('Ajouter aux Favoris'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 500),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      ForecastScreen(
                                          cityName: _cityController.text),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                var begin = Offset(1.0, 0.0);
                                var end = Offset.zero;
                                var curve = Curves.ease;

                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Text('Voir la Prévision'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
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
