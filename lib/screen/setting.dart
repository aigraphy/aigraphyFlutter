import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../translations/export_lang.dart';
import '../bloc/listen_language/bloc_listen_language.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config/config_local_noti.dart';
import '../config_router/name_router.dart';
import '../util/config_shared_pre.dart';
import '../widget/appbar_custom.dart';
import '../widget/banner_ads.dart';
import '../widget/click_widget.dart';
import '../widget_helper.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
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
              style: style7(color: white),
            ),
          ),
          trailing ??
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Image.asset(
                  icKeyboardRight,
                  width: 24,
                  height: 24,
                  color: cultured,
                ),
              )
        ],
      ),
    );
  }

  Future<bool> getNotification() async {
    switchNoti = await getLocalNoti();
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
      appBar: AppBarCustom(
        left: ClickWidget(
          function: () {
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Image.asset(icClose, width: 24, height: 24, color: white),
          ),
        ),
        center: Text(LocaleKeys.settings.tr(), style: style6(color: white)),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AigraphyWidget.typeButtonStartAction(
            context: context,
            input: '${LocaleKeys.signOut.tr()}',
            bgColor: spaceCadet,
            textColor: white,
            borderColor: spaceCadet,
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.introduce, (route) => false);
            }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ListView(
        padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 24, right: 24, bottom: 16),
            child: BannerAds(),
          ),
          Text(
            LocaleKeys.support.tr(),
            style: style9(color: isabelline),
          ),
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 32),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: spaceCadet, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ClickWidget(
                    function: () {
                      launchUrlUlti(linkSupport);
                    },
                    child: item(LocaleKeys.contactSupport.tr())),
                Container(
                  decoration: BoxDecoration(
                      color: spaceCadet,
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          LocaleKeys.notification.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: style7(color: white, fontWeight: '400'),
                        ),
                      ),
                      CupertinoSwitch(
                        activeColor: blue,
                        value: switchNoti,
                        onChanged: (value) async {
                          setState(() {
                            switchNoti = value;
                          });
                          if (switchNoti) {
                            EasyLoading.show();
                            await setLocalNoti(true);
                            try {
                              await requestPermission();
                              EasyLoading.dismiss();
                            } catch (e) {
                              EasyLoading.dismiss();
                            }
                          } else {
                            await setLocalNoti(false);
                            flutterLocalNotificationsPlugin.cancelAll();
                          }
                        },
                      )
                    ],
                  ),
                ),
                ClickWidget(
                    function: () {
                      AigraphyWidget.showDialogCustom(LocaleKeys.doYouWant.tr(),
                          LocaleKeys.youWillLose.tr(), context: context,
                          remove: () async {
                        Navigator.of(context).pop();
                        EasyLoading.show();
                        await AigraphyWidget.deleteUser();
                        await FirebaseAuth.instance.signOut();
                        EasyLoading.dismiss();
                        BotToast.showText(
                            text: LocaleKeys.youHaveDeleted.tr(),
                            textStyle: style7(color: white));
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.introduce, (route) => false);
                      });
                    },
                    child: item(LocaleKeys.deleteAccount.tr())),
              ],
            ),
          ),
          Text(
            LocaleKeys.about.tr(),
            style: style9(color: isabelline),
          ),
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: spaceCadet, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ClickWidget(
                    function: () {
                      launchUrlUlti(linkApp);
                    },
                    child: item(LocaleKeys.aboutAIGraphy.tr())),
                ClickWidget(
                  function: () {
                    Navigator.of(context).pushNamed(Routes.choose_language);
                  },
                  child: item(LocaleKeys.language.tr(),
                      trailing: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (context.watch<ListenLanguageBloc>().language !=
                              null)
                            Text(
                              context.watch<ListenLanguageBloc>().language!,
                              style:
                                  style8(color: isabelline, fontWeight: '400'),
                            ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Image.asset(
                              icKeyboardRight,
                              width: 24,
                              height: 24,
                              color: cultured,
                            ),
                          )
                        ],
                      )),
                ),
                ClickWidget(
                    function: () {
                      launchUrlUlti(linkPolicy);
                    },
                    child: item(LocaleKeys.securityTerms.tr())),
                ClickWidget(
                    function: () {
                      Navigator.of(context).pushNamed(Routes.add_fb);
                    },
                    child: item(LocaleKeys.leaveYourFeedback.tr())),
                ClickWidget(
                    function: () {
                      launchUrlUlti(linkPolicy);
                    },
                    child: item(LocaleKeys.subscriptionPolicy.tr())),
                ClickWidget(
                    function: () {
                      launchUrlUlti(linkDiscord);
                    },
                    child: item(LocaleKeys.discordCommunity.tr())),
                item(LocaleKeys.appVersion.tr(),
                    trailing: Text(
                      version,
                      style: style8(color: isabelline, fontWeight: '400'),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
