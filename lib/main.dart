import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(SkyCastApp());
}

class SkyCastApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyCast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  String? temperature = '';
  String? description = '';
  String? iconUrl = '';
  bool isLoading = false;
  String apiKey = 'e17416922f46bcfc873a13b01a26a278';

  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true;
    });

    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          temperature = "${data['main']['temp']} °C";
          description = data['weather'][0]['description'];
          iconUrl =
              'http://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png';
        });
      } else {
        setState(() {
          temperature = 'City not found';
          description = '';
          iconUrl = '';
        });
      }
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget weatherCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconUrl != null && iconUrl!.isNotEmpty)
              Image.network(iconUrl!, height: 100),
            SizedBox(height: 10),
            Text(
              temperature ?? '',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              description ?? '',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('SkyCast'),
        centerTitle: true,
        backgroundColor: Colors.blue[200],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter city name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => fetchWeather(_controller.text),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (isLoading)
              CircularProgressIndicator()
            else if (temperature != null && temperature!.isNotEmpty)
              weatherCard(),
          ],
        ),
      ),
    );
  }
}
