part of kobo_mobile_core;

class PredictionModel {
  List<Predictions> predictions;
  String status;

  PredictionModel({this.predictions, this.status});

  PredictionModel.fromJson(Map<String, dynamic> json) {
    if (json['predictions'] != null) {
      predictions = new List<Predictions>();
      json['predictions'].forEach((v) {
        predictions.add(new Predictions.fromJson(v));
      });
    }
    status = json['status'];
  }
}

class Predictions {
  String description;
  String id;
  List<MatchedSubstrings> matchedSubstrings;
  String placeId;
  String reference;
  StructuredFormatting structuredFormatting;
  List<Terms> terms;
  List<String> types;

  Predictions(
      {this.description,
        this.id,
        this.matchedSubstrings,
        this.placeId,
        this.reference,
        this.structuredFormatting,
        this.terms,
        this.types});

  Predictions.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    id = json['id'];
    if (json['matched_substrings'] != null) {
      matchedSubstrings = new List<MatchedSubstrings>();
      json['matched_substrings'].forEach((v) {
        matchedSubstrings.add(new MatchedSubstrings.fromJson(v));
      });
    }
    placeId = json['place_id'];
    reference = json['reference'];
    structuredFormatting = json['structured_formatting'] != null
        ? new StructuredFormatting.fromJson(json['structured_formatting'])
        : null;
    if (json['terms'] != null) {
      terms = new List<Terms>();
      json['terms'].forEach((v) {
        terms.add(new Terms.fromJson(v));
      });
    }
    types = json['types'].cast<String>();
  }
}

class MatchedSubstrings {
  int length;
  int offset;

  MatchedSubstrings({this.length, this.offset});

  MatchedSubstrings.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    offset = json['offset'];
  }
}

class StructuredFormatting {
  String mainText;
  List<MainTextMatchedSubstrings> mainTextMatchedSubstrings;
  String secondaryText;

  StructuredFormatting(
      {this.mainText, this.mainTextMatchedSubstrings, this.secondaryText});

  StructuredFormatting.fromJson(Map<String, dynamic> json) {
    mainText = json['main_text'];
    if (json['main_text_matched_substrings'] != null) {
      mainTextMatchedSubstrings = new List<MainTextMatchedSubstrings>();
      json['main_text_matched_substrings'].forEach((v) {
        mainTextMatchedSubstrings
            .add(new MainTextMatchedSubstrings.fromJson(v));
      });
    }
    secondaryText = json['secondary_text'];
  }
}

class MainTextMatchedSubstrings {
  int length;
  int offset;

  MainTextMatchedSubstrings({this.length, this.offset});

  MainTextMatchedSubstrings.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    offset = json['offset'];
  }
}

class Terms {
  int offset;
  String value;

  Terms({this.offset, this.value});

  Terms.fromJson(Map<String, dynamic> json) {
    offset = json['offset'];
    value = json['value'];
  }
}

