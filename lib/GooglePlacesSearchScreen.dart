import 'dart:async';

import 'package:flutter/material.dart';

import 'Bloc/GooglePlaceBloc.dart';
import 'Model/PredictionModel.dart';


class GooglePlacesSearchRequest extends StatefulWidget
{
  _GooglePlacesSearchRequestState createState() => _GooglePlacesSearchRequestState();
}

class _GooglePlacesSearchRequestState extends State<GooglePlacesSearchRequest>
{
  var _searchController = TextEditingController();
  List<Predictions> predictionList = [];
  GooglePlaceBloc placeBloc = GooglePlaceBloc();
  bool processing = false;

  initState() {
    super.initState();
    _searchController.addListener(onSearchTextChanged);
  }

  onSearchTextChanged()async
  {
    await Future.delayed(Duration(seconds: 1));
    placeBloc.search(_searchController.text);
    if(mounted){
      setState(() {
        processing = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Container(
              height: 60,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                color: Colors.white,
                elevation: 3,
                child: Row(
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: (){
                          Navigator.of(context).pop();
                        }
                    ),

                    SizedBox(width: 10,),

                    Expanded(
                      child: TextFormField(
                        controller: _searchController,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Search here",
                          border: InputBorder.none
                        ),
                        autofocus: true,
                      )
                    ),

                  ],
                ),
              ),
            ),

            Expanded(
              child: StreamBuilder(
                stream: placeBloc.outPredictionList,
                builder: (context, AsyncSnapshot<BlocModel> snapShot){
                  switch(snapShot.connectionState){
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Container();
                    case ConnectionState.active:
                    case ConnectionState.done:
                      predictionList = snapShot.data.model;
                      processing = snapShot.data.processing;
                      return Column(
                        children: <Widget>[
                          processing ? LinearProgressIndicator() : SizedBox(),
                          Expanded(
                            child: predictionList.isEmpty ? SizedBox() :
                            ListView.builder(
                                itemCount: predictionList.length,
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                itemBuilder: (contextX, index){
                                  Predictions prediction = predictionList[index];
                                  return InkWell(
                                    onTap: (){
                                      Navigator.of(context).pop(prediction);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Icon(Icons.location_on),
                                              SizedBox(width: 20,),
                                              Expanded(child:
                                              Text("${prediction.description}")
                                              ),

                                            ],
                                          ),

                                          Divider()
                                        ],
                                      ),
                                    ),
                                  );
                                }
                            ),
                          )
                        ],
                      );
                  }
                }
              )
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController?.dispose();
    super.dispose();
  }

}