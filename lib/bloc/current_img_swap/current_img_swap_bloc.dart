import 'package:bloc/bloc.dart';

import '../../config_model/img_cate_model.dart';

class CurrentImgSwapCubit extends Cubit<ImgCateModel?> {
  CurrentImgSwapCubit() : super(null);
  void setImageSwap(ImgCateModel imageCategoryModel) =>
      emit(imageCategoryModel);
  void reset() => emit(null);
}
