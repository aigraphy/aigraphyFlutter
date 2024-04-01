import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/list_posts/list_posts_bloc.dart';
import '../bloc/pageview/pageview_bloc.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_image.dart';
import '../config_router/name_router.dart';
import '../widget/appbar_custom.dart';
import '../widget/click_widget.dart';
import '../widget/go_pro.dart';
import '../widget/post_feed.dart';

class NewFeed extends StatefulWidget {
  const NewFeed({super.key});

  @override
  State<NewFeed> createState() => _NewFeedState();
}

class _NewFeedState extends State<NewFeed> {
  final _scrollController = ScrollController();

  void _onScroll() {
    if (_isBottom) {
      context.read<ListPostsBloc>().add(ListPostsFetched());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) {
      return false;
    }
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarCustom(
          left: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              'New Feed',
              style: style5(color: white),
            ),
          ),
          right: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              children: [
                const GoPro(),
                const SizedBox(width: 12),
                ClickWidget(
                  function: () {
                    Navigator.of(context).pushNamed(Routes.settings);
                  },
                  child: Image.asset(
                    setting,
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<ListPostsBloc>().add(ResetListPosts());
            context.read<ListPostsBloc>().add(ListPostsFetched());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<ListPostsBloc, ListPostsState>(
                    builder: (context, state) {
                      switch (state.status) {
                        case ListPostsStatus.failure:
                          return Center(
                              child: Text('Failed to fetch posts',
                                  style: style6(color: cultured)));
                        case ListPostsStatus.success:
                          if (state.posts.isEmpty) {
                            return Center(
                                child: Text('No posts found',
                                    style: style6(color: cultured)));
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (BuildContext context, int index) {
                              return index >= state.posts.length
                                  ? const Center(
                                      child: CupertinoActivityIndicator())
                                  : BlocProvider<PageViewCubit>(
                                      create: (context) => PageViewCubit(),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 24),
                                        child: PostFeed(
                                          post: state.posts[index],
                                          index: index,
                                        ),
                                      ));
                            },
                            itemCount: state.hasReachedMax
                                ? state.posts.length
                                : state.posts.length + 1,
                            controller: _scrollController,
                          );
                        case ListPostsStatus.initial:
                          return const Center(
                              child: CupertinoActivityIndicator());
                      }
                    },
                  ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ));
  }
}
