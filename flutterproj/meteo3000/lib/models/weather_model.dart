class WeatherModel {
  final double temperature;
  final String description;
  final String date;

  WeatherModel({
    required this.temperature,
    required this.description,
    required this.date,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['main']['temp'],
      description: json['weather'][0]['description'],
      date: json['dt_txt'] ??
          DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000).toString(),
    );
  }
}
