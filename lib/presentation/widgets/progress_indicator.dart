import 'package:flutter/material.dart';

void showProgressIndicator(BuildContext ctx) {
  AlertDialog alertDialog = const AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0.0,
    content: Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
      ),
    ),
  );

  showDialog(
      context: ctx,
      barrierColor: Colors.white.withOpacity(0),
      barrierDismissible: false,
      builder: (_) => alertDialog);
}
