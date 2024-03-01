import 'package:bloc/bloc.dart';

class SetIndexBottomBar extends Cubit<int> {
  SetIndexBottomBar() : super(0);
  void setIndex(int index) => emit(index);
  void reset() => emit(0);
}
