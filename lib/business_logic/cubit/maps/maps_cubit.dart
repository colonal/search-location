import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import '../../../data/models/place.dart';
import '../../../data/models/place_directions.dart';

import '../../../data/repository/maps_repo.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {
  final MapsRepository mapsRepository;

  MapsCubit(this.mapsRepository) : super(MapInitial());

  static MapsCubit get(context) => BlocProvider.of(context);

  void emitPlaceSuggestions(String place, String sessionToken) {
    mapsRepository.frtchSuggestion(place, sessionToken).then((suggestions) {
      emit(PlacesLoadedState(suggestions));
    });
  }

  void emitPlaceLocation(String placeId, String sessionToken) {
    mapsRepository.getPlaceLocation(placeId, sessionToken).then((place) {
      emit(PlacesLocationLoadedState(place));
    });
  }

  void emitPlaceDirections(LatLng origin, LatLng destination) {
    mapsRepository.getDirections(origin, destination).then((direction) {
      emit(DirectionsLoadedState(direction));
    });
  }
}
