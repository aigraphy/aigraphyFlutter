import 'package:bloc/bloc.dart';

class SetIndexCategory extends Cubit<int> {
  SetIndexCategory() : super(0);
  void setIndex(int index) => emit(index);
  void reset() => emit(0);
}
