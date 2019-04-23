import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'GooglePlacesSearchScreen.dart';
import 'Model/GooglePlaceModel.dart';
import 'Model/PredictionModel.dart';
import 'Service/GMapService.dart';

class MapScreen extends StatefulWidget
{
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
{
  GoogleMapController mapController;
  double _currentLatitude = 6.5212402, _currentLongitude = 3.3679965;
  Map<MarkerId, Marker> markers = {};
 TextEditingController originController = TextEditingController();
 TextEditingController destController = TextEditingController();
 Predictions prediction;
 String address = "Where to?";
 bool showProgress = false;
 Map<PolylineId, Polyline> polylines = {};
 List<LatLng> polylinePoints = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentLatitude, _currentLongitude),
                zoom: 15
              ),
              myLocationEnabled: true,
              tiltGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              onMapCreated: _onMapCreated,
              markers: Set<Marker>.of(markers.values),
              polylines: Set<Polyline>.of(polylines.values),
            ),

            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => GooglePlacesSearchRequest())).then((prediction){
                      if(prediction != null) {
                        this.prediction = prediction;
                        processPrediction();
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.location_on, color: Colors.green,),

                        SizedBox(width: 5,),

                        Expanded(
                          child: Text(address, style: TextStyle(
                            fontSize: 18
                          ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        showProgress ?
                        Container(
                          height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2,)) : SizedBox()
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      )
    );
  }

  ///processes the selected prediction
  ///
  /// connect to ggogle api to get the place details
  ///
  /// then connect to get the polyline points
  processPrediction() async
  {
    GMapService mapService = GMapService();
    setState(() {
      showProgress = true;
      address = this.prediction.description;
    });
    GooglePlaceModel model = await mapService.getPlaceById(prediction.placeId);
    if(model != null) {
      double destLat = model.result.geometry.location.lat;
      double destLng = model.result.geometry.location.lng;
      _addMarker(LatLng(destLat, destLng), "destination", BitmapDescriptor.defaultMarkerWithHue(90));
      polylinePoints = await mapService.getRouteBetweenLocations(_currentLatitude, _currentLongitude, destLat, destLng);
      _addPolyLine();
      showProgress = false;
      mapController.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(_currentLatitude, _currentLongitude),
            northeast: LatLng(destLat, destLng)
          ), 80));
      setState(() {
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) async
  {
    mapController = controller;
    await _getCurrentPosition();
    setState(() {
      var location = LatLng(_currentLatitude, _currentLongitude);
      mapController.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
              target: location,
              zoom: 16
          )));
      _addMarker(location, "origin", BitmapDescriptor.defaultMarker);
    });
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor)
  {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine()
  {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red, points: polylinePoints
    );
    polylines[id] = polyline;
  }

  _getCurrentPosition() async
  {
    var position = await Geolocator().getCurrentPosition();
    if(position != null){
      _currentLatitude = position.latitude;
      _currentLongitude = position.longitude;
      List<Placemark> placemarkList = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarkList.isNotEmpty) {
        Placemark placemark = placemarkList[0];
        originController.text = placemark.name;
      }
    }
  }
}