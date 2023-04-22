import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

import 'package:google_maps_webservice/places.dart';

class ParkingSearch {
  final String apiKey;

  ParkingSearch(this.apiKey);

  Future<List<PlacesSearchResult>> search(LatLng location) async {
    final places = GoogleMapsPlaces(apiKey: apiKey);
    print('here');
    print(location.latitude);
    print(apiKey);

    final result = await places.searchNearbyWithRadius(
      Location(
        lat: location.latitude,
        lng: location.longitude,
      ),
      500, // radius in meters
      type: 'parking',
    );
    print('here2');
    print(result.results);

    return result.results;
  }
}
