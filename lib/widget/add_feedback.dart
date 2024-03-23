import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_graphql/config_mutation.dart';
import '../config_graphql/graphql.dart';
import '../config_router/name_router.dart';
import 'appbar_custom.dart';
import 'click_widget.dart';
import 'text_gradient.dart';
import 'textfield_cpn.dart';
import 'unfocus_textfield.dart';

class AddFeedback extends StatefulWidget {
  const AddFeedback({Key? key}) : super(key: key);

  @override
  State<AddFeedback> createState() => _AddFeedbackState();
}

class _AddFeedbackState extends State<AddFeedback> {
  late TextEditingController controller;
  late FocusNode focusNode;

  final User userFB = FirebaseAuth.instance.currentUser!;

  Future<void> _insertFeedback(String content) async {
    final String? token = await userFB.getIdToken();
    await Graphql.initialize(token!).value.mutate(MutationOptions(
            document: gql(ConfigMutation.insertFb()),
            variables: {
              'content': content,
              'user_uuid': userFB.uid,
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
    return UnfocusTextField(
      child: Scaffold(
        appBar: AppBarCustom(
            left: ClickWidget(
          function: () {
            Navigator.of(context).pop();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Image.asset(
              icClose,
              width: 24,
              height: 24,
              color: white,
            ),
          ),
        )),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Image.asset(feedback, width: 100, height: 100)),
              const SizedBox(height: 24),
              TextGradient(
                LocaleKeys.leaveYourFeedback.tr(),
                style: const TextStyle(
                    fontSize: 30,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'ClashGrotesk'),
                gradient: Theme.of(context).linerPimary,
              ),
              const SizedBox(height: 24),
              TextFieldCpn(
                controller: controller,
                focusNode: focusNode,
                autoFocus: true,
                filled: true,
                fillColor: spaceCadet,
                hintText: LocaleKeys.putYourSuggestion.tr(),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              AigraphyWidget.typeButtonGradient(
                  context: context,
                  input: LocaleKeys.sentNow.tr(),
                  vertical: 16,
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      _insertFeedback(controller.text.trim());
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.result_fb);
                    } else {
                      BotToast.showText(
                          text: LocaleKeys.pleasePutYourSuggestion.tr());
                    }
                  },
                  bgColor: blue,
                  borderColor: blue,
                  textColor: white),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Or you can directly communicate with us via our ',
                  style: style9(color: white, fontWeight: '400'),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Instagram',
                      style: style8(
                          color: blue, fontWeight: '600', hasUnderLine: true),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final Uri _url = Uri.parse(linkInsta);
                          if (!await launchUrl(_url)) {
                            throw Exception('Could not launch $_url');
                          }
                        },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
