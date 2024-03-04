import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

import '../../features/screen/result_remove_bg.dart';
import '../../features/screen/token_success.dart';
import '../../translations/export_lang.dart';
import '../bloc/list_requests/list_requests_bloc.dart';
import '../bloc/listen_language/bloc_listen_language.dart';
import '../bloc/recent_face/bloc_recent_face.dart';
import '../bloc/user/bloc_user.dart';
import '../graphql/config.dart';
import '../graphql/mutations.dart';
import '../graphql/queries.dart';
import '../graphql/subscription.dart';
import '../helper_ads/ads_lovin_utils.dart';
import '../models/image_removebg.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';
import '../preference/shared_preference_builder.dart';
import '../route/routes.dart';
import '../util/upload_image.dart';
import '../widget/rate_app.dart';
import 'colors.dart';
import 'error_code.dart';
import 'firebase_api.dart';
import 'images.dart';
import 'styles.dart';

/* MUST CONFIG */
const apiEndpoint = 'http://164.90.175.136:8000';
const apiUploadImageEndpoint = 'https://aigraphy.vercel.app';
const tokenIdentifier1 = 'dev_ditustudio_faceswap1';
const tokenIdentifier2 = 'dev_ditustudio_faceswap2';
const tokenIdentifier4 = 'dev_ditustudio_faceswap4';
const version = 'v1.0.0';

const defaultAvatar =
    'https://user-images.githubusercontent.com/79369571/182101394-89e63593-11a1-4aed-8ec5-9638d9c62a81.png';

const String legalInappPurchase =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

/* MUST CONFIG */
const linkApp = 'https://bit.ly/lpfaceswap';
const linkAppAIGenVision = 'https://aivision.webflow.io/';
const linkFacebook = 'https://www.facebook.com/profile.php?id=61555408634180';
const linkTwitter = 'https://twitter.com/izidev2023';
const linkPolicy = 'https://aigraphyapp.com/terms-conditions-privacy-policy/';
DateTime now = DateTime.now();

Future<DateTime> getTime() async {
  DateTime? dateTime;
  final res = await http
      .get(Uri.parse('https://worldtimeapi.org/api/timezone/Etc/UTC'));
  if (res.statusCode == 200) {
    final result = jsonDecode(res.body);
    dateTime =
        DateTime.tryParse(result['datetime'])?.toLocal() ?? DateTime.now();
  }
  return dateTime ?? DateTime.now();
}

String locale = 'en';
const TOKEN_REWARD = 15;
const TOKEN_DAILY = 15;
const TOKEN_SHARE = 3;
const TOKEN_EDIT = 5;
const TOKEN_OPEN_SLOT = 20;
const TOKEN_OPEN_HISTORY = 99;
const TOKEN_SWAP = 9;
const TOKEN_SWAP_VIDEO = 29;
const TOKEN_SAVE_VIDEO = 5;
const TOKEN_SAVE_VIDEO_ONLY_HD = 3;
const TOKEN_SAVE_VIDEO_ONLY_MARK = 2;
const TOKEN_REMOVE_BG = 4;
const CATEGORY_LIMIT = 4;
const HISTORY_LIMIT = 10;
const IMAGE_CATEGORY_LIMIT = 10;
const IMAGE_SHOW_LIMIT = 10;
const DEFAULT_SLOT = 5;
const DEFAULT_SLOT_HISTORY = 30;

// image guide remove bg
// MUST CONFIG
const image1 = defaultAvatar;
const image1BG = defaultAvatar;
const imageAnime = defaultAvatar;
const imageAnimeBG = defaultAvatar;
const imageHumanAnimalBG = defaultAvatar;

List<Map<String, dynamic>> languagesData = [
  <String, dynamic>{
    'title': 'English',
    'image': uk,
    'locale': 'en',
  },
  <String, dynamic>{
    'title': 'Hindi',
    'image': india,
    'locale': 'hi',
  },
  <String, dynamic>{
    'title': 'Vietnamese',
    'image': vietnam,
    'locale': 'vi',
  },
  <String, dynamic>{
    'title': 'Italian',
    'image': italy,
    'locale': 'it',
  },
  <String, dynamic>{
    'title': 'Portuguese',
    'image': portugal,
    'locale': 'pt',
  },
  <String, dynamic>{
    'title': 'Spanish',
    'image': spain,
    'locale': 'es',
  },
  <String, dynamic>{
    'title': 'Japanese',
    'image': japan,
    'locale': 'ja',
  },
];

