import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationWidget extends StatefulWidget {
  @override
  _LocationWidgetState createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  final myControllerVolcanoName = TextEditingController();
  final myControllerVolcanoHeight = TextEditingController();

  String _uriNewView = 'http:/localhost:51597/#/location';
  String _locationMessage = '';
  String whatsAppLink = 'http://wa.me/?text=';

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _getCurrentLocation() async {
    final position = await _determinePosition();

    setState(() {
      _locationMessage =
          '$_uriNewView/?latitude=${position.latitude}&longitude=${position.longitude}&volName=${myControllerVolcanoName.text}&volHeight=${myControllerVolcanoHeight.text}';
    });
  }

  void sendWhatsAppLink() async {
    final encodedUrl = Uri.encodeComponent(_locationMessage);
    final encodedWhatsAppLink = '$whatsAppLink$encodedUrl';

    if (await canLaunchUrl(Uri.parse(encodedWhatsAppLink))) {
      await launchUrl(Uri.parse(encodedWhatsAppLink));
    } else {
      print('Failed to open WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'REGISTER A NEW VOLCANO',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          child: TextField(
            controller: myControllerVolcanoName,
            decoration: const InputDecoration(
              hintText: 'Volcano Name',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          child: TextField(
            controller: myControllerVolcanoHeight,
            decoration: const InputDecoration(
              hintText: 'Volcano Height',
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _getCurrentLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue, // Cambio de color aquí
          ),
          child: const Text('Generate Link'),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: sendWhatsAppLink,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Cambio de color aquí
          ),
          child: const Text('Share by WhatsApp'),
        ),
        const SizedBox(height: 20),
        const Text('👇🏼 Click the link generated to open a new view 👇🏼'),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            launchUrl(
              Uri.parse(_locationMessage),
              mode: LaunchMode.externalApplication,
            );
          },
          child: Text(_locationMessage),
        ),
      ],
    );
  }
}
