import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:parking/models/place.dart';

final apiKey = 'AIzaSyAoidbQgL_RDddR-h27Ypjn0kgYJEP6wWg';

class PlacesService {
  Future<List<Place>> getPlaces(double latitude, double longitude) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$latitude,$longitude'
      '&type=parking'
      '&rankby=distance'
      '&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List<dynamic>;
      final places = results.map((place) => Place.fromJson(place)).toList();
      return places;
    } else {
      throw Exception('Failed to load places');
    }
  }
}