final RegExp emailValid = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

NumberFormat formatToken(BuildContext context, {int digit = 0}) {
  return NumberFormat.currency(
      locale: 'en', customPattern: '#,###', decimalDigits: digit);
}

bool isIOS = Platform.isIOS || Platform.isMacOS;

final FilterOptionGroup filterOption = FilterOptionGroup(
  videoOption: const FilterOption(
    durationConstraint: DurationConstraint(
      min: Duration(seconds: 1),
      max: Duration(seconds: 16),
      allowNullable: false,
    ),
  ),
);

String formatDuration(Duration duration) {
  final int totalSeconds = duration.inSeconds;
  final int hours = totalSeconds ~/ 3600;
  final int minutes = (totalSeconds % 3600) ~/ 60;
  final int seconds = totalSeconds % 60;

  String formattedDuration = '';
  if (hours > 0) {
    formattedDuration += '$hours:';
  }
  formattedDuration +=
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  return formattedDuration;
}

Future<void> showRating(BuildContext context) async {
  final bool showedReview = await getValueBool(input: 'showed_review') ?? false;
  if (!showedReview) {
    showRatingWhenCreateImage(context);
  }
}

Future<void> showRatingWhenCreateImage(BuildContext context) async {
  int count = await getAmountShowReview();
  if (count % 20 == 19) {
    showDialog(
      context: context,
      builder: (context) {
        return const RateAppWidget();
      },
    );
  }
  count += 1;
  setAmountShowReview(count);
}

Future<void> launchUrlFaceSwap() async {
  final Uri _url = Uri.parse(linkAppAIGenVision);
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

bool canCheckIn(DateTime? currentDate, DateTime timeNow) {
  if (currentDate == null) {
    return true;
  } else {
    if (currentDate.isBefore(timeNow.subtract(const Duration(days: 1)))) {
      return true;
    } else {
      return false;
    }
  }
}

Future<File> createFileUploadDO(Uint8List res) async {
  final documentDirectory = await getTemporaryDirectory();
  final path =
      documentDirectory.path + '/${DateTime.now().toIso8601String()}.jpg';
  final File file = File(path);
  file.writeAsBytesSync(res);
  return file;
}

Future<Uint8List> getImage(String url) async {
  final responseData = await http.get(Uri.parse(url));
  final Uint8List res = responseData.bodyBytes;
  return res;
}

Future<void> uploadFace(BuildContext context, Uint8List? res) async {
  final imageFile = await createFileUploadDO(res!);
  final String? url = await uploadFile(imageFile: imageFile);
  if (url != null) {
    context.read<RecentFaceBloc>().add(UpdateFace(url, context));
  }
}

Future<void> updateInAppTokenUser(int tokens) async {
  final User firebaseUser = FirebaseAuth.instance.currentUser!;
  final String? token = await firebaseUser.getIdToken();
  await Config.initializeClient(token!).value.mutate(MutationOptions(
          document: gql(Mutations.updateUser()),
          variables: <String, dynamic>{
            'uuid': firebaseUser.uid,
            'token': tokens,
          }));
}

Future<UserModel?> getUser(BuildContext context) async {
  final User firebaseUser = FirebaseAuth.instance.currentUser!;
  final String? token = await firebaseUser.getIdToken();
  UserModel? userModel;
  await Config.initializeClient(token!)
      .value
      .query(QueryOptions(
          document: gql(Queries.getUser),
          variables: <String, dynamic>{'uuid': firebaseUser.uid}))
      .then((value) async {
    if (!value.hasException && value.data!['User'].length > 0) {
      userModel = UserModel.fromJson(value.data!['User'][0]);
    }
  });
  return userModel;
}

Future<void> handleTokenUser(int reward, BuildContext context) async {
  final UserModel? user = await getUser(context);
  if (user != null) {
    await updateInAppTokenUser(user.token + reward);
  }
  Navigator.of(context).pushNamed(
    Routes.token_success,
    arguments: TokenSuccess(tokens: reward),
  );
}

Future<void> initPlatformState(BuildContext context) async {
  late PurchasesConfiguration configuration;
  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration('your_api_key');
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration('your_api_key');
  }
  await Purchases.configure(configuration);
}

