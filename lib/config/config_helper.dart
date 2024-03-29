import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/face/bloc_face.dart';
import '../bloc/histories/histories_bloc.dart';
import '../bloc/listen_language/bloc_listen_language.dart';
import '../bloc/person/bloc_person.dart';
import '../config_graphql/config_mutation.dart';
import '../config_graphql/config_query.dart';
import '../config_graphql/config_subscription.dart';
import '../config_graphql/graphql.dart';
import '../config_model/history_model.dart';
import '../config_model/img_removebg.dart';
import '../config_model/person_model.dart';
import '../config_router/name_router.dart';
import '../screen/coin_success.dart';
import '../screen/combine_img.dart';
import '../screen/in_app_purchase.dart';
import '../translations/export_lang.dart';
import '../util/config_shared_pre.dart';
import '../util/upload_file_DO.dart';
import '../widget/daily_coin.dart';
import 'config_color.dart';
import 'config_font_styles.dart';
import 'config_image.dart';
import 'config_noti_FCM.dart';
import 'format_time.dart';

const apiEndpoint = 'http://164.90.175.136:8000';
const apiUploadImageEndpoint = 'https://aigraphy.vercel.app';
final coinProductId1 = Platform.isIOS || Platform.isMacOS
    ? 'tn_aigraphyapp_com1'
    : 'aigraphyapp_com_tn1';
final coinProductId2 = Platform.isIOS || Platform.isMacOS
    ? 'tn_aigraphyapp_com2'
    : 'aigraphyapp_com_tn2';
final coinProductId3 = Platform.isIOS || Platform.isMacOS
    ? 'tn_aigraphyapp_com3'
    : 'aigraphyapp_com_tn3';
const version = 'v1.0.0';
const apiGraphql = 'ws://138.68.111.65:8080/v1/graphql';

const String SOMETHING_WENT_WRONG = 'Something went wrong';

const linkApp = 'https://aigraphyapp.com/';
const linkSupport = 'https://aigraphyapp.com/support';
const linkInsta = 'https://www.instagram.com/aigraphy.app';
const linkPolicy = 'https://aigraphyapp.com/terms-conditions-privacy-policy/';
const linkDiscord = 'https://bit.ly/4adQFfF';
DateTime now = DateTime.now();

