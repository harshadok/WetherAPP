import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../services/api/base_api.dart';

class HomePageProvider extends ChangeNotifier {
  bool isloaded = false;
  num? temp = 0;
  num? pressure = 0;
  num? humidity;
  num? cover;
  String? cityName = '';
  final TextEditingController controller = TextEditingController();
  getCurrentLocation() async {
    var p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        forceAndroidLocationManager: true);

//    print(p);
    getCurentcity(p);
    // print("data unavilable");
  }

  getCityWether(String cityname) async {
    var clint = http.Client();
    var uri = '${baseUrl}q=$cityname&appid=$apikey';

    var url = Uri.parse(uri);

    var res = await clint.get(url);

    if (res.statusCode == 200) {
      var data = res.body;
      var newData = json.decode(data);
      //  print(data);
      upDateUI(newData);
      isloaded = true;
    }
  }

  getCurentcity(Position position) async {
    var clint = http.Client();
    var uri =
        '${baseUrl}lat=${position.latitude}&lon=${position.longitude}&appid=$apikey';

    var url = Uri.parse(uri);

    var res = await clint.get(url);

    if (res.statusCode == 200) {
      var data = res.body;
      var newData = json.decode(data);
      //print(data);
      upDateUI(newData);
      isloaded = true;
    }
  }

  upDateUI(var data) {
    if (data == null) {
      temp = 0;
      pressure = 0;
      humidity = 0;
      cover = 0;
      cityName = "Not Available";
    } else {
      temp = data["main"]["temp"] - 273;
      pressure = data["main"]["pressure"];
      humidity = data["main"]["humidity"];
      cover = data["clouds"]["all"];
      cityName = data['name'];
    }
  }
}
