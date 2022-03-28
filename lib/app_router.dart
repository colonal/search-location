// ignore_for_file: body_might_complete_normally_nullable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'business_logic/cubit/maps/maps_cubit.dart';
import 'business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'constnats/strings.dart';
import 'data/repository/maps_repo.dart';
import 'data/wepservices/places_web_serevices.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/map_screen.dart';
import 'presentation/screens/otp_screen.dart';

class AppRouter {
  PhoneAuthCubit? phoneAuthCubit;

  AppRouter() {
    phoneAuthCubit = PhoneAuthCubit();
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<PhoneAuthCubit>.value(
                value: phoneAuthCubit!, child: LoginScreen()));

      case otpScreen:
        final phoneNumber = settings.arguments;
        return MaterialPageRoute(
            builder: (_) => BlocProvider<PhoneAuthCubit>.value(
                  value: phoneAuthCubit!,
                  child: OtpScreen(phoneNumber: phoneNumber as String),
                ));
      case mapScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<MapsCubit>(
                  create: (_) => MapsCubit(MapsRepository(PlacesWebServices())),
                  child: MapScreen(),
                ));
      case historyScreen:
        return MaterialPageRoute(
            builder: (_) => BlocProvider<MapsCubit>(
                  create: (_) => MapsCubit(MapsRepository(PlacesWebServices())),
                  child: const HistoryScreen(),
                ));
    }
  }
}
