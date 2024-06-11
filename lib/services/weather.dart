import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:untitled/services/location.dart';
import 'package:untitled/services/networking.dart';

const apiKey = '0319fde830dc85a74d1f2f8685bb0a69'; // Updated API key
const openWeatherMapURL = 'https://api.openweathermap.org/data/2.5/weather';

class WeatherModel {
  Future<dynamic> getCityWeather(String cityName) async {
    NetworkHelper networkHelper = NetworkHelper(
        '$openWeatherMapURL?q=$cityName&appid=$apiKey&units=metric');

    return _getData(networkHelper);
  }

  Future<dynamic> getLocationWeather(BuildContext context) async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      _showPermissionDeniedDialog(context);
      return null;
    } else if (permission == LocationPermission.deniedForever) {
      _showPermissionDeniedForeverDialog(context);
      return null;
    }

    Location location = Location();
    await location.getCurrentLocation();

    NetworkHelper networkHelper = NetworkHelper(
        '$openWeatherMapURL?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey&units=metric');

    return _getData(networkHelper);
  }

  Future<dynamic> _getData(NetworkHelper networkHelper) async {
    var weatherData = await networkHelper.getData();

    if (weatherData == null) {
      return 'Unable to fetch weather data. Please check your internet connection.';
    }

    if (weatherData['cod'] == null || weatherData['cod'] == 401) {
      return 'Unauthorized request. Please check your API key.';
    }

    return weatherData;
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission'),
          content: Text('Location permission is needed to provide weather updates based on your current location.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedForeverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission'),
          content: Text('Location permission has been permanently denied. Please enable it from settings.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  String getMessage(int temp) {
    if (temp > 25) {
      return 'It\'s 🍦 time';
    } else if (temp > 20) {
      return 'Time for shorts and 👕';
    } else if (temp < 10) {
      return 'You\'ll need 🧣 and 🧤';
    } else {
      return 'Bring a 🧥 just in case';
    }
  }
}
