import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void animateCameraToBounds(
    List<List<dynamic>> results, GoogleMapController controller) {
  WidgetsBinding.instance?.addPostFrameCallback((_) {
    final mostNortheastSpace = results.reduce((curr, next) =>
        curr[1] > next[1] || (curr[1] == next[1] && curr[2] > next[2])
            ? curr
            : next);

    final mostSouthwestSpace = results.reduce((curr, next) =>
        curr[1] < next[1] || (curr[1] == next[1] && curr[2] < next[2])
            ? curr
            : next);

    controller?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(mostNortheastSpace[1], mostNortheastSpace[2]),
          southwest: LatLng(mostSouthwestSpace[1], mostSouthwestSpace[2]),
        ),
        100.0,
      ),
    );
  });
}
