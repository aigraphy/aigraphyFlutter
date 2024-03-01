import 'package:bloc/bloc.dart';

class ShowGift extends Cubit<bool> {
  ShowGift() : super(false);
  void setShowGift(bool show) => emit(show);
  void reset() => emit(false);
}
