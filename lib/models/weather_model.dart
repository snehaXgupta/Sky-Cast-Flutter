class Weather {
  final double temperature;
  final String condition;
  final double windSpeed;
  final int humidity;
  final String iconCode;
  final DateTime time;

  Weather({
    required this.temperature,
    required this.condition,
    required this.windSpeed,
    required this.humidity,
    required this.iconCode,
    required this.time,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    return Weather(
      temperature: current['temperature_2m'].toDouble(),
      condition: _getConditionFromCode(current['weather_code']),
      windSpeed: current['wind_speed_10m'].toDouble(),
      humidity: current['relative_humidity_2m'].toInt(),
      iconCode: current['weather_code'].toString(),
      time: DateTime.parse(current['time']),
    );
  }

  static String _getConditionFromCode(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 57) return 'Drizzle';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Rain Showers';
    if (code <= 86) return 'Snow Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }
}

class Location {
  final String name;
  final double lat;
  final double lon;
  final String country;

  Location({
    required this.name,
    required this.lat,
    required this.lon,
    required this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'],
      lat: json['latitude'],
      lon: json['longitude'],
      country: json['country'] ?? '',
    );
  }
}
