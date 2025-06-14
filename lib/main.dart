import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _weather = '';
  bool _loading = false;

  // 🔑 Your OpenWeatherMap API key
  static const String apiKey = 'e17416922f46bcfc873a13b01a26a278';

  Future<void> fetchWeather(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    setState(() => _loading = true);

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temp = data['main']['temp'];
        final description = data['weather'][0]['description'];

        setState(() {
          _weather =
              'Temperature: $temp°C\nCondition: ${description[0].toUpperCase()}${description.substring(1)}';
          _loading = false;
        });
      } else {
        setState(() {
          _weather = 'City not found!';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _weather = 'Error fetching data.';
        _loading = false;
      });
    }
  }

  final List<String> weatherFacts = [
    'The highest temperature ever recorded was 56.7°C in Death Valley, USA.',
    'Raindrops can fall at speeds of about 35 km/h.',
    'Snowflakes can take up to an hour to fall from the sky.',
    'The coldest temperature on Earth was -89.2°C in Antarctica.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple Weather App'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter City Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => fetchWeather(_controller.text),
              child: Text('Get Weather'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: _loading
                  ? CircularProgressIndicator()
                  : Text(
                      _weather,
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
            ),
            SizedBox(height: 30),
            Divider(),
            Text(
              '🌤️ Fun Weather Facts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ...weatherFacts.map((fact) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(child: Text(fact, style: TextStyle(fontSize: 16))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
