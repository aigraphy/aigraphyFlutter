import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../translations/export_lang.dart';
import '../bloc/histories/histories_bloc.dart';
import '../bloc/person/bloc_person.dart';
import '../bloc/rem_bg_img/bloc_rem_bg_img.dart';
import '../bloc/set_user_pro/set_user_pro_bloc.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import '../config_model/history_model.dart';
import '../config_router/name_router.dart';
import '../widget/appbar_custom.dart';
import '../widget/buy_more_slot.dart';
import '../widget/click_widget.dart';
import '../widget/go_pro.dart';
import '../widget/native_medium_ads.dart';
import '../widget/offer_first_time.dart';
import '../widget/opacity_widget.dart';
import 'history_detail.dart';
import 'iap_first_time.dart';

class Histories extends StatefulWidget {
  const Histories({super.key});

  @override
  State<Histories> createState() => _HistoriesState();
}

class _HistoriesState extends State<Histories>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  void _onScroll() {
    if (_isBottom) {
      context.read<HistoriesBloc>().add(HistoriesFetched(context: context));
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
    return context.watch<PersonBloc>().userModel != null
        ? ClickWidget(
            function: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: spaceCadet,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10)),
                ),
                builder: (context) {
                  return const BuyMoreSlot(openSlotHistory: true);
                },
              );
            },
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
                decoration: BoxDecoration(
                    color: spaceCadet, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Image.asset(ic_open_slot,
                        width: 32, height: 32, color: white),
                    const SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Buy 20 additional image storage slots with',
                        style: style9(color: white),
                        children: <TextSpan>[
                          TextSpan(
                              text:
                                  ' ${TOKEN_OPEN_HISTORY + 5 * (context.watch<PersonBloc>().userModel!.slotHistory - DEFAULT_SLOT_HISTORY)} Coins',
                              style: style6(color: yellow2)),
                        ],
                      ),
                    ),
                  ],
                )),
          )
        : const SizedBox();
  }

  Widget itemImage(HistoryModel requestModel) {
    return ClickWidget(
      function: () {
        context.read<RemBGImgBloc>().add(const ResetRemBGImg());
        Navigator.of(context).pushNamed(Routes.detail_history,
            arguments: HistoryDetail(
                idRequest: requestModel.id!,
                imageRes: requestModel.imageRes,
                imageRemoveBG: requestModel.imageRemoveBG?.imageRembg));
      },
      child: OpacityWidget(
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
        appBar: AppBarCustom(
          left: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text('AIGraphy', style: style6(color: white)),
          ),
          right: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              children: [
                const GoPro(showCoin: true, showPro: false),
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
        floatingActionButton: const OfferFirstTime(),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        body: Column(
          children: [
            if (!context.watch<SetUserPro>().state)
              ClickWidget(
                function: () {
                  Navigator.of(context).pushNamed(Routes.iap_first_time,
                      arguments: IAPFirstTime());
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: Theme.of(context).linerPimary),
                  child: Column(
                    children: [
                      Text(LocaleKeys.removeAds.tr(),
                          style: style5(color: white)),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(LocaleKeys.buyMoreCoinNow.tr(),
                            style: style9(color: gray900)),
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
                    context.read<HistoriesBloc>().add(ResetHistories());
                    context
                        .read<HistoriesBloc>()
                        .add(HistoriesFetched(context: context));
                  },
                ),
                child: ListView(
                  controller: _scrollController,
                  children: [
                    BlocBuilder<HistoriesBloc, HistoriesState>(
                      builder: (context, state) {
                        switch (state.status) {
                          case HistoriesStatus.failure:
                            return Center(
                                child: Text(
                                    LocaleKeys.failedToFetchRequests.tr(),
                                    style: style9(color: cultured)));
                          case HistoriesStatus.success:
                            if (state.requests.isEmpty) {
                              return Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(LocaleKeys.noRequests.tr(),
                                      style: style9(color: cultured)),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24),
                                    child: NativeMediumAds(),
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
                          case HistoriesStatus.initial:
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
