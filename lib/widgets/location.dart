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
  String _locationMessage = 'https://192.168.0.17:9101/#/location';
  String whatsAppLink = 'https://wa.me/?text=';

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
          '$_locationMessage/?latitude=${position.latitude}&longitude=${position.longitude}&volName=${myControllerVolcanoName.text}&volHeight=${myControllerVolcanoHeight.text}';
    });
  }

  void sendWhatsAppLink() async {
    //Esto fue lo ultimo que intente, pero no sirvio :c
    final encodedUrl = Uri.encodeFull(_locationMessage);

    if (await canLaunchUrl(Uri.parse(whatsAppLink))) {
      await launchUrl(Uri.parse('$encodedUrl$encodedUrl'));
    } else {
      print('Failed to open WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: myControllerVolcanoName,
          decoration: const InputDecoration(hintText: 'Nombre del volcán'),
        ),
        TextField(
          controller: myControllerVolcanoHeight,
          decoration: const InputDecoration(hintText: 'Altura del volcán'),
        ),
        ElevatedButton(
          onPressed: _getCurrentLocation,
          child: const Text('Get Location'),
        ),
        ElevatedButton(
          onPressed: sendWhatsAppLink,
          child: const Text('Generar fucking link de WhatsApp'),
        ),
        const SizedBox(height: 20),
        TextButton(
            onPressed: () {
              launchUrl(Uri.parse(_locationMessage),
                  mode: LaunchMode.externalApplication);
            },
            child: Text(_locationMessage)),
      ],
    );
  }
}
