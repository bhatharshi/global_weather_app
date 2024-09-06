import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = 'a06c937ef30ea25329ae4824385ae10d';

  Future<Map<String, dynamic>?> fetchWeather(String city) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<Map<String, dynamic>>> fetchIndianCitiesWeather() async {
    final List<String> indianCities = [
      'Mumbai',
      'Delhi',
      'Bangalore',
      'Hyderabad',
      'Chennai',
      'Kolkata',
      'Pune',
      'Ahmedabad',
      'Jaipur',
      'Surat',
      'Lucknow',
      'Kanpur',
      'Nagpur',
      'Indore',
      'Thane',
      'Bhopal',
      'Visakhapatnam',
      'Patna',
      'Vadodara',
      'Ghaziabad'
    ];

    List<Map<String, dynamic>> weatherDataList = [];

    for (String city in indianCities) {
      try {
        final data = await fetchWeather('$city,IN');
        if (data != null) {
          weatherDataList.add(data);
        }
      } catch (e) {
        debugPrint('Error fetching data for $city: $e');
      }
    }

    return weatherDataList;
  }
}
