import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../app/widget_support.dart';
import '../../common/bloc/listen_language/bloc_listen_language.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/preference/shared_preference_builder.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_applovin_banner.dart';
import '../../common/widget/animation_click.dart';
import '../../common/widget/app_bar_cpn.dart';
import '../../common/widget/leave_feedback.dart';
import '../../common/widget/rate_app.dart';
import '../../translations/export_lang.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool switchNoti = false;

  Widget item(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: body(color: grey1100),
            ),
          ),
          trailing ??
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Image.asset(
                  icKeyboardRight,
                  width: 24,
                  height: 24,
                  color: grey800,
                ),
              )
        ],
      ),
    );
  }

  Future<bool> getNotification() async {
    switchNoti = await getNoti();
    setState(() {});
    return switchNoti;
  }

  @override
  void initState() {
    super.initState();
    getNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCpn(
        left: AnimationClick(
          function: () {
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Image.asset(icClose, width: 24, height: 24, color: grey1100),
          ),
        ),
        center:
            Text(LocaleKeys.settings.tr(), style: headline(color: grey1100)),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AppWidget.typeButtonStartAction(
            context: context,
            input: '${LocaleKeys.signOut.tr()}',
            bgColor: grey200,
            textColor: grey1100,
            borderColor: grey200,
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.onboarding, (route) => false);
            }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ListView(
        padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 24, right: 24, bottom: 16),
            child: AdsApplovinBanner(),
          ),
          Text(
            LocaleKeys.support.tr(),
            style: subhead(color: grey600),
          ),
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 32),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: grey200, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                item(LocaleKeys.contactSupport.tr()),
                Container(
                  decoration: BoxDecoration(
                      color: grey200, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          LocaleKeys.notification.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: body(color: grey1100, fontWeight: '400'),
                        ),
                      ),
                      CupertinoSwitch(
                        activeColor: primary,
                        value: switchNoti,
                        onChanged: (value) async {
                          setState(() {
                            switchNoti = value;
                          });
                          if (switchNoti) {
                            EasyLoading.show();
                            await setNoti(true);
                            try {
                              await requestPermissions();
                              EasyLoading.dismiss();
                            } catch (e) {
                              EasyLoading.dismiss();
                            }
                          } else {
                            await setNoti(false);
                            flutterLocalNotificationsPlugin.cancelAll();
                          }
                        },
                      )
                    ],
                  ),
                ),
                AnimationClick(
                    function: () {
                      AppWidget.showDialogCustom(LocaleKeys.doYouWant.tr(),
                          LocaleKeys.youWillLose.tr(), context: context,
                          remove: () async {
                        Navigator.of(context).pop();
                        EasyLoading.show();
                        await AppWidget.deleteUser();
                        await FirebaseAuth.instance.signOut();
                        EasyLoading.dismiss();
                        BotToast.showText(
                            text: LocaleKeys.youHaveDeleted.tr(),
                            textStyle: body(color: grey1100));
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.onboarding, (route) => false);
                      });
                    },
                    child: item(LocaleKeys.deleteAccount.tr())),
              ],
            ),
          ),
          Text(
            LocaleKeys.about.tr(),
            style: subhead(color: grey600),
          ),
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: grey200, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                item(LocaleKeys.aboutAIGraphy.tr()),
                AnimationClick(
                  function: () {
                    Navigator.of(context).pushNamed(Routes.language);
                  },
                  child: item(LocaleKeys.language.tr(),
                      trailing: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            context.watch<ListenLanguageBloc>().language,
                            style: callout(color: grey600, fontWeight: '400'),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Image.asset(
                              icKeyboardRight,
                              width: 24,
                              height: 24,
                              color: grey800,
                            ),
                          )
                        ],
                      )),
                ),
                item(LocaleKeys.securityTerms.tr()),
                AnimationClick(
                    function: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const LeaveFeedback();
                        },
                      );
                    },
                    child: item(LocaleKeys.leaveYourFeedback.tr())),
                AnimationClick(
                    function: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const RateAppWidget();
                        },
                      );
                    },
                    child: item(LocaleKeys.rateFaceSwap.tr(),
                        trailing: RatingBar(
                          initialRating: 5,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 16,
                          ignoreGestures: true,
                          ratingWidget: RatingWidget(
                            full: Image.asset(
                              rate,
                              color: corn2,
                            ),
                            half: const SizedBox(),
                            empty: Image.asset(
                              rate,
                              color: corn2,
                            ),
                          ),
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 4.0),
                          onRatingUpdate: (rating) {},
                        ))),
                item(LocaleKeys.subscriptionPolicy.tr()),
                item(LocaleKeys.discordCommunity.tr()),
                item(LocaleKeys.appVersion.tr(),
                    trailing: Text(
                      version,
                      style: callout(color: grey600, fontWeight: '400'),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