Future<DateTime> getTimeOnline() async {
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
const TOKEN_DAILY = 30;
const TOKEN_SHARE = 5;
const TOKEN_EDIT = 5;
const TOKEN_OPEN_SLOT = 20;
const TOKEN_OPEN_HISTORY = 99;
const TOKEN_SWAP = 9;
const TOKEN_REMOVE_BG = 4;
const CATEGORY_LIMIT = 4;
const HISTORY_LIMIT = 10;
const IMAGE_CATEGORY_LIMIT = 10;
const IMAGE_SHOW_LIMIT = 10;
const DEFAULT_SLOT = 5;
const DEFAULT_SLOT_HISTORY = 30;
const POST_LIMIT = 5;

List<Map<String, dynamic>> langsData = [
  <String, dynamic>{
    'title': 'English',
    'image': uk,
    'locale': 'en',
  },
  <String, dynamic>{
    'title': 'Frensh',
    'image': frensh,
    'locale': 'fr',
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
];

List<String> landings = [
  introduce1,
  introduce2,
  introduce4,
];

List<Map<String, String>> titlesIntroduce = [
  {'title1': 'Swap your face', 'title2': 'to image'},
  {'title1': 'High quality', 'title2': 'render image'},
  {'title1': 'Keep all just', 'title2': 'funny.'}
];

NumberFormat formatCoin(BuildContext context, {int digit = 0}) {
  return NumberFormat.currency(
      locale: 'en', customPattern: '#,###', decimalDigits: digit);
}

bool isIOS = Platform.isIOS || Platform.isMacOS;

bool checkIn(DateTime? currentDate, DateTime timeNow) {
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

Future<Uint8List> getUint8List(String url) async {
  final responseData = await http.get(Uri.parse(url));
  final Uint8List res = responseData.bodyBytes;
  return res;
}

Future<void> uploadFace(BuildContext context, Uint8List? res) async {
  final imageFile = await createFileUploadDO(res!);
  final String? url = await uploadFileDO(imageFile: imageFile);
  if (url != null) {
    context.read<FaceBloc>().add(UpdateFace(url, context));
  }
}

Future<void> updateInAppCoinUser(int coins) async {
  final User userFB = FirebaseAuth.instance.currentUser!;
  final String? token = await userFB.getIdToken();
  await Graphql.initialize(token!).value.mutate(MutationOptions(
          document: gql(ConfigMutation.updatePerson()),
          variables: <String, dynamic>{
            'uuid': userFB.uid,
            'token': coins,
          }));
}

Future<PersonModel?> getPerson(BuildContext context) async {
  final User userFB = FirebaseAuth.instance.currentUser!;
  final String? token = await userFB.getIdToken();
  PersonModel? userModel;
  await Graphql.initialize(token!)
      .value
      .query(QueryOptions(
          document: gql(ConfigQuery.getPerson),
          variables: <String, dynamic>{'uuid': userFB.uid}))
      .then((value) async {
    if (!value.hasException && value.data!['User'].length > 0) {
      userModel = PersonModel.convertToObj(value.data!['User'][0]);
    }
  });
  return userModel;
}

Future<void> handleCoinUser(int reward, BuildContext context) async {
  final PersonModel? user = await getPerson(context);
  if (user != null) {
    await updateInAppCoinUser(user.coin + reward);
  }
  Navigator.of(context).pushNamed(
    Routes.coin_success,
    arguments: CoinSuccess(coins: reward),
  );
}

Future<void> configRevenueCat(BuildContext context) async {
  late PurchasesConfiguration configuration;
  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration('goog_leeHKJluPftkFMvUPtvWOdHDwcD');
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration('appl_kiDgmALwJliwfkHmfMuezrDLuxk');
  }
  await Purchases.configure(configuration);
}

void listenIAP(BuildContext context) {
  Purchases.addCustomerInfoUpdateListener((customerInfo) async {
    final reward = await getCoinIAP();
    if (reward != 0) {
      await handleCoinUser(reward, context);
      await setCoinIAP(0);
      await checkUserPro(context);
    }
  });
}

Future<XFile> createFileLocal(Uint8List res) async {
  final documentDirectory = await getTemporaryDirectory();
  final path =
      documentDirectory.path + '/${DateTime.now().toIso8601String()}.jpg';
  final File file = File(path);
  file.writeAsBytesSync(res);
  final XFile xFile = XFile(file.path);
  return xFile;
}

Future<void> shareImgGetCoin(BuildContext context) async {
  final userBloc = context.read<PersonBloc>();
  userBloc.add(UpdateCoinUser(userBloc.userModel!.coin + TOKEN_SHARE));
}

Future<void> shareMultiUrl(List<String> urls, BuildContext context) async {
  final List<XFile> files = [];
  for (String url in urls) {
    final responseData = await http.get(Uri.parse(url));
    final Uint8List res = responseData.bodyBytes;
    final XFile xFile = await createFileLocal(res);
    files.add(xFile);
  }
  final result = await Share.shareXFiles(files,
      subject: '${LocaleKeys.fromAIGraphy.tr()}: $linkApp',
      text: '${LocaleKeys.fromAIGraphy.tr()}: $linkApp');
  if (result.status == ShareResultStatus.success) {
    shareImgGetCoin(context);
    FirebaseAnalytics.instance.logEvent(name: 'click_share_image');
    BotToast.showText(
        text: LocaleKeys.shareYourImage.tr(), textStyle: style7(color: white));
  }
}

Future<void> downMultiImg(List<String> urls) async {
  for (String url in urls) {
    final responseData = await http.get(Uri.parse(url));
    final Uint8List res = responseData.bodyBytes;
    await ImageGallerySaver.saveImage(res,
        name: '${DateTime.now().toIso8601String()}.jpg');
  }
  BotToast.showText(
      text: LocaleKeys.downloadSuccessfull.tr(),
      textStyle: style7(color: white));
}

Future<void> removeBGImgDevice(BuildContext context, String link) async {
  final User userFB = FirebaseAuth.instance.currentUser!;
  try {
    final request =
        http.MultipartRequest('POST', Uri.parse('$apiEndpoint/remove_bg'));
    request.fields['uuid'] = userFB.uid;
    request.fields['link'] = link;
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final imageFile = await createFileUploadDO(response.bodyBytes);
      final String? url = await uploadFileDO(imageFile: imageFile);
      if (url != null) {
        EasyLoading.dismiss();
        Navigator.of(context)
            .pushNamed(Routes.combine_img, arguments: CombineImg(url: url));
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

Future<HistoryModel?> insertHistory(
    String url, BuildContext context, bool fromCate) async {
  HistoryModel? historyModel;
  final User userFB = FirebaseAuth.instance.currentUser!;
  final String? token = await userFB.getIdToken();
  await Graphql.initialize(token!)
      .value
      .mutate(MutationOptions(
          document: gql(ConfigMutation.insertHistory()),
          variables: <String, dynamic>{
            'uuid': userFB.uid,
            'image_res': url,
            'from_cate': fromCate,
          }))
      .then((value) {
    if (!value.hasException && value.data!['insert_Request_one'] != null) {
      historyModel =
          HistoryModel.convertToObj(value.data!['insert_Request_one']);
      context
          .read<HistoriesBloc>()
          .add(InsertHistory(historyModel: historyModel!));
    }
  });
  return historyModel;
}

Future<ImgRemoveBG?> insertImgRemBG(
    int requestId, String link, BuildContext context) async {
  ImgRemoveBG? imageRemoveBG;
  final User userFB = FirebaseAuth.instance.currentUser!;
  final String? token = await userFB.getIdToken();
  await Graphql.initialize(token!)
      .value
      .mutate(MutationOptions(
          document: gql(ConfigMutation.insertImgRemBG()),
          variables: <String, dynamic>{
            'image_rembg': link,
            'request_id': requestId,
          }))
      .then((value) {
    if (!value.hasException && value.data!['insert_ImageRemBG_one'] != null) {
      imageRemoveBG =
          ImgRemoveBG.convertToObj(value.data!['insert_ImageRemBG_one']);
      context
          .read<HistoriesBloc>()
          .add(UpdateRemImg(imageRemoveBG: imageRemoveBG!));
    }
  });
  return imageRemoveBG;
}

Future<void> getLanguagePerson(BuildContext context) async {
  final User userFB = FirebaseAuth.instance.currentUser!;
  final String? token = await userFB.getIdToken();
  await Graphql.initialize(token!)
      .value
      .query(QueryOptions(
          document: gql(ConfigQuery.getPerson),
          variables: <String, dynamic>{'uuid': userFB.uid}))
      .then((value) async {
    if (!value.hasException && value.data!['User'].length > 0) {
      final PersonModel userModel =
          PersonModel.convertToObj(value.data!['User'][0]);
      context
          .read<ListenLanguageBloc>()
          .add(InitialLanguage(locale: userModel.language, context: context));
    }
  });
}

Future<PersonModel?> listenPersonInfo(
    bool mounted, BuildContext context) async {
  final User userFB = FirebaseAuth.instance.currentUser!;
  PersonModel? userModel;
  final String? token = await userFB.getIdToken();
  Graphql.initialize(token!)
      .value
      .subscribe(SubscriptionOptions(
          document: gql(ConfigSubscription.listenPerson),
          variables: <String, dynamic>{'uuid': userFB.uid}))
      .listen((value) async {
    if (mounted) {
      if (!value.hasException && value.data!['User'].length > 0) {
        userModel = PersonModel.convertToObj(value.data!['User'][0]);
        context.read<PersonBloc>().add(GetUser(userModel!, context));
      }
    }
  });
  return userModel;
}

Future<void> listenFaces(bool mounted, BuildContext context) async {
  final User userFB = FirebaseAuth.instance.currentUser!;
  final String? token = await userFB.getIdToken();
  Graphql.initialize(token!)
      .value
      .subscribe(SubscriptionOptions(
          document: gql(ConfigSubscription.listenFace),
          variables: <String, dynamic>{
            'user_uuid': userFB.uid,
          }))
      .listen((value) {
    if (mounted) {
      context.read<FaceBloc>().add(GetFace());
    }
  });
}

Future<void> showDailyReward(BuildContext context) async {
  Future.delayed(const Duration(seconds: 2)).whenComplete(() async {
    final PersonModel? user = context.read<PersonBloc>().userModel;
    if (user != null) {
      final timeNow = await getTimeOnline();
      if (checkIn(user.dateCheckIn, timeNow)) {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: spaceCadet,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10)),
          ),
          builder: (BuildContext context) {
            return const DailyCoin();
          },
        );
      }
    }
  });
}

Future<void> showPriceScreen(BuildContext context) async {
  if (isIOS) {
    final bool showPrice = await getBoolVal(input: 'show_price') ?? false;
    if (showPrice) {
      await setBoolVal(false, 'show_price');
      Future.delayed(const Duration(seconds: 2)).whenComplete(() async {
        final res = await Navigator.of(context).pushNamed(
            Routes.in_app_purchase,
            arguments: InAppPurchase(showDaily: true)) as bool;
        if (res) {
          showDailyReward(context);
        }
      });
    }
  } else {
    showDailyReward(context);
  }
}

Future<void> launchUrlUlti(String url) async {
  final Uri _url = Uri.parse(url);
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

String formatDays(DateTime dateTime) {
  return FormatTime.formatTime(
      dateTime: dateTime.toLocal(), format: Format.dMyHm);
}

String formatNumber(dynamic num) {
  if (num > 999 && num < 99999) {
    return '${(num / 1000).toStringAsFixed(1)} K';
  } else if (num > 99999 && num < 999999) {
    return '${(num / 1000).toStringAsFixed(0)} K';
  } else if (num > 999999 && num < 999999999) {
    return '${(num / 1000000).toStringAsFixed(1)} M';
  } else if (num > 999999999) {
    return '${(num / 1000000000).toStringAsFixed(1)} B';
  } else {
    return num.toString();
  }
}
