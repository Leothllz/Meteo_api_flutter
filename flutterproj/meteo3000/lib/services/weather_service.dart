import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherService {
  final String apiKey = '53ba4dc86d2795a7200487b5562da5d8';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Map<String, dynamic>> getWeather(String cityName) async {
    final response = await http.get(
        Uri.parse('$baseUrl/weather?q=$cityName&units=metric&appid=$apiKey'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Échec de la récupération des données météo');
  }

  Future<Map<String, dynamic>> getForecast(String cityName) async {
    final response = await http.get(
        Uri.parse('$baseUrl/forecast?q=$cityName&units=metric&appid=$apiKey'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Échec de la récupération des données de prévision');
  }
}
