import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/cubit/maps/maps_cubit.dart';
import '../../constnats/my_colors.dart';
import '../../data/models/place_suggestion.dart';
import '../../data/repository/maps_repo.dart';
import '../../data/wepservices/places_web_serevices.dart';
import '../../helpers/db_helper.dart';
import 'map_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Places History",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: () async {
                await DbHelper.deleteAll();
                MapScreen.historyList.clear();
              },
              icon: Icon(
                Icons.delete,
                color: Colors.red[200],
              )),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<MapsCubit, MapsState>(
          listener: (context, state) {},
          builder: (context, state) {
            List historyList = MapScreen.historyList;

            return ListView.builder(
                itemCount: historyList.length,
                itemBuilder: (context, index) =>
                    itemHistoryBuilder(context, index, historyList[index]));
          },
        ),
      ),
    );
  }

  itemHistoryBuilder(context, int index, PlaceSuggestion suggestion) {
    List<String> splitText = suggestion.description.split(",");
    String title = splitText[0];
    splitText.removeAt(0);
    String subTitle = splitText.join(",");
    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => BlocProvider<MapsCubit>(
                  create: (_) => MapsCubit(MapsRepository(PlacesWebServices())),
                  child: MapScreen(
                    placeId: suggestion,
                  ),
                )));
      },
      child: Column(
        children: [
          Dismissible(
            key: Key(index.toString()),
            child: ListTile(
              leading: const CircleAvatar(
                  child: Icon(
                    Icons.place,
                    color: Colors.blue,
                  ),
                  backgroundColor: MyColors.lightBlue),
              title: Text(
                title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                subTitle,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            background: Container(
              color: Colors.redAccent,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            secondaryBackground: Container(
              color: Colors.redAccent,
              child: const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            onDismissed: (DismissDirection direction) async {
              await DbHelper.delete(suggestion.id);
              MapScreen.historyList.removeAt(index);
            },
          ),
          const Divider(
            height: 0,
            thickness: 1,
            indent: 18,
            endIndent: 24,
          ),
        ],
      ),
    );
  }
}
