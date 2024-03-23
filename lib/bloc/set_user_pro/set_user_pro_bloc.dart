import 'package:bloc/bloc.dart';

class SetUserPro extends Cubit<bool> {
  SetUserPro() : super(false);
  void setIndex(bool isPro) => emit(isPro);
  void reset() => emit(false);
}
