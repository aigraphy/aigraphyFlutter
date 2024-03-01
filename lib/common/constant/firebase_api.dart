import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../app/app.dart';
import '../../features/screen/bottom_bar.dart';
import '../../features/screen/price_first_time.dart';
import '../../features/screen/price_one_time.dart';
import '../route/routes.dart';
import 'helper.dart';

void handleMess(RemoteMessage? mess) {
  if (mess == null) {
    return;
  }
  navigateKey.currentState?.pushReplacementNamed(Routes.bottom_bar,
      arguments: const BottomBar(index: 0));
  if (mess.from == 'buy_first_time') {
    navigateKey.currentState
        ?.pushNamed(Routes.price_first_time, arguments: PriceFirstTime());
  } else if (mess.from == 'buy_one_time') {
    navigateKey.currentState
        ?.pushNamed(Routes.price_one_time, arguments: PriceOneTime());
  }
}

Future<void> initPushNoti() async {
  FirebaseMessaging.instance.getInitialMessage().then(handleMess);
  FirebaseMessaging.onMessageOpenedApp.listen(handleMess);
  await FirebaseMessaging.instance.subscribeToTopic('all');
  final customerInfo = await Purchases.getCustomerInfo();
  await checkNotiFirstTime(customerInfo);
  await checkNotiOneTime(customerInfo);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

Future<void> checkNotiFirstTime(CustomerInfo customerInfo) async {
  if (customerInfo.nonSubscriptionTransactions.isEmpty) {
    await subNotiFirstTime();
  } else {
    await cancelNotiFirstTime();
  }
}

Future<void> checkNotiOneTime(CustomerInfo customerInfo) async {
  if (customerInfo.nonSubscriptionTransactions.length == 1) {
    final latestTran =
        DateTime.parse(customerInfo.nonSubscriptionTransactions[0].purchaseDate)
            .toLocal();
    final timeNow = await getTime();
    final isBefore = timeNow.isBefore(latestTran.add(const Duration(days: 5)));
    final isAfter = timeNow.isAfter(latestTran.add(const Duration(days: 2)));
    if (isAfter && isBefore) {
      await subNotiOneTime();
    } else {
      await cancelNotiOneTime();
    }
  } else {
    await cancelNotiOneTime();
  }
}

Future<void> subNotiFirstTime() async {
  await FirebaseMessaging.instance.subscribeToTopic('buy_first_time');
}

Future<void> subNotiOneTime() async {
  await FirebaseMessaging.instance.subscribeToTopic('buy_one_time');
}

Future<void> cancelNotiFirstTime() async {
  await FirebaseMessaging.instance.unsubscribeFromTopic('buy_first_time');
}

Future<void> cancelNotiOneTime() async {
  await FirebaseMessaging.instance.unsubscribeFromTopic('buy_one_time');
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
  print('Notification Message: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotify() async {
    await _firebaseMessaging.requestPermission();
    initPushNoti();
  }
}
