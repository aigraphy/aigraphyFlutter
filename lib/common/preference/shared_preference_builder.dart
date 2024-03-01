import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

Future<bool?> getValueBool({required String input}) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  return shared.getBool(input);
}

Future<void> setSharedBool(bool value, String key) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  shared.setBool('$key', value);
}

//down image
Future<int> getCountDownImage() async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  return shared.getInt('down_image') ?? 0;
}

Future<void> setCountDownImage(int value) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  shared.setInt('down_image', value);
}

//save review
Future<int> getAmountShowReview({String input = 'amount_review'}) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  final int amountCreate = shared.getInt('amount_review') ?? 0;
  return amountCreate;
}

Future<void> setAmountShowReview(int amount) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  shared.setInt('amount_review', amount);
}

// show onboarding
Future<int> getCountIntoApp() async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  return shared.getInt('into_app') ?? 0;
}

Future<void> setCountIntoApp(int value) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  shared.setInt('into_app', value);
}

// reward tokens
Future<int> getRewardTokenIAP() async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  return shared.getInt('reward_token') ?? 0;
}

Future<void> setRewardTokenIAP(int value) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  shared.setInt('reward_token', value);
}

// Notification
Future<bool> getNoti() async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  return shared.getBool('turn_on') ?? false;
}

Future<void> setNoti(bool value) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  shared.setBool('turn_on', value);
}

// First Login
Future<bool> getIsFirstUseApp() async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  return shared.getBool('is_first') ?? false;
}

Future<void> setIsFirstUseApp(bool value) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  shared.setBool('is_first', value);
}
