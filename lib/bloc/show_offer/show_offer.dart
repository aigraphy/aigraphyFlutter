import 'package:bloc/bloc.dart';

class ShowOffer extends Cubit<bool> {
  ShowOffer() : super(false);
  void setShowOffer(bool show) => emit(show);
  void reset() => emit(false);
}
