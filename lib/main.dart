import 'package:flutter/material.dart';
import 'dart:async';
import 'package:light/light.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _luxString = 'Unknown';
  int number = 0;
  Light? _light;
  StreamSubscription? _subscription;

  String latidudeMenssage = "Unknown";
  String longitudeMenssage = "Unknown";
  double latidudeTrue = 0;
  double longitudeTrue = 0;

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return yourLocation();
  }

  void yourLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latidudeMenssage = position.latitude.toString();
      longitudeMenssage = position.longitude.toString();

      latidudeTrue = double.parse(latidudeMenssage);
      longitudeTrue = double.parse(longitudeMenssage);
    });
  }
//latitude: -3.768293, longitude: -38.478974

  Container check() {
    if ((-3.771153 <= latidudeTrue &&
            latidudeTrue <= -3.766142) &&
        (-38.481796 <= longitudeTrue &&
            longitudeTrue <= -38.472423)) {
      if (number >= 4000) {
        return Container(
          height: 300,
          width: 300,
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Claro",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        );
      } else {
        return Container(
          height: 300,
          width: 300,
          color: Colors.blue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Escuro",
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        );
      }
    } else {
      return Container(
        height: 300,
        width: 300,
        color: const Color.fromARGB(255, 77, 77, 77),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Distânte",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            )
          ],
        ),
      );
    }
  }

  void onData(int luxValue) async {
    //PRINTS TERMINAL--------------------------------------------------
    //print("Lux value: $luxValue");
    //print("$latidudeMenssage - $longitudeMenssage");
    setState(() {
      _luxString = "$luxValue";
      number = int.parse(_luxString);
    });
  }

  void stopListening() {
    _subscription?.cancel();
  }

  void startListening() {
    _light = Light();
    try {
      _subscription = _light?.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      print(exception);
    }
  }

  @override
  void initState() {
    super.initState();
    startListening();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Light Example App'),
        ),
        body: new Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new Text('Light value: $_luxString'),
              new Text(
                  'Latitude: $latidudeMenssage - Longitude: $longitudeMenssage\n'),
              check(),
              TextButton(
                onPressed: () {
                  yourLocation();
                },
                child: Text("Atualizar localização"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
