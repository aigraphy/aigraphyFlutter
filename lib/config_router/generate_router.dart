import 'package:flutter/material.dart';

import '../config/config_helper.dart';
import '../screen/choose_language.dart';
import '../screen/coin_success.dart';
import '../screen/final_result.dart';
import '../screen/full_img_cate.dart';
import '../screen/full_img_screen.dart';
import '../screen/guide_face.dart';
import '../screen/histories.dart';
import '../screen/history_detail.dart';
import '../screen/home.dart';
import '../screen/iap_first_time.dart';
import '../screen/in_app_purchase.dart';
import '../screen/introduce.dart';
import '../screen/res_edit_local_img.dart';
import '../screen/res_remove_bg_local_img.dart';
import '../screen/select_face.dart';
import '../screen/setting.dart';
import '../widget/add_feedback.dart';
import '../widget/privacy.dart';
import '../widget/result_feedback.dart';
import 'name_router.dart';

mixin GeneratorRouter {
  static Route<dynamic> generateRouter(RouteSettings st) {
    switch (st.name) {
      case Routes.introduce:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const Introduce(),
        );
      case Routes.policy:
        final args = st.arguments as Privacy;
        return MaterialPageRoute<dynamic>(
          builder: (_) => Privacy(
            title: args.title,
            url: args.url,
          ),
        );
      case Routes.home:
        final args = st.arguments as Home;
        return MaterialPageRoute<dynamic>(
          builder: (_) => Home(
            index: args.index,
          ),
        );
      case Routes.select_face:
        final args = st.arguments as SelectFace;
        return MaterialPageRoute<dynamic>(
          builder: (_) => SelectFace(
            bytes: args.bytes,
            isImgCate: args.isImgCate,
            imageCate: args.imageCate,
            pathSource: args.pathSource,
          ),
        );
      case Routes.final_result:
        final args = st.arguments as FinalResult;
        return MaterialPageRoute<dynamic>(
          builder: (_) => FinalResult(
              dstPath: args.dstPath,
              dstImage: args.dstImage,
              srcPath: args.srcPath,
              srcImage: args.srcImage,
              isSwapCate: args.isSwapCate),
        );
      case Routes.histories:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const Histories(),
        );
      case Routes.detail_history:
        final args = st.arguments as HistoryDetail;
        return MaterialPageRoute<dynamic>(
          builder: (_) => HistoryDetail(
            idRequest: args.idRequest,
            imageRes: args.imageRes,
            imageRemoveBG: args.imageRemoveBG,
          ),
        );
      case Routes.settings:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const Setting(),
        );
      case Routes.choose_language:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const ChooseLanguage(),
        );
      case Routes.full_img_cate:
        final args = st.arguments as FullImgCate;
        return MaterialPageRoute<dynamic>(
          builder: (_) => FullImgCate(
            categoryModel: args.categoryModel,
          ),
        );
      case Routes.in_app_purchase:
        final args = st.arguments as InAppPurchase;
        return InAppPurchase(
            showDaily: args.showDaily, currentIndex: args.currentIndex);
      case Routes.iap_first_time:
        final args = st.arguments as IAPFirstTime;
        return IAPFirstTime(currentIndex: args.currentIndex);
      case Routes.full_img_screen:
        final args = st.arguments as FullImgScreen;
        return MaterialPageRoute<dynamic>(
          builder: (_) => FullImgScreen(url: args.url),
        );
      case Routes.coin_success:
        final args = st.arguments as CoinSuccess;
        return CoinSuccess(coins: args.coins);
      case Routes.guide_face:
        return GuideFace();
      case Routes.res_edit_local_img:
        final args = st.arguments as ResEditLocalImg;
        return MaterialPageRoute<dynamic>(
          builder: (_) => ResEditLocalImg(
              imageEdit: args.imageEdit, requestId: args.requestId),
        );
      case Routes.res_remove_bg_local_img:
        final args = st.arguments as ResRemBgLocalImg;
        return MaterialPageRoute<dynamic>(
          builder: (_) =>
              ResRemBgLocalImg(url: args.url, requestId: args.requestId),
        );
      case Routes.add_fb:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const AddFeedback(),
        );
      case Routes.result_fb:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const ResultFeedback(),
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
          child: Text(SOMETHING_WENT_WRONG),
        ),
      );
    });
  }
}
