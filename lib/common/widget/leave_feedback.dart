import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/widget_support.dart';
import '../../translations/export_lang.dart';
import '../constant/colors.dart';
import '../constant/helper.dart';
import '../constant/images.dart';
import '../constant/styles.dart';
import '../graphql/config.dart';
import '../graphql/mutations.dart';
import 'animation_click.dart';
import 'gradient_text.dart';
import 'textfield.dart';
import 'thank_feedback.dart';

class LeaveFeedback extends StatefulWidget {
  const LeaveFeedback({Key? key}) : super(key: key);

  @override
  State<LeaveFeedback> createState() => _LeaveFeedbackState();
}

class _LeaveFeedbackState extends State<LeaveFeedback> {
  late TextEditingController controller;
  late FocusNode focusNode;

  final User _firebaseUser = FirebaseAuth.instance.currentUser!;

  Future<void> _insertFeedback(String content) async {
    final String? token = await _firebaseUser.getIdToken();
    await Config.initializeClient(token!).value.mutate(MutationOptions(
            document: gql(Mutations.insertFeedback()),
            variables: {
              'content': content,
              'user_uuid': _firebaseUser.uid,
            }));
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          color: grey100,
                          borderRadius: BorderRadius.circular(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                              child: Image.asset(feedback,
                                  width: 100, height: 100)),
                          const SizedBox(height: 24),
                          GradientText(
                            LocaleKeys.leaveYourFeedback.tr(),
                            style: const TextStyle(
                                fontSize: 30,
                                height: 1,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'SpaceGrotesk'),
                            gradient: Theme.of(context).linearGradientCustome,
                          ),
                          const SizedBox(height: 24),
                          TextFieldCpn(
                            controller: controller,
                            focusNode: focusNode,
                            autoFocus: true,
                            filled: true,
                            fillColor: grey200,
                            hintText: LocaleKeys.putYourSuggestion.tr(),
                            maxLines: 4,
                          ),
                          const SizedBox(height: 16),
                          AppWidget.typeButtonStartAction(
                              context: context,
                              input: LocaleKeys.sentNow.tr(),
                              borderRadius: 12,
                              vertical: 16,
                              onPressed: () {
                                if (controller.text.trim().isNotEmpty) {
                                  _insertFeedback(controller.text.trim());
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const ThankFeedback();
                                    },
                                  );
                                } else {
                                  BotToast.showText(
                                      text: LocaleKeys.pleasePutYourSuggestion
                                          .tr());
                                }
                              },
                              bgColor: primary,
                              borderColor: primary,
                              textColor: grey1100),
                          const SizedBox(height: 16),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text:
                                  'Or you can directly communicate with us via our ',
                              style:
                                  subhead(color: grey1100, fontWeight: '400'),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Facebook fanpage',
                                  style: callout(
                                      color: blueLight,
                                      fontWeight: '600',
                                      hasUnderLine: true),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      final Uri _url = Uri.parse(linkFacebook);
                                      if (!await launchUrl(_url)) {
                                        throw Exception(
                                            'Could not launch $_url');
                                      }
                                    },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                  left: 32,
                  top: 32,
                  child: AnimationClick(
                    function: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: grey200,
                          borderRadius: BorderRadius.circular(48)),
                      child: Image.asset(
                        icClose,
                        width: 20,
                        height: 20,
                        color: grey600,
                      ),
                    ),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
