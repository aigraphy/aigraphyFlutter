import 'package:flutter/material.dart';

import '../../features/screen/bottom_bar.dart';
import '../../features/screen/detail_history.dart';
import '../../features/screen/full_image_category.dart';
import '../../features/screen/guide_face.dart';
import '../../features/screen/image_full_screen.dart';
import '../../features/screen/language.dart';
import '../../features/screen/menu.dart';
import '../../features/screen/onboarding.dart';
import '../../features/screen/price.dart';
import '../../features/screen/price_first_time.dart';
import '../../features/screen/price_one_time.dart';
import '../../features/screen/profile.dart';
import '../../features/screen/result_edit_image.dart';
import '../../features/screen/result_remove_bg.dart';
import '../../features/screen/step_one.dart';
import '../../features/screen/step_three.dart';
import '../../features/screen/step_two.dart';
import '../../features/screen/token_success.dart';
import '../../features/widget/web_view_privacy.dart';
import 'routes.dart';

mixin RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // / route catalog AIGraphy
      case Routes.onboarding:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const Onboarding(),
        );
      case Routes.bottom_bar:
        final args = settings.arguments as BottomBar;
        return MaterialPageRoute<dynamic>(
          builder: (context) => BottomBar(
            index: args.index,
          ),
        );
      case Routes.step_two:
        final args = settings.arguments as StepTwo;
        return MaterialPageRoute<dynamic>(
          builder: (context) => StepTwo(
            bytes: args.bytes,
            isImgCate: args.isImgCate,
            imageCate: args.imageCate,
            pathSource: args.pathSource,
          ),
        );
      case Routes.step_three:
        final args = settings.arguments as StepThree;
        return MaterialPageRoute<dynamic>(
          builder: (context) => StepThree(
              dstPath: args.dstPath,
              srcPath: args.srcPath,
              dstImage: args.dstImage,
              srcImage: args.srcImage,
              isSwapCate: args.isSwapCate),
        );
      case Routes.price:
        final args = settings.arguments as PriceScreen;
        return PriceScreen(
            showDaily: args.showDaily, currentIndex: args.currentIndex);
      case Routes.price_first_time:
        final args = settings.arguments as PriceFirstTime;
        return PriceFirstTime(currentIndex: args.currentIndex);
      case Routes.price_one_time:
        final args = settings.arguments as PriceOneTime;
        return PriceOneTime(currentIndex: args.currentIndex);
      case Routes.profile:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const Profile(),
        );
      case Routes.step_one:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const StepOne(),
        );
      case Routes.image_full:
        final args = settings.arguments as ImageFullScreen;
        return MaterialPageRoute<dynamic>(
          builder: (context) => ImageFullScreen(url: args.url),
        );
      case Routes.result_edit_image:
        final args = settings.arguments as ResultEditImage;
        return MaterialPageRoute<dynamic>(
          builder: (context) => ResultEditImage(
              imageEdit: args.imageEdit, requestId: args.requestId),
        );
      case Routes.result_remove_bg:
        final args = settings.arguments as ResultRemoveBg;
        return MaterialPageRoute<dynamic>(
          builder: (context) =>
              ResultRemoveBg(url: args.url, requestId: args.requestId),
        );
      case Routes.term:
        final args = settings.arguments as WebViewPrivacy;
        return MaterialPageRoute<dynamic>(
          builder: (context) => WebViewPrivacy(
            title: args.title,
            url: args.url,
          ),
        );
      case Routes.history:
        final args = settings.arguments as DetailHistory;
        return MaterialPageRoute<dynamic>(
          builder: (context) => DetailHistory(
            idRequest: args.idRequest,
            imageRes: args.imageRes,
            imageRemoveBG: args.imageRemoveBG,
          ),
        );
      case Routes.language:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const Language(),
        );
      case Routes.token_success:
        final args = settings.arguments as TokenSuccess;
        return TokenSuccess(tokens: args.tokens);
      case Routes.guide_face:
        return GuideFace();
      case Routes.menu:
        return MaterialPageRoute<dynamic>(
          builder: (context) => const MenuScreen(),
        );
      case Routes.full_image_cate:
        final args = settings.arguments as FullImageCategory;
        return MaterialPageRoute<dynamic>(
          builder: (context) => FullImageCategory(
            categoryModel: args.categoryModel,
          ),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute<dynamic>(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
