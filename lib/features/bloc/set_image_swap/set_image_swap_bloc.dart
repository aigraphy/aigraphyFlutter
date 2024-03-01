import 'package:bloc/bloc.dart';

import '../../../common/models/image_category_model.dart';

class SetImageSwapCubit extends Cubit<ImageCategoryModel?> {
  SetImageSwapCubit() : super(null);
  void setImageSwap(ImageCategoryModel imageCategoryModel) =>
      emit(imageCategoryModel);
  void reset() => emit(null);
}