void listenInAppPurchase(BuildContext context) {
  Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    final reward = await getRewardTokenIAP();
    if (reward != 0) {
      await handleTokenUser(reward, context);
      await setRewardTokenIAP(0);
      await checkUserPro(context);
      await checkNotiFirstTime(customerInfo);
      await checkNotiOneTime(customerInfo);
    }
  });
}

/// Config notification
Future<void> createNotification() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

Future<void> requestPermissions() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  if (Platform.isIOS || Platform.isMacOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await scheduleNotification(7, 59);
  } else if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? granted =
        await androidImplementation?.requestNotificationsPermission();
    if (granted != null && granted) {
      await scheduleNotification(7, 59);
    }
  }
}

Future<void> scheduleNotification(int hour, int minutes) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'FaceSwap',
    'Remind Daily',
    channelDescription: 'Hey yo! Get a FREE Token now!',
  );
  const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
  const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  final offset = now.timeZoneOffset;
  await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'FaceSwap',
      'Hey yo! Get a FREE Token now!',
      tz.TZDateTime(tz.local, now.year, now.month, now.day,
          hour - offset.inHours, minutes, 00),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time);
}

Future<XFile> createFile(Uint8List res) async {
  final documentDirectory = await getTemporaryDirectory();
  final path =
      documentDirectory.path + '/${DateTime.now().toIso8601String()}.jpg';
  final File file = File(path);
  file.writeAsBytesSync(res);
  final XFile xFile = XFile(file.path);
  return xFile;
}

Future<void> shareImageGetToken(BuildContext context) async {
  final UserBloc userBloc = context.read<UserBloc>();
  userBloc.add(UpdateTokenUser(userBloc.userModel!.token + TOKEN_SHARE));
}

Future<void> shareContentMultiUrl(
    List<String> urls, BuildContext context) async {
  final List<XFile> files = [];
  for (String url in urls) {
    final responseData = await http.get(Uri.parse(url));
    final Uint8List res = responseData.bodyBytes;
    final XFile xFile = await createFile(res);
    files.add(xFile);
  }
  final result = await Share.shareXFiles(files,
      subject: '${LocaleKeys.fromFaceSwap.tr()}: $linkApp',
      text: '${LocaleKeys.fromFaceSwap.tr()}: $linkApp');
  if (result.status == ShareResultStatus.success) {
    // AdLovinUtils().showAdIfReady();
    shareImageGetToken(context);
    FirebaseAnalytics.instance.logEvent(name: 'click_share_image');
    BotToast.showText(
        text: LocaleKeys.shareYourImage.tr(), textStyle: body(color: grey1100));
  }
}

Future<void> downloadMultiImage(List<String> urls) async {
  for (String url in urls) {
    final responseData = await http.get(Uri.parse(url));
    final Uint8List res = responseData.bodyBytes;
    await ImageGallerySaver.saveImage(res,
        name: '${DateTime.now().toIso8601String()}.jpg');
  }
  BotToast.showText(
      text: LocaleKeys.downloadSuccessfull.tr(),
      textStyle: body(color: grey1100));
}

Future<void> downloadVideo(String url, BuildContext context) async {
  final appDocDir = await getTemporaryDirectory();
  final String savePath =
      appDocDir.path + '/${DateTime.now().toIso8601String()}.mp4';
  await Dio().download(url, savePath, onReceiveProgress: (count, total) {
    EasyLoading.showProgress(count / total,
        status: ((count / total) * 100).toStringAsFixed(0) + '%');
  });
  await ImageGallerySaver.saveFile(savePath,
      name: '${DateTime.now().toIso8601String()}.jpg');
  EasyLoading.dismiss();
  BotToast.showText(
      text: LocaleKeys.downloadSuccessfull.tr(),
      textStyle: body(color: grey1100));
}

Future<void> removeBGImageDevice(BuildContext context, String path,
    {String? option}) async {
  EasyLoading.show();
  final User _firebaseUser = FirebaseAuth.instance.currentUser!;
  try {
    final request = http.MultipartRequest(
        'POST', Uri.parse('$apiEndpoint/remove_bg_image_device'));
    request.files.addAll([
      await http.MultipartFile.fromPath('path', path),
    ]);
    request.fields['uuid'] = _firebaseUser.uid;
    if (option != null) {
      request.fields['option'] = option;
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final imageFile = await createFileUploadDO(response.bodyBytes);
      final String? url = await uploadFile(imageFile: imageFile);
      if (url != null) {
        final res = await insertRequest(url, context);
        if (res != null) {
          EasyLoading.dismiss();
          Navigator.of(context).pushNamed(Routes.result_remove_bg,
              arguments: ResultRemoveBg(url: url));
        }
      }
    } else {
      EasyLoading.dismiss();
      BotToast.showText(text: SOMETHING_WENT_WRONG);
    }
  } catch (e) {
    EasyLoading.dismiss();
    print('Error uploading image: $e');
  }
}

