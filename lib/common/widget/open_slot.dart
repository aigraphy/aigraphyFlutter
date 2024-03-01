import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/widget_support.dart';
import '../../features/widget/not_enough_token.dart';
import '../../translations/export_lang.dart';
import '../bloc/user/bloc_user.dart';
import '../constant/colors.dart';
import '../constant/helper.dart';
import '../constant/images.dart';
import '../constant/styles.dart';
import 'animation_click.dart';

class OpenSlot extends StatefulWidget {
  const OpenSlot({Key? key, this.openSlotHistory = false}) : super(key: key);
  final bool openSlotHistory;

  @override
  State<OpenSlot> createState() => _CheckInWidgetState();
}

class _CheckInWidgetState extends State<OpenSlot> {
  @override
  Widget build(BuildContext context) {
    final userModel = context.read<UserBloc>().userModel!;
    final tokenLost = widget.openSlotHistory
        ? (TOKEN_OPEN_HISTORY +
            5 * (userModel.slotHistory - DEFAULT_SLOT_HISTORY))
        : (TOKEN_OPEN_SLOT + 20 * (userModel.slotRecentFace - DEFAULT_SLOT));
    final slot = widget.openSlotHistory
        ? (context.watch<UserBloc>().userModel?.slotHistory ??
            DEFAULT_SLOT_HISTORY)
        : (context.watch<UserBloc>().userModel?.slotRecentFace ?? DEFAULT_SLOT);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
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
                        color: grey200,
                        borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                            child:
                                Image.asset(success, width: 150, height: 150)),
                        const SizedBox(height: 24),
                        Text(
                            '${LocaleKeys.youCanSave.tr()} $slot ${widget.openSlotHistory ? LocaleKeys.history.tr() : LocaleKeys.faces.tr()}.',
                            textAlign: TextAlign.start,
                            style: body(color: grey1100)),
                        RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            text: LocaleKeys.doYouWantToBuy.tr(),
                            style: body(color: grey1100),
                            children: <TextSpan>[
                              TextSpan(
                                text: ' ${widget.openSlotHistory ? 20 : 1} ',
                                style: headline(color: grey1100),
                              ),
                              TextSpan(
                                text: LocaleKeys.moreSlotWith.tr(),
                                style: body(color: grey1100),
                              ),
                              TextSpan(
                                text: ' $tokenLost ',
                                style: headline(color: grey1100),
                              ),
                              TextSpan(
                                text: widget.openSlotHistory
                                    ? '${LocaleKeys.tokens.tr()} ?'
                                    : LocaleKeys.weWillReplace.tr(),
                                style: body(color: grey1100),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppWidget.typeButtonStartAction(
                            context: context,
                            input: LocaleKeys.openSlotNow.tr(),
                            borderRadius: 12,
                            vertical: 16,
                            onPressed: () {
                              if (userModel.token >= tokenLost) {
                                if (widget.openSlotHistory) {
                                  context
                                      .read<UserBloc>()
                                      .add(UpdateSlotHistory());
                                } else {
                                  context
                                      .read<UserBloc>()
                                      .add(UpdateSlotRecentFace());
                                }
                                Navigator.of(context).pop();
                              } else {
                                Navigator.of(context).pop();
                                showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const NotEnoughToken();
                                  },
                                );
                              }
                            },
                            bgColor: primary,
                            borderColor: primary,
                            textColor: grey1100),
                        const SizedBox(height: 16),
                        AppWidget.typeButtonStartAction(
                            context: context,
                            input: LocaleKeys.cancel.tr(),
                            borderRadius: 12,
                            vertical: 16,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            bgColor: grey100,
                            borderColor: grey100,
                            textColor: grey600),
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
    );
  }
}
