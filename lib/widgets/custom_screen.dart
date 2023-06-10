import 'package:flutter/material.dart';
import 'package:lab4flutter/widgets/screen_arguments.dart';

Widget customScreen(Map<String, dynamic> args) {
  var latitude = args['latitude'];
  var longitude = args['longitude'];
  var volName = args['volName'];
  var volHeight = args['volHeight'];

  return Scaffold(
    appBar: AppBar(title: const Text('Second Screen')),
    body: Center(
        child: Text(
            'Latitude: $latitude \nLongitude: $longitude\nName: $volName\nHeight: $volHeight')),
  );
}
