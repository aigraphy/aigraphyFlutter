import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../aigraphy.dart';
import '../bloc/set_user_pro/set_user_pro_bloc.dart';
import '../config_router/name_router.dart';
import '../screen/home.dart';
import '../screen/iap_first_time.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotify() async {
    await _firebaseMessaging.requestPermission();
    initPushNoti();
  }
}

Future<void> initPushNoti() async {
  FirebaseMessaging.instance.getInitialMessage().then(listenNoti);
  FirebaseMessaging.onMessageOpenedApp.listen(listenNoti);
  await FirebaseMessaging.instance.subscribeToTopic('all');
  final customerInfo = await Purchases.getCustomerInfo();
  await checkNotiFirstTime(customerInfo);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> checkUserPro(BuildContext context) async {
  final customerInfo = await Purchases.getCustomerInfo();
  if (customerInfo.nonSubscriptionTransactions.isEmpty) {
    context.read<SetUserPro>().setIndex(false);
  } else {
    context.read<SetUserPro>().setIndex(true);
  }
}

Future<void> checkNotiFirstTime(CustomerInfo customerInfo) async {
  if (customerInfo.nonSubscriptionTransactions.isEmpty) {
    await notiInAppFirstTime();
  } else {
    await cancelNotiInAppFirstTime();
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
  print('Notification Message: ${message.data}');
}

void listenNoti(RemoteMessage? mess) {
  if (mess == null) {
    return;
  }
  navigateKey.currentState
      ?.pushReplacementNamed(Routes.home, arguments: const Home(index: 0));
  if (mess.from == 'in_app_first_time') {
    navigateKey.currentState
        ?.pushNamed(Routes.iap_first_time, arguments: IAPFirstTime());
  }
}

Future<void> notiInAppFirstTime() async {
  await FirebaseMessaging.instance.subscribeToTopic('in_app_first_time');
}

Future<void> cancelNotiInAppFirstTime() async {
  await FirebaseMessaging.instance.unsubscribeFromTopic('in_app_first_time');
}
