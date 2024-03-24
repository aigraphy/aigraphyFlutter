import 'package:bloc/bloc.dart';

class CurrentCate extends Cubit<int> {
  CurrentCate() : super(0);
  void setIndex(int index) => emit(index);
  void reset() => emit(0);
}
