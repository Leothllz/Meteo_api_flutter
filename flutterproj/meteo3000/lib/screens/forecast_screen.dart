import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class ForecastScreen extends StatefulWidget {
  final String cityName;

  ForecastScreen({required this.cityName});

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  List<WeatherModel>? _forecastData;

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    try {
      final weatherService = WeatherService();
      final forecastData = await weatherService.getForecast(widget.cityName);
      final List<dynamic> list = forecastData['list'];
      setState(() {
        _forecastData = list.map((e) => WeatherModel.fromJson(e)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching forecast data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forecast for ${widget.cityName}'),
      ),
      body: _forecastData == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _forecastData!.length,
              itemBuilder: (context, index) {
                final weather = _forecastData![index];
                return ListTile(
                  title: Text('Date: ${weather.date}'),
                  subtitle: Text(
                      'Temperature: ${weather.temperature}°C, Condition: ${weather.description}'),
                );
              },
            ),
    );
  }
}
