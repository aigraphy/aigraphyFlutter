import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../translations/export_lang.dart';
import '../bloc/person/bloc_person.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../config_router/name_router.dart';
import '../widget/click_widget.dart';
import '../widget_helper.dart';
import 'home.dart';

class CoinSuccess extends PageRouteBuilder<dynamic> {
  CoinSuccess({required this.coins})
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                const Scaffold());
  final int coins;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0.0, 0.0))
              .animate(controller!),
      child: Scaffold(
        body: CoinSuccessWidget(coins: coins),
      ),
    );
  }
}

class CoinSuccessWidget extends StatefulWidget {
  const CoinSuccessWidget({Key? key, required this.coins}) : super(key: key);
  final int coins;
  @override
  State<CoinSuccessWidget> createState() => _CoinSuccessWidgetState();
}

class _CoinSuccessWidgetState extends State<CoinSuccessWidget> {
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
              style: style3(color: white),
            ),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: LocaleKeys.yourBalanceAdd.tr(),
                style: style7(color: white),
                children: <TextSpan>[
                  TextSpan(
                    text:
                        ' ${formatCoin(context).format(widget.coins)} ${LocaleKeys.coins.tr()} ',
                    style: style6(color: white),
                  ),
                  TextSpan(
                    text: '${LocaleKeys.totalIs.tr()} ',
                    style: style6(color: white, fontWeight: '400'),
                  ),
                  TextSpan(
                    text:
                        '${formatCoin(context).format(context.watch<PersonBloc>().userModel!.coin)} Coins.',
                    style: style6(color: white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 48, left: 24, right: 24, bottom: 16),
              child: AigraphyWidget.typeButtonGradient(
                  context: context,
                  input: LocaleKeys.generateNow.tr(),
                  textColor: white,
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.home, (Route<dynamic> route) => false,
                        arguments: const Home());
                  }),
            )
          ],
        ),
        Positioned(
            right: 24,
            top: 64,
            child: ClickWidget(
              function: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.home, (Route<dynamic> route) => false,
                    arguments: const Home());
              },
              child: const Icon(
                Icons.close_rounded,
                size: 32,
                color: white,
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
