import 'package:dio/dio.dart';
import 'package:flutter_polyline_example/Model/GooglePlaceModel.dart';
import 'package:flutter_polyline_example/Model/PredictionModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GMapService
{
  /// add your apikey here
  static String apiKey = "Your APi Key";

  /// google places autocomplete api
  /// for seaching places
  static GOOGLE_PLACES_AUTO_COMPLETE_API(String searchTerm)
  => "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=$apiKey&input=${searchTerm}";

  /// the place id api
  static GET_GOOGLE_PLACE_BY_ID(String placeId) =>
      "https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$apiKey";

  ///returns list of predictions based on google result
  ///
  Future<PredictionModel> getPredictions(String searchTerm) async
  {
    PredictionModel model;

    var response = await getDio().get(GOOGLE_PLACES_AUTO_COMPLETE_API(searchTerm));
    if(response?.statusCode == 200){
      model = PredictionModel.fromJson(response.data);
    }

    return model;
  }

  /// Get the details of the place by its id
  ///
  Future<GooglePlaceModel> getPlaceById(String id)async
  {
    GooglePlaceModel placeModel;

    var response = await getDio().get(GET_GOOGLE_PLACE_BY_ID(id));
    if(response?.statusCode == 200){
      placeModel = GooglePlaceModel.fromJson(response.data);
    }
    return placeModel;
  }

  Future<List<LatLng>> getRouteBetweenLocations(double originLat, double originLong,
      double destLat, double destLong)async
  {
    List<LatLng> polylinePoints = [];
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=" +
        originLat.toString() +
        "," +
        originLong.toString() +
        "&destination=" +
        destLat.toString() +
        "," +
        destLong.toString() +
        "&mode=driving" +
        "&key=${apiKey}";
    try {
      var response = await getDio().get(url);
      if (response?.statusCode == 200) {
        polylinePoints = decodedPolyForGoogleMap(
            response.data["routes"][0]["overview_polyline"]["points"]);
      }
    }catch (error){
      print(error);
    }
    return polylinePoints;
  }

  ///decode polyline
  ///return [List]
  List<LatLng> decodedPolyForGoogleMap(String encoded)
  {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = new LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }


  Dio getDio()
  {
    return new Dio(
        BaseOptions(
          connectTimeout: 30000,
          receiveTimeout: 30000,
        )
    );
  }

}