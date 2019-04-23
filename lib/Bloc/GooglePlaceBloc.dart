import 'dart:collection';

import 'package:flutter_polyline_example/Model/PredictionModel.dart';
import 'package:flutter_polyline_example/Service/GMapService.dart';
import 'package:rxdart/rxdart.dart';

class GooglePlaceBloc
{
  GMapService gMapService = GMapService();
  PublishSubject<BlocModel> predictionController = PublishSubject<BlocModel>();
  Sink<BlocModel> get inPredictionList => predictionController.sink;
  Stream<BlocModel> get outPredictionList => predictionController.stream;

  List<Predictions> currentPredictionList = [];


  search(String searchTerm){
    inPredictionList.add(BlocModel(model: currentPredictionList, processing: true));
    gMapService.getPredictions(searchTerm).then((PredictionModel model){
      if(model != null){
        currentPredictionList = model.predictions;
        inPredictionList.add(BlocModel(model: currentPredictionList, processing: false));
        //inPredictionList.add(UnmodifiableListView(model.predictions));
      }
    });
  }

  @override
  void dispose() {
    predictionController.close();
  }

}

class BlocModel<T>{
  List<T> model;
  bool processing;

  BlocModel({this.model, this.processing});

}