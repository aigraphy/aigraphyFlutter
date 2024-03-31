import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';

import '../aigraphy_widget.dart';
import '../bloc/list_posts/list_posts_bloc.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_graphql/config_mutation.dart';
import '../config_graphql/graphql.dart';
import '../config_model/post_model.dart';
import '../translations/export_lang.dart';
import 'text_gradient.dart';

class ShareResult extends StatelessWidget {
  const ShareResult(
      {super.key, required this.historyId, required this.linkImage});
  final String linkImage;
  final int historyId;

  Future<PostModel?> insertPost(int historyId, String linkImage) async {
    EasyLoading.show();
    PostModel? postModel;
    final User _firebaseUser = FirebaseAuth.instance.currentUser!;
    final String? token = await _firebaseUser.getIdToken();
    await Graphql.initialize(token!)
        .value
        .mutate(MutationOptions(
            document: gql(ConfigMutation.insertPost()),
            variables: <String, dynamic>{
              'user_uuid': _firebaseUser.uid,
              'history_id': historyId,
              'link_image': linkImage,
              'published': DateTime.now().toUtc().toIso8601String()
            }))
        .then((value) {
      if (!value.hasException && value.data!['insert_Post_one'] != null) {
        postModel = PostModel.convertToObj(value.data!['insert_Post_one']);
      }
    });
    EasyLoading.dismiss();
    return postModel;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Image.asset(
              coin,
              width: 64,
              height: 64,
            ),
          ),
          TextGradient(
            'Share your result',
            style: const TextStyle(
                fontSize: 28,
                height: 1,
                fontWeight: FontWeight.w700,
                fontFamily: 'ClashGrotesk'),
            gradient: Theme.of(context).linerPimary,
          ),
          const SizedBox(height: 16),
          AigraphyWidget.buttonCustom(
              context: context,
              input: 'Share To New Feed +$TOKEN_SHARE',
              icon: coin,
              textColor: white,
              sizeAsset: 20,
              borderColor: white,
              borderRadius: 16,
              onPressed: () async {
                final post = await insertPost(historyId, linkImage);
                if (post != null) {
                  shareImgGetCoin(context);
                  BotToast.showText(
                      text: 'Share your image successful!!',
                      textStyle: style7(color: white));
                  context.read<ListPostsBloc>().add(InsertPost(post: post));
                  Navigator.of(context).pop();
                } else {
                  BotToast.showText(
                      text: LocaleKeys.someThingWentWrong.tr(),
                      textStyle: style7(color: white));
                }
              }),
          const SizedBox(height: 8),
          AigraphyWidget.buttonCustom(
              context: context,
              input: 'Share Social',
              icon: share,
              textColor: white,
              sizeAsset: 20,
              borderColor: white,
              borderRadius: 16,
              onPressed: () async {
                EasyLoading.show();
                await shareMultiUrl([linkImage], context);
                EasyLoading.dismiss();
                Navigator.of(context).pop();
              }),
        ],
      ),
    );
  }
}
