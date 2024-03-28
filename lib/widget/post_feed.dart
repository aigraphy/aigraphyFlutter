import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../aigraphy_widget.dart';
import '../bloc/like_post/bloc_like_post.dart';
import '../bloc/list_posts/list_posts_bloc.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_model/post_model.dart';
import '../translations/export_lang.dart';
import 'click_widget.dart';
import 'text_gradient.dart';

class PostFeed extends StatefulWidget {
  const PostFeed({super.key, required this.post, required this.index});
  final PostModel post;
  final int index;

  @override
  State<PostFeed> createState() => _PostFeedState();
}

class _PostFeedState extends State<PostFeed> {
  final User _user = FirebaseAuth.instance.currentUser!;

  Widget option(String icon, int number) {
    return Row(
      children: [
        Image.asset(
          icon,
          width: 20,
          height: 20,
          color: isabelline,
        ),
        const SizedBox(
          width: 8,
        ),
        Text(
          '${formatNumber(number)}',
          style: style8(color: isabelline, fontWeight: '500'),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = AigraphyWidget.getWidth(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: CachedNetworkImage(
                    imageUrl: widget.post.person!.avatar,
                    fadeOutDuration: const Duration(milliseconds: 200),
                    fadeInDuration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.person!.name,
                      style: style5(color: white, fontWeight: '500'),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      formatDays(widget.post.published),
                      style: style10(color: isabelline),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (_user.uid == widget.post.userUuid)
                ClickWidget(
                    function: () {
                      showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: spaceCadet,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24))),
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 32),
                                  child: Image.asset(
                                    bin,
                                    width: 64,
                                    height: 64,
                                    color: white,
                                  ),
                                ),
                                TextGradient(
                                  'Delete Post',
                                  style: const TextStyle(
                                      fontSize: 32,
                                      height: 1,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'ClashGrotesk'),
                                  gradient: Theme.of(context).linerPimary,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 16),
                                  child: Text(
                                    LocaleKeys.itIsImpossible.tr(),
                                    textAlign: TextAlign.center,
                                    style: style7(color: white),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AigraphyWidget.buttonCustom(
                                          context: context,
                                          input: LocaleKeys.delete.tr(),
                                          onPressed: () {
                                            context.read<ListPostsBloc>().add(
                                                DeletePost(
                                                    id: widget.post.id!));
                                            Navigator.of(context).pop();
                                          },
                                          bgColor: red1,
                                          borderColor: red1,
                                          textColor: white),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: AigraphyWidget.buttonGradient(
                                          context: context,
                                          input: LocaleKeys.cancel.tr(),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          textColor: white),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24)
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Image.asset(ic_option, width: 24, height: 24))
            ],
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: widget.post.linkImage,
                  fadeOutDuration: const Duration(milliseconds: 200),
                  fadeInDuration: const Duration(milliseconds: 200),
                  key: ValueKey(widget.post.linkImage),
                  width: width,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
                left: 24,
                bottom: 8,
                child: Container(
                  width: 70,
                  height: 36,
                  decoration: BoxDecoration(
                      color: blackCoral,
                      borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BlocBuilder<LikePostBloc, LikePostState>(
                          builder: (context, state) {
                        if (state is LikePostLoaded) {
                          return ClickWidget(
                            function: () {
                              if (!state.likedPostIds
                                  .contains(widget.post.id)) {
                                context
                                    .read<ListPostsBloc>()
                                    .add(LikePost(index: widget.index));
                                context.read<LikePostBloc>().add(
                                    InsertLikePost(postId: widget.post.id!));
                              } else {
                                context
                                    .read<ListPostsBloc>()
                                    .add(UnLikePost(index: widget.index));
                                context.read<LikePostBloc>().add(
                                    DeleteLikePost(postId: widget.post.id!));
                              }
                            },
                            child: option(
                                state.likedPostIds.contains(widget.post.id)
                                    ? heartFill
                                    : heart,
                                widget.post.likes),
                          );
                        }
                        return option(heart, widget.post.likes);
                      }),
                    ],
                  ),
                ))
          ],
        ),
      ],
    );
  }
}
