import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../common/widget/animation_click.dart';
import '../../common/bloc/list_requests/list_requests_bloc.dart';
import '../../common/bloc/set_user_pro/set_user_pro_bloc.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/images.dart';
import '../../common/constant/styles.dart';
import '../../common/models/request_model.dart';
import '../../common/route/routes.dart';
import '../../common/widget/ads_native_applovin_medium.dart';
import '../../common/widget/app_bar_cpn.dart';
import '../../common/widget/open_slot.dart';
import '../../translations/export_lang.dart';
import '../bloc/remove_bg_image/bloc_remove_bg_image.dart';
import '../widget/gift_widget.dart';
import '../widget/go_pro.dart';
import '../widget/image_opacity.dart';
import 'detail_history.dart';
import 'price_first_time.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  void _onScroll() {
    if (_isBottom) {
      context
          .read<ListRequestsBloc>()
          .add(ListRequestsFetched(context: context));
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

  Widget buySlot() {
    return context.watch<UserBloc>().userModel != null
        ? AnimationClick(
            function: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const OpenSlot(openSlotHistory: true);
                },
              );
            },
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
                decoration: BoxDecoration(
                    color: grey300, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Image.asset(lock, width: 32, height: 32, color: grey1100),
                    const SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Buy 20 additional image storage slots with',
                        style: subhead(color: grey1100),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  ' ${TOKEN_OPEN_HISTORY + 5 * (context.watch<UserBloc>().userModel!.slotHistory - DEFAULT_SLOT_HISTORY)} Tokens',
                              style: headline(color: corn2)),
                        ],
                      ),
                    ),
                  ],
                )),
          )
        : const SizedBox();
  }

  Widget itemImage(RequestModel requestModel) {
    return AnimationClick(
      function: () {
        context.read<RemoveBGImageBloc>().add(const ResetRemoveBGImage());
        Navigator.of(context).pushNamed(Routes.history,
            arguments: DetailHistory(
                idRequest: requestModel.id!,
                imageRes: requestModel.imageRes,
                imageRemoveBG: requestModel.imageRemoveBG?.imageRembg));
      },
      child: ImageOpacity(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: requestModel.imageRes,
              fadeOutDuration: const Duration(milliseconds: 200),
              fadeInDuration: const Duration(milliseconds: 200),
              fit: BoxFit.cover,
            )),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBarCpn(
          left: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text('AIGraphy', style: headline(color: grey1100)),
          ),
          right: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              children: [
                const GoPro(showCoin: true, showPro: false),
                const SizedBox(width: 12),
                AnimationClick(
                  function: () {
                    Navigator.of(context).pushNamed(Routes.menu);
                  },
                  child: Image.asset(
                    circles_four,
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: const GiftWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        body: Column(
          children: [
            if (!context.watch<SetUserPro>().state)
              AnimationClick(
                function: () {
                  Navigator.of(context).pushNamed(Routes.price_first_time,
                      arguments: PriceFirstTime());
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: Theme.of(context).colorLinear),
                  child: Column(
                    children: [
                      Text(LocaleKeys.removeAds.tr(),
                          style: title4(color: grey1100)),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(LocaleKeys.buyMoreCoinNow.tr(),
                            style: subhead(color: grey900)),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GoPro(
                              text: LocaleKeys.goProNow.tr(), showCoin: false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => Future.sync(
                  () {
                    context.read<ListRequestsBloc>().add(ResetListRequests());
                    context
                        .read<ListRequestsBloc>()
                        .add(ListRequestsFetched(context: context));
                  },
                ),
                child: ListView(
                  controller: _scrollController,
                  children: [
                    BlocBuilder<ListRequestsBloc, ListRequestsState>(
                      builder: (context, state) {
                        switch (state.status) {
                          case ListRequestsStatus.failure:
                            return Center(
                                child: Text(
                                    LocaleKeys.failedToFetchRequests.tr(),
                                    style: subhead(color: grey800)));
                          case ListRequestsStatus.success:
                            if (state.requests.isEmpty) {
                              return Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(LocaleKeys.noRequests.tr(),
                                      style: subhead(color: grey800)),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24),
                                    child: AdsNativeApplovinMedium(),
                                  )
                                ],
                              ));
                            }
                            return MasonryGridView.count(
                                crossAxisCount: 2,
                                padding: const EdgeInsets.only(
                                    left: 24, right: 24, top: 8, bottom: 80),
                                shrinkWrap: true,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.hasReachedMax
                                    ? state.requests.length + 1
                                    : state.requests.length + 2,
                                itemBuilder: (context, ind) {
                                  final int index = ind < 1 ? ind : (ind - 1);
                                  return index >= state.requests.length
                                      ? const Center(
                                          child: CupertinoActivityIndicator())
                                      : ind == 0
                                          ? buySlot()
                                          : itemImage(state.requests[index]);
                                });
                          case ListRequestsStatus.initial:
                            return const Center(
                                child: CupertinoActivityIndicator());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
