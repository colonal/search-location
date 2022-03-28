// ignore_for_file: recursive_getters, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mfs/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:mfs/constnats/my_colors.dart';
import 'package:mfs/constnats/strings.dart';
import 'package:mfs/presentation/widgets/progress_indicator.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatelessWidget {
  OtpScreen({required this.phoneNumber, Key? key}) : super(key: key);

  final String phoneNumber;

  late String otpCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroTexts(),
                const SizedBox(height: 88),
                _buildPinCodeFilds(context),
                const SizedBox(height: 60),
                _buildNextButton(context),
                _buildPhoneVerifivationBloc(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Verify your phone number",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: RichText(
            text: TextSpan(
                text: "Enter your 6 digit code numbers send to ",
                style: const TextStyle(
                    color: Colors.black, fontSize: 18, height: 1.4),
                children: [
                  TextSpan(
                      text: phoneNumber,
                      style: const TextStyle(color: MyColors.blue))
                ]),
          ),
        )
      ],
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () {
            showProgressIndicator(context);
            _login(context);
          },
          child: const Text(
            "Verify",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(110, 50),
            primary: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }

  _buildPinCodeFilds(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      autoFocus: true,
      cursorColor: Colors.black,
      keyboardType: TextInputType.number,
      length: 6,
      obscureText: false,
      animationType: AnimationType.scale,
      pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(5),
          fieldHeight: 50,
          fieldWidth: 40,
          borderWidth: 1,
          activeColor: MyColors.blue,
          inactiveColor: MyColors.blue,
          inactiveFillColor: Colors.white,
          activeFillColor: MyColors.lightBlue,
          selectedColor: MyColors.blue,
          selectedFillColor: Colors.white),
      animationDuration: const Duration(milliseconds: 300),
      backgroundColor: Colors.white,
      enableActiveFill: true,
      onCompleted: (code) {
        debugPrint("Completed");
        otpCode = code;
      },
      onChanged: (value) {
        debugPrint(value);
      },
    );
  }

  _buildPhoneVerifivationBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previous, current) {
        return previous != current;
      },
      listener: (context, state) {
        if (state is LoadingState) {
          showProgressIndicator(context);
        }

        if (state is PhoneOTPVerifiedState) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(mapScreen);
        }

        if (state is ErrorOccurredState) {
          String errorMsg = (state).errorMsg;

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.black,
            duration: const Duration(seconds: 3),
          ));
        }
      },
      child: Container(),
    );
  }

  void _login(BuildContext context) {
    BlocProvider.of<PhoneAuthCubit>(context).submitOTP(otpCode);
  }
}
