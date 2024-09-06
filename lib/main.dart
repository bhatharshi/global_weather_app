import 'package:flutter/material.dart';

import 'weather_api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Weather App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _searchController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  List<Map<String, dynamic>> _weatherData = [];
  List<Map<String, dynamic>> _displayedWeatherData = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchIndianCitiesWeather();
  }

  Future<void> _fetchIndianCitiesWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _weatherService.fetchIndianCitiesWeather();
      setState(() {
        _weatherData = data;
        _displayedWeatherData = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchCity(String query) async {
    if (query.isEmpty) {
      setState(() {
        _displayedWeatherData = _weatherData;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _weatherService.fetchWeather(query);
      if (data != null) {
        setState(() {
          _displayedWeatherData = [data];
        });
      } else {
        setState(() {
          _error = 'City not found';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Weather App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for any city worldwide',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onSubmitted: (value) => _searchCity(value),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_error != null) {
      return Expanded(
        child: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    } else if (_displayedWeatherData.isNotEmpty) {
      return Expanded(
        child: ListView.builder(
          itemCount: _displayedWeatherData.length,
          itemBuilder: (context, index) {
            final weather = _displayedWeatherData[index];
            return _buildWeatherCard(weather);
          },
        ),
      );
    } else {
      return const Expanded(
        child: Center(
          child: Text(
            'No weather data available.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
  }

  Widget _buildWeatherCard(Map<String, dynamic> weather) {
    final cityName = weather['name'];
    final country = weather['sys']['country'];
    final temp = weather['main']['temp'];
    final description = weather['weather'][0]['description'];
    final icon = weather['weather'][0]['icon'];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          '$cityName, $country',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(
          '$temp°C - $description',
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Image.network(
          'http://openweathermap.org/img/wn/$icon@2x.png',
          width: 60,
        ),
      ),
    );
  }
}
