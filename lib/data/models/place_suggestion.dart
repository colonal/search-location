class PlaceSuggestion {
  int? id;
  late String placeId;
  late String description;

  PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    placeId = json["place_id"];
    description = json["description"];
    id = json["id"];
  }
  Map<String, dynamic> toJson() {
    return {"place_id": placeId, "description": description, "id": id};
  }
}
