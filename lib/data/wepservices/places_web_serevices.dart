// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mfs/constnats/strings.dart';

class PlacesWebServices {
  late Dio dio;

  PlacesWebServices() {
    BaseOptions options = BaseOptions(
      connectTimeout: 20 * 1000,
      receiveTimeout: 20 * 1000,
      receiveDataWhenStatusError: true,
    );

    dio = Dio(options);
  }

  Future<List<dynamic>> frtchSuggestion(
      String place, String sessionToken) async {
    try {
      Response response = await dio.get(suggestionsBaseURL, queryParameters: {
        "input": place,
        "types": "address",
        "components": "country:jo",
        "key": "XXXXXXXXXXXXXXXXXXXXX",
        "sessiontoken": sessionToken,
      });
      print("Data: ${response.data["predictions"]}");
      print("statusCode: ${response.statusCode}");

      return response.data["predictions"];
    } catch (e) {
      print(e.toString());
    }
    return [];
  }

  Future<dynamic> getPlaceLocation(String placeId, String sessionToken) async {
    try {
      Response response = await dio.get(placeLocationBaseURL, queryParameters: {
        "place_id": placeId,
        "fields": "geometry",
        "key": "XXXXXXXXXXXXXXXXXXXXX",
        "sessiontoken": sessionToken,
      });

      return response.data;
    } catch (e) {
      print(e.toString());
    }
    return Future.error(
        "Place location error: ", StackTrace.fromString(("this is its trace")));
  }

  Future<dynamic> getDirections(LatLng origin, LatLng destination) async {
    try {
      Response response = await dio.get(directionsBaseURL, queryParameters: {
        "origin": "${origin.latitude},${origin.longitude}",
        "destination": "${destination.latitude},${destination.longitude}",
        "key": "XXXXXXXXXXXXXXXXXXXXX",
      });

      return response.data;
    } catch (e) {
      print(e.toString());
    }
    return Future.error(
        "Place location error: ", StackTrace.fromString(("this is its trace")));
  }
}
