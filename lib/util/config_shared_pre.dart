import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

Future<bool?> getBoolVal({required String input}) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  return shared.getBool(input);
}

Future<void> setBoolVal(bool value, String key) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  shared.setBool('$key', value);
}

Future<int> getCoinIAP() async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  return shared.getInt('coin_iap') ?? 0;
}

Future<void> setCoinIAP(int value) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  shared.setInt('coin_iap', value);
}

Future<bool> getLocalNoti() async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  return shared.getBool('local_noti') ?? false;
}

Future<void> setLocalNoti(bool value) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  shared.setBool('local_noti', value);
}

Future<int> getShowReview({String input = 'show_review'}) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  final int amountCreate = shared.getInt('show_review') ?? 0;
  return amountCreate;
}

Future<void> setShowReview(int amount) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  shared.setInt('show_review', amount);
}
