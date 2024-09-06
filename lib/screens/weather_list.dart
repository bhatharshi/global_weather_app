import 'package:flutter/material.dart';
import '../components/weather_card.dart';
import '../services/weather_api_service.dart';

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
  String? _validationError;
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
    if (query.trim().isEmpty) {
      setState(() {
        _displayedWeatherData = _weatherData;
        _validationError = 'Enter a city name'; // Set validation error
        _error = null; // Clear any existing errors
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _validationError = null; // Clear validation error
    });

    try {
      final data = await _weatherService.fetchWeather(query);
      if (data != null) {
        setState(() {
          _displayedWeatherData = [data];
          _error = null;
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
            SearchBar(
              hintText: 'Search for any city worldwide',
              controller: _searchController,
              onSubmitted: _searchCity,
            ),
            if (_validationError != null) // Display validation error
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _validationError!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            const SizedBox(height: 20),
            _buildContent(),
          ],
        ),
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
            return WeatherCard(weather: weather);
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
}
