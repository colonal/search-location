// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mfs/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:mfs/constnats/my_colors.dart';
import 'package:mfs/constnats/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({Key? key}) : super(key: key);

  Widget buildDrawerHeader(context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(70, 10, 70, 10),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.blue[100],
          ),
          child: Image.asset(
            "assets/images/mohammad.png",
            fit: BoxFit.cover,
          ),
        ),
        const Text(
          "Mohammad",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        BlocProvider<PhoneAuthCubit>(
          create: (context) => phoneAuthCubit,
          child: Text(
            phoneAuthCubit.getLoggedInUser().phoneNumber ?? "",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget buildDrawerListItem(
      {required IconData leadingIcon,
      required String title,
      Widget? trailing,
      Function()? onTap,
      Color? color}) {
    return ListTile(
      leading: Icon(
        leadingIcon,
        color: color ?? MyColors.blue,
      ),
      title: Text(title),
      trailing: trailing ??
          const Icon(
            Icons.arrow_right,
            color: MyColors.blue,
          ),
      onTap: onTap,
    );
  }

  Widget buildDrawerListItemsDivider() {
    return const Divider(
      height: 0,
      thickness: 1,
      indent: 18,
      endIndent: 24,
    );
  }

  void _launchURL(String url) async {
    await canLaunch(url) ? await launch(url) : throw "Could not launch $url";
  }

  Widget buildIcon(IconData icon, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Icon(
        icon,
        color: MyColors.blue,
        size: 35,
      ),
    );
  }

  Widget buildSocialMediaIcons() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16),
      child: Row(
        children: [
          buildIcon(FontAwesomeIcons.facebook, "https://www.facebook.com"),
          const SizedBox(width: 16),
          buildIcon(FontAwesomeIcons.github, "https://www.github.com"),
          const SizedBox(width: 16),
          buildIcon(FontAwesomeIcons.instagram, "https://www.instagram.com"),
        ],
      ),
    );
  }

  Widget buildLogoutBlocProvider(BuildContext context) {
    return BlocProvider<PhoneAuthCubit>(
      create: (_) => phoneAuthCubit,
      child: buildDrawerListItem(
          leadingIcon: Icons.logout,
          title: "Logout",
          color: Colors.red,
          onTap: () async {
            phoneAuthCubit.logOut();
            Navigator.of(context).pushReplacementNamed(loginScreen);
          }),
    );
  }

  PhoneAuthCubit phoneAuthCubit = PhoneAuthCubit();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 260,
            child: DrawerHeader(
              child: buildDrawerHeader(context),
              decoration: BoxDecoration(color: Colors.blue[100]),
            ),
          ),
          buildDrawerListItem(leadingIcon: Icons.person, title: "My Profile"),
          buildDrawerListItemsDivider(),
          buildDrawerListItem(
              leadingIcon: Icons.history,
              title: "Places History",
              onTap: () {
                Navigator.of(context).pushNamed(historyScreen);
              }),
          buildDrawerListItemsDivider(),
          buildDrawerListItem(leadingIcon: Icons.settings, title: "Settings"),
          buildDrawerListItemsDivider(),
          buildDrawerListItem(leadingIcon: Icons.help, title: "Help"),
          buildDrawerListItemsDivider(),
          buildLogoutBlocProvider(context),
          const SizedBox(height: 180),
          ListTile(
            leading: Text(
              "Follow us",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          buildSocialMediaIcons()
        ],
      ),
    );
  }
}