Future<RequestModel?> insertRequest(String url, BuildContext context) async {
  RequestModel? requestModel;
  final User _firebaseUser = FirebaseAuth.instance.currentUser!;
  final String? token = await _firebaseUser.getIdToken();
  await Config.initializeClient(token!)
      .value
      .mutate(MutationOptions(
          document: gql(Mutations.insertRequest()),
          variables: <String, dynamic>{
            'uuid': _firebaseUser.uid,
            'image_res': url,
          }))
      .then((value) {
    if (!value.hasException && value.data!['insert_Request_one'] != null) {
      requestModel = RequestModel.fromJson(value.data!['insert_Request_one']);
      context
          .read<ListRequestsBloc>()
          .add(InsertRequest(requestModel: requestModel!));
    }
  });
  return requestModel;
}

Future<ImageRemoveBG?> insertImageRemBG(
    int requestId, String link, BuildContext context) async {
  ImageRemoveBG? imageRemoveBG;
  final User _firebaseUser = FirebaseAuth.instance.currentUser!;
  final String? token = await _firebaseUser.getIdToken();
  await Config.initializeClient(token!)
      .value
      .mutate(MutationOptions(
          document: gql(Mutations.insertImageRemBG()),
          variables: <String, dynamic>{
            'image_rembg': link,
            'request_id': requestId,
          }))
      .then((value) {
    if (!value.hasException && value.data!['insert_ImageRemBG_one'] != null) {
      imageRemoveBG =
          ImageRemoveBG.fromJson(value.data!['insert_ImageRemBG_one']);
      context
          .read<ListRequestsBloc>()
          .add(UpdateRemoveImage(imageRemoveBG: imageRemoveBG!));
    }
  });
  return imageRemoveBG;
}

Future<void> getLanguageUser(BuildContext context) async {
  final User firebaseUser = FirebaseAuth.instance.currentUser!;
  final String? token = await firebaseUser.getIdToken();
  await Config.initializeClient(token!)
      .value
      .query(QueryOptions(
          document: gql(Queries.getUser),
          variables: <String, dynamic>{'uuid': firebaseUser.uid}))
      .then((value) async {
    if (!value.hasException && value.data!['User'].length > 0) {
      final UserModel userModel = UserModel.fromJson(value.data!['User'][0]);
      context
          .read<ListenLanguageBloc>()
          .add(InitialLanguage(locale: userModel.language, context: context));
    }
  });
}

Future<UserModel?> getUserInfo(bool mounted, BuildContext context) async {
  final User firebaseUser = FirebaseAuth.instance.currentUser!;
  UserModel? userModel;
  final String? token = await firebaseUser.getIdToken();
  Config.initializeClient(token!)
      .value
      .subscribe(SubscriptionOptions(
          document: gql(Subscription.listenUser),
          variables: <String, dynamic>{'uuid': firebaseUser.uid}))
      .listen((value) async {
    if (mounted) {
      if (!value.hasException && value.data!['User'].length > 0) {
        userModel = UserModel.fromJson(value.data!['User'][0]);
        context.read<UserBloc>().add(GetUser(userModel!, context));
      }
    }
  });
  return userModel;
}

Future<void> getRecentFace(bool mounted, BuildContext context) async {
  final User firebaseUser = FirebaseAuth.instance.currentUser!;
  final String? token = await firebaseUser.getIdToken();
  Config.initializeClient(token!)
      .value
      .subscribe(SubscriptionOptions(
          document: gql(Subscription.listenRecentFace),
          variables: <String, dynamic>{
            'user_uuid': firebaseUser.uid,
          }))
      .listen((value) {
    if (mounted) {
      context.read<RecentFaceBloc>().add(GetRecentFace());
    }
  });
}

Future<void> createNoti() async {
  await createNotification();
  await requestPermissions();
}
