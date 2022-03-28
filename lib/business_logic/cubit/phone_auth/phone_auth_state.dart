part of 'phone_auth_cubit.dart';

@immutable
abstract class PhoneAuthState {}

class PhoneAuthInitial extends PhoneAuthState {}

class LoadingState extends PhoneAuthState {}

class ErrorOccurredState extends PhoneAuthState {
  final String errorMsg;

  ErrorOccurredState(this.errorMsg);
}

class PhoneNumberSubmitedState extends PhoneAuthState {}

class PhoneOTPVerifiedState extends PhoneAuthState {}
