part of 'maps_cubit.dart';

@immutable
abstract class MapsState {}

class MapInitial extends MapsState {}

class PlacesLoadedState extends MapsState {
  final List<dynamic> place;

  PlacesLoadedState(this.place);
}

class PlacesLocationLoadedState extends MapsState {
  final Place place;

  PlacesLocationLoadedState(this.place);
}

class DirectionsLoadedState extends MapsState {
  final PlaceDirections placeDirections;

  DirectionsLoadedState(this.placeDirections);
}
