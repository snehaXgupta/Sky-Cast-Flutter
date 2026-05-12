import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'models/weather_model.dart';
import 'services/weather_service.dart';

void main() {
  runApp(const SkyCastApp());
}

class SkyCastApp extends StatelessWidget {
  const SkyCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sky Cast',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  Location? _selectedLocation;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  List<Location> _suggestions = [];

  @override
  void initState() {
    super.initState();
    // Default location
    _fetchWeatherForLocation(Location(name: 'London', lat: 51.5074, lon: -0.1278, country: 'UK'));
  }

  Future<void> _fetchWeatherForLocation(Location location) async {
    setState(() {
      _isLoading = true;
      _selectedLocation = location;
      _suggestions = [];
      _searchController.clear();
    });

    try {
      final weather = await _weatherService.fetchWeather(location.lat, location.lon);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    try {
      final results = await _weatherService.searchLocations(query);
      setState(() => _suggestions = results);
    } catch (e) {
      // Handle error quietly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Background
          _buildBackground(),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  if (_suggestions.isNotEmpty) _buildSuggestions(),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : _weather == null
                            ? const Center(child: Text('Search for a location'))
                            : RefreshIndicator(
                                onRefresh: () => _fetchWeatherForLocation(_selectedLocation!),
                                child: SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 40),
                                      _buildLocationHeader(),
                                      const SizedBox(height: 20),
                                      _buildMainWeather(),
                                      const SizedBox(height: 40),
                                      _buildWeatherDetails(),
                                      const SizedBox(height: 40),
                                    ],
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    Color topColor = const Color(0xFF1A237E);
    Color bottomColor = const Color(0xFF0D47A1);

    if (_weather != null) {
      final code = int.tryParse(_weather!.iconCode) ?? 0;
      if (code == 0) {
        topColor = const Color(0xFF29B6F6);
        bottomColor = const Color(0xFF0288D1);
      } else if (code <= 3) {
        topColor = const Color(0xFF78909C);
        bottomColor = const Color(0xFF455A64);
      } else if (code <= 67) {
        topColor = const Color(0xFF37474F);
        bottomColor = const Color(0xFF102027);
      }
    }

    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, bottomColor],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            controller: _searchController,
            onChanged: _searchLocation,
            decoration: InputDecoration(
              hintText: 'Search city...',
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              hintStyle: const TextStyle(color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: _suggestions.map((loc) {
          return ListTile(
            title: Text(loc.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(loc.country, style: const TextStyle(color: Colors.white54)),
            onTap: () => _fetchWeatherForLocation(loc),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Column(
      children: [
        Text(
          _selectedLocation?.name ?? 'Unknown',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        Text(
          DateFormat('EEEE, d MMMM').format(DateTime.now()),
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildMainWeather() {
    return Column(
      children: [
        _getWeatherIcon(_weather!.iconCode),
        const SizedBox(height: 10),
        Text(
          '${_weather!.temperature.round()}°',
          style: const TextStyle(fontSize: 86, fontWeight: FontWeight.w200),
        ),
        Text(
          _weather!.condition,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildWeatherDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildDetailItem(Icons.water_drop_outlined, 'Humidity', '${_weather!.humidity}%'),
        _buildDetailItem(Icons.air, 'Wind', '${_weather!.windSpeed} km/h'),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.white54)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _getWeatherIcon(String code) {
    final intCode = int.tryParse(code) ?? 0;
    IconData icon;
    Color color = Colors.white;

    if (intCode == 0) {
      icon = Icons.wb_sunny_rounded;
      color = Colors.yellowAccent;
    } else if (intCode <= 3) {
      icon = Icons.cloud_outlined;
    } else if (intCode <= 67) {
      icon = Icons.umbrella_rounded;
      color = Colors.lightBlueAccent;
    } else if (intCode <= 99) {
      icon = Icons.thunderstorm_rounded;
      color = Colors.deepPurpleAccent;
    } else {
      icon = Icons.wb_cloudy_rounded;
    }

    return Icon(icon, size: 100, color: color);
  }
}
