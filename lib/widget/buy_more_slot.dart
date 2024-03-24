import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../translations/export_lang.dart';
import '../aigraphy_widget.dart';
import '../bloc/person/bloc_person.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config/config_image.dart';
import 'get_more_coin.dart';

class BuyMoreSlot extends StatefulWidget {
  const BuyMoreSlot({Key? key, this.openSlotHistory = false}) : super(key: key);
  final bool openSlotHistory;

  @override
  State<BuyMoreSlot> createState() => _CheckInWidgetState();
}

class _CheckInWidgetState extends State<BuyMoreSlot> {
  @override
  Widget build(BuildContext context) {
    final userModel = context.read<PersonBloc>().userModel!;
    final coinLost = widget.openSlotHistory
        ? (TOKEN_OPEN_HISTORY +
            5 * (userModel.slotHistory - DEFAULT_SLOT_HISTORY))
        : (TOKEN_OPEN_SLOT + 20 * (userModel.slotFaces - DEFAULT_SLOT));
    final slot = widget.openSlotHistory
        ? (context.watch<PersonBloc>().userModel?.slotHistory ??
            DEFAULT_SLOT_HISTORY)
        : (context.watch<PersonBloc>().userModel?.slotFaces ?? DEFAULT_SLOT);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Image.asset(success, height: 120)),
              const SizedBox(height: 24),
              Text(
                  '${LocaleKeys.youCanSave.tr()} $slot ${widget.openSlotHistory ? LocaleKeys.history.tr() : LocaleKeys.faces.tr()}.',
                  textAlign: TextAlign.center,
                  style: style7(color: white)),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: LocaleKeys.doYouWantToBuy.tr(),
                  style: style7(color: white),
                  children: <TextSpan>[
                    TextSpan(
                      text: ' ${widget.openSlotHistory ? 20 : 1} ',
                      style: style6(color: white),
                    ),
                    TextSpan(
                      text: LocaleKeys.moreSlotWith.tr(),
                      style: style7(color: white),
                    ),
                    TextSpan(
                      text: ' $coinLost ',
                      style: style6(color: white),
                    ),
                    TextSpan(
                      text: widget.openSlotHistory
                          ? '${LocaleKeys.coins.tr()} ?'
                          : LocaleKeys.weWillReplace.tr(),
                      style: style7(color: white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AigraphyWidget.typeButtonGradient(
                  context: context,
                  input: LocaleKeys.openSlotNow.tr(),
                  vertical: 16,
                  onPressed: () {
                    if (userModel.coin >= coinLost) {
                      if (widget.openSlotHistory) {
                        context.read<PersonBloc>().add(UpdateSlotHistory());
                      } else {
                        context.read<PersonBloc>().add(UpdateSlotFace());
                      }
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop();
                      showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: spaceCadet,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10)),
                        ),
                        builder: (BuildContext context) {
                          return const GetMoreCoin();
                        },
                      );
                    }
                  },
                  textColor: white),
              const SizedBox(height: 16),
              AigraphyWidget.buttonCustom(
                  context: context,
                  input: LocaleKeys.cancel.tr(),
                  vertical: 16,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  bgColor: blackCoral,
                  borderColor: blackCoral,
                  textColor: white),
            ],
          ),
        ],
      ),
    );
  }
}
