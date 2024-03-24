import 'package:bloc/bloc.dart';

class CurrentBottomBar extends Cubit<int> {
  CurrentBottomBar() : super(0);
  void setIndex(int index) => emit(index);
  void reset() => emit(0);
}
