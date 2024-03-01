import 'package:bloc/bloc.dart';

class SliderCubit extends Cubit<int> {
  SliderCubit() : super(0);
  void swipeLeft() => emit(state - 1);
  void swipeRight() => emit(state + 1);
  void swipeReset() => emit(0);
}
