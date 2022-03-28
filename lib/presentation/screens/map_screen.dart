import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import '../../business_logic/cubit/maps/maps_cubit.dart';
import '../../constnats/my_colors.dart';
import '../../data/models/place.dart';
import '../../data/models/place_directions.dart';
import '../../data/models/place_suggestion.dart';
import '../../helpers/db_helper.dart';
import '../../helpers/location_helper.dart';
import '../widgets/distance_and_time.dart';
import '../widgets/my_drawer.dart';
import '../widgets/place_itme.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class MapScreen extends StatefulWidget {
  MapScreen({this.placeId, Key? key}) : super(key: key);
  static List historyList = [];
  late PlaceSuggestion? placeId;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  FloatingSearchBarController controller = FloatingSearchBarController();

  static Position? position;
  Completer<GoogleMapController> mapController = Completer();

  static final CameraPosition _myCurrentLocationCameraPosition = CameraPosition(
      target: LatLng(position!.latitude, position!.longitude),
      bearing: 0.0,
      tilt: 0.0,
      zoom: 17);

  List places = [];

  Set<Marker> markers = {};
  late PlaceSuggestion placeSuggestion;
  late Place selectedPlace;
  late Marker searchedPlaceMarker;
  late Marker currentLocationMarker;

  late CameraPosition goToSearchForPlace;

  // these variables for getDirections
  PlaceDirections? placeDirections;
  var progressIndicator = false;
  late List<LatLng> polylinePoints;
  var issearchedPlaceMarkerClicked = false;
  var isTimeAndDistanceVisible = false;
  late String time;
  late String distance;

  void buildCameraNewPosition() {
    goToSearchForPlace = CameraPosition(
      bearing: 0.0,
      tilt: 0.0,
      zoom: 13,
      target: LatLng(
        selectedPlace.result.geometry.location.lat,
        selectedPlace.result.geometry.location.lng,
      ),
    );
  }

  Future<void> getMyCurrentLocation() async {
    await LocationHelper.getCurrentLocation();

    position = await Geolocator.getLastKnownPosition().whenComplete(() {
      setState(() {});
    });
  }

  Widget buildMap() {
    return GoogleMap(
      initialCameraPosition: _myCurrentLocationCameraPosition,
      mapType: MapType.normal,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      markers: markers,
      onMapCreated: (GoogleMapController controller) {
        mapController.complete(controller);
      },
      polylines: placeDirections != null
          ? {
              Polyline(
                  polylineId: const PolylineId('my_polyline'),
                  color: Colors.black,
                  width: 2,
                  points: polylinePoints),
            }
          : {},
    );
  }

  @override
  void initState() {
    super.initState();
    getMyCurrentLocation();

    if (widget.placeId != null) {
      _selectItemSearch(widget.placeId);
    } else {
      getHistoryData();
    }
  }

  void getHistoryData() async {
    final history = await DbHelper.querySQL();
    for (var element in history) {
      MapScreen.historyList.add(PlaceSuggestion.fromJson(element));
    }
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return FloatingSearchBar(
      controller: controller,
      elevation: 6,
      hintStyle: const TextStyle(fontSize: 20),
      queryStyle: const TextStyle(fontSize: 20),
      hint: 'Find a place..',
      border: const BorderSide(style: BorderStyle.none),
      margins: const EdgeInsets.fromLTRB(20, 70, 20, 0),
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      height: 52,
      iconColor: MyColors.blue,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 600),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        getPlacesSuggestion(query);
      },
      progress: progressIndicator,
      onFocusChanged: (_) {
        setState(() {
          isTimeAndDistanceVisible = false;
        });
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: Icon(
              Icons.place,
              color: Colors.black.withOpacity(0.6),
            ),
            onPressed: () {},
          ),
        )
      ],
      builder: (context, transition) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildSuggestionBloc(),
            buildSelectedPlaceLocationBloc(),
            buildDiretionsBloc(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            position != null
                ? buildMap()
                : const Center(
                    child: CircularProgressIndicator(color: MyColors.blue),
                  ),
            buildFloatingSearchBar(),
            issearchedPlaceMarkerClicked
                ? DistanceAndTime(
                    isTimeAndDistanceVisible: isTimeAndDistanceVisible,
                    placeDirections: placeDirections,
                  )
                : Container(),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 30),
        child: FloatingActionButton(
          onPressed: _goToMyCurrent,
          backgroundColor: MyColors.blue,
          child: const Icon(
            Icons.place,
            color: Colors.white,
          ),
        ),
      ),
      drawer: MyDrawer(),
    );
  }

  Future<void> _goToMyCurrent() async {
    final GoogleMapController controller = await mapController.future;

    controller.animateCamera(
        CameraUpdate.newCameraPosition(_myCurrentLocationCameraPosition));
  }

  Widget buildSuggestionBloc() {
    return BlocBuilder<MapsCubit, MapsState>(builder: (context, state) {
      if (state is PlacesLoadedState) {
        places = (state).place;
        if (places.isNotEmpty) {
          return buildPlacesList();
        } else {
          return Container();
        }
      }
      return Container();
    });
  }

  buildPlacesList() {
    debugPrint("places.length: ${places.length}");

    return ListView.builder(
      itemCount: places.length,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (ctx, index) {
        return InkWell(
          onTap: () async {
            _selectItemSearch(places[index]);
            MapScreen.historyList.add(places[index]);
            await DbHelper.insert(places[index]);
          },
          child: PlaceItme(
            suggestion: places[index],
          ),
        );
      },
    );
  }

  void _selectItemSearch(PlaceSuggestion? places) {
    controller.close();
    placeSuggestion = places!;
    getSelectedPlaceLocation();
    removeAllMarkersAndUpdateUI();
    debugPrint("places[index]: $places");

    try {
      polylinePoints.clear();
    } catch (error) {
      debugPrint("polylinePoints: $error");
    }
  }

  void getPlacesSuggestion(String query) {
    final sessionToken = const Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceSuggestions(query, sessionToken);
  }

  void getSelectedPlaceLocation() {
    final sessionToken = const Uuid().v4();

    BlocProvider.of<MapsCubit>(context)
        .emitPlaceLocation(placeSuggestion.placeId, sessionToken);
  }

  buildSelectedPlaceLocationBloc() {
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is PlacesLocationLoadedState) {
          selectedPlace = (state).place;

          goToMySearchedForLocation();
          getDirections();
        }
      },
      child: Container(),
    );
  }

  Future<void> goToMySearchedForLocation() async {
    buildCameraNewPosition();
    final GoogleMapController _controller = await mapController.future;
    _controller
        .animateCamera(CameraUpdate.newCameraPosition(goToSearchForPlace));

    buildSearchedPlacMarker();
  }

  void buildSearchedPlacMarker() {
    searchedPlaceMarker = Marker(
      position: goToSearchForPlace.target,
      markerId: const MarkerId("2"),
      onTap: () {
        buildCurrentLocationMarker();
        // Show time and distance
        setState(() {
          issearchedPlaceMarkerClicked = true;
          isTimeAndDistanceVisible = true;
        });
      },
      infoWindow: InfoWindow(title: placeSuggestion.description),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    addMarkerToMarkersAndUpdateUI(searchedPlaceMarker);
  }

  void buildCurrentLocationMarker() {
    currentLocationMarker = Marker(
      position: LatLng(position!.latitude, position!.longitude),
      markerId: const MarkerId("4"),
      onTap: () {},
      infoWindow: const InfoWindow(title: "Your current Location"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    addMarkerToMarkersAndUpdateUI(currentLocationMarker);
  }

  void addMarkerToMarkersAndUpdateUI(Marker marker) {
    setState(() {
      markers.add(marker);
    });
  }

  buildDiretionsBloc() {
    return BlocListener<MapsCubit, MapsState>(
      listener: (context, state) {
        if (state is DirectionsLoadedState) {
          placeDirections = (state).placeDirections;
          getPolyLinePoints();
        }
      },
      child: Container(),
    );
  }

  void getPolyLinePoints() {
    polylinePoints = placeDirections!.polylinePoints
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
  }

  void getDirections() {
    BlocProvider.of<MapsCubit>(context).emitPlaceDirections(
        LatLng(position!.latitude, position!.longitude),
        LatLng(selectedPlace.result.geometry.location.lat,
            selectedPlace.result.geometry.location.lng));
  }

  void removeAllMarkersAndUpdateUI() {
    setState(() {
      markers.clear();
    });
  }
}
