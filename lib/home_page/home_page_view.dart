import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../services/api/base_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isloaded = false;
  num? temp = 0;
  num? pressure = 0;
  num? humidity;
  num? cover;
  String? cityName = '';
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Visibility(
          visible: isloaded,
          replacement: const Center(child: CircularProgressIndicator()),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.08,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
                child: Center(
                  child: TextFormField(
                    onFieldSubmitted: (String city) {
                      cityName = city;
                      getCityWether(city);
                      isloaded = false;
                      controller.clear();
                    },
                    controller: controller,
                    cursorColor: Colors.white,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                        hintStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.bold),
                        hintText: "Search City",
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: InputBorder.none),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.pin_drop,
                      color: Colors.red,
                      size: 40,
                    ),
                    Text(
                      cityName!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              rowtetx(context),
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.12,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.shade900,
                          offset: const Offset(1, 2),
                          blurRadius: 3,
                          spreadRadius: 1)
                    ]),
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.09,
                      child: const Icon(Icons.fire_extinguisher),
                    ),
                    Text("Pressure : ${pressure!.toStringAsFixed(2)}")
                  ],
                ),
              )
            ]),
          ),
        ),
      )),
    );
  }

  Container rowtetx(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.12,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade900,
                offset: const Offset(1, 2),
                blurRadius: 3,
                spreadRadius: 1)
          ]),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.09,
            child: const Icon(Icons.fire_extinguisher),
          ),
          Text("Temperature : ${temp!.toStringAsFixed(2)}")
        ],
      ),
    );
  }

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
      setState(() {
        isloaded = true;
      });
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
      setState(() {
        isloaded = true;
      });
    }
  }

  upDateUI(var data) {
    setState(() {
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
    });
  }

  @override
  // ignore: must_call_super
  void dispose() {
    controller.dispose();
  }
}
