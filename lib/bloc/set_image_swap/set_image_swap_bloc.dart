import 'package:bloc/bloc.dart';

import '../../config_model/img_cate_model.dart';

class SetImageSwapCubit extends Cubit<ImgCateModel?> {
  SetImageSwapCubit() : super(null);
  void setImageSwap(ImgCateModel imageCategoryModel) =>
      emit(imageCategoryModel);
  void reset() => emit(null);
}
