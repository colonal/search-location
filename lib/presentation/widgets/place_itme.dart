import 'package:flutter/material.dart';
import '../../constnats/my_colors.dart';
import '../../data/models/place_suggestion.dart';

class PlaceItme extends StatelessWidget {
  final PlaceSuggestion suggestion;

  const PlaceItme({required this.suggestion, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> splitText = suggestion.description.split(",");
    String title = splitText[0];
    splitText.removeAt(0);
    String subTitle = splitText.join(",");

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: MyColors.lightBlue),
              child: const Icon(
                Icons.place,
                color: MyColors.blue,
              ),
            ),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$title\n",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: subTitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
