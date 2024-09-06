// component/weather_card.dart
import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic> weather;

  const WeatherCard({Key? key, required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
