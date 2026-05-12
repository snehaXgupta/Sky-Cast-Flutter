import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _weatherUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  Future<List<Location>> searchLocations(String query) async {
    final response = await http.get(Uri.parse('$_geocodingUrl?name=$query&count=5&language=en&format=json'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] == null) return [];
      return (data['results'] as List).map((item) => Location.fromJson(item)).toList();
    } else {
      throw Exception('Failed to search locations');
    }
  }

  Future<Weather> fetchWeather(double lat, double lon) async {
    final response = await http.get(Uri.parse(
        '$_weatherUrl?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&timezone=auto'));

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
