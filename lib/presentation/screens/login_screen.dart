// ignore_for_file: recursive_getters, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mfs/business_logic/cubit/phone_auth/phone_auth_cubit.dart';
import 'package:mfs/constnats/my_colors.dart';
import 'package:mfs/constnats/strings.dart';
import 'package:mfs/presentation/widgets/progress_indicator.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final GlobalKey<FormState>? _phoneFormKey = GlobalKey();

  late String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
            child: Form(
                key: _phoneFormKey,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 88),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIntroTexts(),
                      const SizedBox(height: 110),
                      _buildPhoneFormField(),
                      const SizedBox(height: 70),
                      _buildNextButton(context),
                      _buildPhoneNumberSubmitedBloc(),
                    ],
                  ),
                ))),
      ),
    );
  }

  Widget _buildIntroTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What is your phone number ?",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          child: const Text(
            "Please enter yout phone number to verify your account",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        )
      ],
    );
  }

  Widget _buildPhoneFormField() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: MyColors.lightGrey),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              generateCountryFlag() + "+962",
              style: const TextStyle(fontSize: 18, letterSpacing: 2.0),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: MyColors.blue),
              borderRadius: BorderRadius.circular(6),
            ),
            child: TextFormField(
              autocorrect: true,
              style: const TextStyle(
                fontSize: 18,
                letterSpacing: 2.0,
              ),
              decoration: const InputDecoration(border: InputBorder.none),
              cursorColor: Colors.black,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter yout phone number!";
                } else if (value.length < 8) {
                  return "Too short for a phone number!";
                }

                return null;
              },
              onSaved: (value) {
                phoneNumber = value!;
              },
            ),
          ),
        ),
      ],
    );
  }

  String generateCountryFlag() {
    String conutryCode = 'jo';

    String flage = conutryCode.toUpperCase().replaceAllMapped(RegExp(r"[A-Z]"),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397));

    return flage;
  }

  Widget _buildNextButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          showProgressIndicator(context);
          _register(context);
        },
        child: const Text(
          "Next",
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
    );
  }

  _buildPhoneNumberSubmitedBloc() {
    return BlocListener<PhoneAuthCubit, PhoneAuthState>(
      listenWhen: (previous, current) {
        return previous != current;
      },
      listener: (context, state) {
        if (state is LoadingState) {
          showProgressIndicator(context);
        }

        if (state is PhoneNumberSubmitedState) {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(otpScreen, arguments: phoneNumber);
        }

        if (state is ErrorOccurredState) {
          Navigator.of(context).pop();
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

  Future<void> _register(BuildContext context) async {
    if (!_phoneFormKey!.currentState!.validate()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop();
    _phoneFormKey!.currentState!.save();
    BlocProvider.of<PhoneAuthCubit>(context).submitPhoneNumber(phoneNumber);
  }
}
