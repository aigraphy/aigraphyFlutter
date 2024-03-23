import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';

import '../../config/config_helper.dart';
import '../../config_graphql/config_mutation.dart';
import '../../config_graphql/graphql.dart';
import '../../config_model/person_model.dart';
import 'bloc_person.dart';

class PersonBloc extends Bloc<PersonEvent, PersonState> {
  PersonBloc() : super(UserLoading()) {
    on<GetUser>(_onGetUser);
    on<UpdateCoinUser>(_onUpdateCoinUser);
    on<UpdateCurrentCheckIn>(_onUpdateCurrentCheckIn);
    on<UpdateSlotRecentFace>(_onUpdateSlotRecentFace);
    on<UpdateSlotHistory>(_onUpdateSlotHistory);
    on<UpdateLanguageUser>(_onUpdateLanguageUser);
  }
  User userFB = FirebaseAuth.instance.currentUser!;

  PersonModel? userModel;

  Future<void> _onGetUser(GetUser event, Emitter<PersonState> emit) async {
    emit(UserLoading());
    try {
      userModel = event.userModel;
      if (userModel != null) {
        emit(UserLoaded(user: userModel!));
      }
    } catch (_) {
      emit(UserError());
    }
  }

  Future<void> _onUpdateCoinUser(
      UpdateCoinUser event, Emitter<PersonState> emit) async {
    final state = this.state;
    if (state is UserLoaded) {
      try {
        updateCoinUser(event.coin);
        userModel = PersonModel(
            id: userModel!.id,
            name: userModel!.name,
            email: userModel!.email,
            uuid: userModel!.uuid,
            dateCheckIn: userModel!.dateCheckIn,
            language: userModel!.language,
            slotRecentFace: userModel!.slotRecentFace,
            slotHistory: userModel!.slotHistory,
            avatar: userModel!.avatar,
            coin: event.coin);
        emit(UserLoaded(user: userModel!));
      } catch (_) {
        emit(UserError());
      }
    }
  }

  Future<void> _onUpdateCurrentCheckIn(
      UpdateCurrentCheckIn event, Emitter<PersonState> emit) async {
    final state = this.state;
    if (state is UserLoaded) {
      try {
        final timeNow = await getTime();
        final date = DateTime(timeNow.year, timeNow.month, timeNow.day, 7, 58);
        updateCurrentCheckIn(date, userModel!.coin + TOKEN_DAILY);
        userModel = PersonModel(
            id: userModel!.id,
            name: userModel!.name,
            email: userModel!.email,
            uuid: userModel!.uuid,
            dateCheckIn: date,
            slotRecentFace: userModel!.slotRecentFace,
            slotHistory: userModel!.slotHistory,
            language: userModel!.language,
            avatar: userModel!.avatar,
            coin: userModel!.coin + TOKEN_DAILY);
        emit(UserLoaded(user: userModel!));
      } catch (_) {
        emit(UserError());
      }
    }
  }

  Future<void> _onUpdateSlotRecentFace(
      UpdateSlotRecentFace event, Emitter<PersonState> emit) async {
    final state = this.state;
    if (state is UserLoaded) {
      try {
        EasyLoading.show();
        userModel = await updateSlotRecentFace(
            userModel!.slotRecentFace + 1,
            userModel!.coin -
                (TOKEN_OPEN_SLOT +
                    20 * (userModel!.slotRecentFace - DEFAULT_SLOT)));
        EasyLoading.dismiss();
        emit(UserLoaded(user: userModel!));
      } catch (_) {
        EasyLoading.dismiss();
        emit(UserError());
      }
    }
  }

  Future<void> _onUpdateSlotHistory(
      UpdateSlotHistory event, Emitter<PersonState> emit) async {
    final state = this.state;
    if (state is UserLoaded) {
      try {
        EasyLoading.show();
        userModel = await updateSlotHistory(
            userModel!.slotHistory + 20,
            userModel!.coin -
                (TOKEN_OPEN_HISTORY +
                    5 * (userModel!.slotHistory - DEFAULT_SLOT_HISTORY)));
        EasyLoading.dismiss();
        emit(UserLoaded(user: userModel!));
      } catch (_) {
        EasyLoading.dismiss();
        emit(UserError());
      }
    }
  }

  Future<void> _onUpdateLanguageUser(
      UpdateLanguageUser event, Emitter<PersonState> emit) async {
    final state = this.state;
    if (state is UserLoaded) {
      emit(UserLoading());
      try {
        updateLanguageUser(event.language);
        userModel = PersonModel(
            id: userModel!.id,
            name: userModel!.name,
            email: userModel!.email,
            uuid: userModel!.uuid,
            avatar: userModel!.avatar,
            dateCheckIn: userModel!.dateCheckIn,
            slotRecentFace: userModel!.slotRecentFace,
            slotHistory: userModel!.slotHistory,
            coin: userModel!.coin,
            language: event.language);
        emit(UserLoaded(user: userModel!));
      } catch (_) {
        emit(UserError());
      }
    }
  }

  Future<void> updateCoinUser(int coins) async {
    final String? coin = await userFB.getIdToken();
    await Graphql.initialize(coin!).value.mutate(MutationOptions(
            document: gql(ConfigMutation.updatePerson()),
            variables: <String, dynamic>{
              'uuid': userFB.uid,
              'token': coins,
            }));
  }

  Future<void> updateCurrentCheckIn(DateTime date, int coins) async {
    final String? coin = await userFB.getIdToken();
    await Graphql.initialize(coin!).value.mutate(MutationOptions(
            document: gql(ConfigMutation.updateDateCheckIn()),
            variables: <String, dynamic>{
              'uuid': userFB.uid,
              'date_checkin': date.toIso8601String(),
              'token': coins,
            }));
  }

  Future<PersonModel?> updateSlotRecentFace(
      int slotRecentFace, int coins) async {
    final String? coin = await userFB.getIdToken();
    PersonModel? userModel;
    await Graphql.initialize(coin!)
        .value
        .mutate(MutationOptions(
            document: gql(ConfigMutation.updateSlotFace()),
            variables: <String, dynamic>{
              'uuid': userFB.uid,
              'slot_recent_face': slotRecentFace,
              'token': coins
            }))
        .then((value) {
      if (value.data!.isNotEmpty && value.data!['update_User'].isNotEmpty) {
        userModel = PersonModel.convertToObj(value.data!['update_User']);
      }
    });
    return userModel;
  }

  Future<PersonModel?> updateSlotHistory(int slotHistory, int coins) async {
    final String? coin = await userFB.getIdToken();
    PersonModel? userModel;
    await Graphql.initialize(coin!)
        .value
        .mutate(MutationOptions(
            document: gql(ConfigMutation.updateSlotHistory()),
            variables: <String, dynamic>{
              'uuid': userFB.uid,
              'slot_history': slotHistory,
              'token': coins
            }))
        .then((value) {
      if (value.data!.isNotEmpty && value.data!['update_User'].isNotEmpty) {
        userModel = PersonModel.convertToObj(value.data!['update_User']);
      }
    });
    return userModel;
  }

  Future<void> updateLanguageUser(String language) async {
    final String? coin = await userFB.getIdToken();
    Graphql.initialize(coin!).value.mutate(MutationOptions(
            document: gql(ConfigMutation.updateLanguagePerson()),
            variables: <String, dynamic>{
              'uuid': userFB.uid,
              'language': language,
            }));
  }
}
