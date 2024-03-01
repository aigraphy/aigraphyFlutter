import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/styles.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/route/routes.dart';
import '../../common/widget/animation_click.dart';
import '../../translations/export_lang.dart';
import 'bottom_bar.dart';

class TokenSuccess extends PageRouteBuilder<dynamic> {
  TokenSuccess({required this.tokens})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                const Scaffold());
  final int tokens;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0.0, 0.0))
              .animate(controller!),
      child: Scaffold(
        body: PremiumSuccessWidget(tokens: tokens),
      ),
    );
  }
}

class PremiumSuccessWidget extends StatefulWidget {
  const PremiumSuccessWidget({Key? key, required this.tokens})
      : super(key: key);
  final int tokens;
  @override
  State<PremiumSuccessWidget> createState() => _PremiumSuccessWidgetState();
}

class _PremiumSuccessWidgetState extends State<PremiumSuccessWidget> {
  late ConfettiController _controllerCenter;

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  Future<void> start() async {
    await Future<dynamic>.delayed(const Duration(seconds: 1));
    _controllerCenter.play();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 10));
    start();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Text(
              LocaleKeys.thankForPurchase.tr(),
              textAlign: TextAlign.center,
              style: title2(color: grey1100),
            ),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: LocaleKeys.yourBalanceAdd.tr(),
                style: body(color: grey1100),
                children: <TextSpan>[
                  TextSpan(
                    text:
                        ' ${formatToken(context).format(widget.tokens)} ${LocaleKeys.tokens.tr()} ',
                    style: headline(color: grey1100),
                  ),
                  TextSpan(
                    text: '${LocaleKeys.totalIs.tr()} ',
                    style: headline(color: grey1100, fontWeight: '400'),
                  ),
                  TextSpan(
                    text:
                        '${formatToken(context).format(context.watch<UserBloc>().userModel!.token)} Tokens.',
                    style: headline(color: grey1100),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 48, left: 24, right: 24, bottom: 16),
              child: AppWidget.typeButtonStartAction2(
                  context: context,
                  input: LocaleKeys.generateNow.tr(),
                  bgColor: primary,
                  textColor: grey1100,
                  borderColor: primary,
                  borderRadius: 12,
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.bottom_bar, (Route<dynamic> route) => false,
                        arguments: const BottomBar());
                  }),
            )
          ],
        ),
        Positioned(
            right: 24,
            top: 64,
            child: AnimationClick(
              function: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.bottom_bar, (Route<dynamic> route) => false,
                    arguments: const BottomBar());
              },
              child: const Icon(
                Icons.close_rounded,
                size: 32,
                color: grey1100,
              ),
            )),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controllerCenter,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: true,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
            createParticlePath: drawStar,
          ),
        ),
      ],
    );
  }
}
