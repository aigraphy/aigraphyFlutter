import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:graphql/client.dart';
import '../../../../common/models/user_model.dart';
import '../../constant/helper.dart';
import '../../graphql/config.dart';
import '../../graphql/mutations.dart';
import '../../helper_ads/ads_lovin_utils.dart';
import 'bloc_user.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserLoading()) {
    on<GetUser>(_onGetUser);
    on<UpdateTokenUser>(_onUpdateTokenUser);
    on<UpdateCurrentCheckIn>(_onUpdateCurrentCheckIn);
    on<UpdateSlotRecentFace>(_onUpdateSlotRecentFace);
    on<UpdateSlotHistory>(_onUpdateSlotHistory);
    on<UpdateLanguageUser>(_onUpdateLanguageUser);
  }
  User firebaseUser = FirebaseAuth.instance.currentUser!;

  UserModel? userModel;

  Future<void> _onGetUser(GetUser event, Emitter<UserState> emit) async {
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

  Future<void> _onUpdateTokenUser(
      UpdateTokenUser event, Emitter<UserState> emit) async {
    final state = this.state;
    if (state is UserLoaded) {
      try {
        updateTokenUser(event.token);
        userModel = UserModel(
            id: userModel!.id,
            name: userModel!.name,
            email: userModel!.email,
            uuid: userModel!.uuid,
            dateCheckIn: userModel!.dateCheckIn,
            language: userModel!.language,
            slotRecentFace: userModel!.slotRecentFace,
            slotHistory: userModel!.slotHistory,
            avatar: userModel!.avatar,
            token: event.token);
        emit(UserLoaded(user: userModel!));
      } catch (_) {
        emit(UserError());
      }
    }
  }

  Future<void> _onUpdateCurrentCheckIn(
      UpdateCurrentCheckIn event, Emitter<UserState> emit) async {
    final state = this.state;
    if (state is UserLoaded) {
      try {
        final timeNow = await getTime();
        final date = DateTime(timeNow.year, timeNow.month, timeNow.day, 7, 58);
        updateCurrentCheckIn(date, userModel!.token + TOKEN_DAILY);
        userModel = UserModel(
            id: userModel!.id,
            name: userModel!.name,
            email: userModel!.email,
            uuid: userModel!.uuid,
            dateCheckIn: date,
            slotRecentFace: userModel!.slotRecentFace,
            slotHistory: userModel!.slotHistory,
            language: userModel!.language,
            avatar: userModel!.avatar,
            token: userModel!.token + TOKEN_DAILY);
        emit(UserLoaded(user: userModel!));
      } catch (_) {
        emit(UserError());
      }
    }
  }

  Future<void> _onUpdateSlotRecentFace(
      UpdateSlotRecentFace event, Emitter<UserState> emit) async {
    final state = this.state;
    if (state is UserLoaded) {
      try {
        EasyLoading.show();
        // AdLovinUtils().showAdIfReady();
        userModel = await updateSlotRecentFace(
            userModel!.slotRecentFace + 1,
            userModel!.token -
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
      UpdateSlotHistory event, Emitter<UserState> emit) async {
    final state = this.state;
    if (state is UserLoaded) {
      try {
        EasyLoading.show();
        // AdLovinUtils().showAdIfReady();
        userModel = await updateSlotHistory(
            userModel!.slotHistory + 20,
            userModel!.token -
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
      UpdateLanguageUser event, Emitter<UserState> emit) async {
    final state = this.state;
    if (state is UserLoaded) {
      emit(UserLoading());
      try {
        updateLanguageUser(event.language);
        userModel = UserModel(
            id: userModel!.id,
            name: userModel!.name,
            email: userModel!.email,
            uuid: userModel!.uuid,
            avatar: userModel!.avatar,
            dateCheckIn: userModel!.dateCheckIn,
            slotRecentFace: userModel!.slotRecentFace,
            slotHistory: userModel!.slotHistory,
            token: userModel!.token,
            language: event.language);
        emit(UserLoaded(user: userModel!));
      } catch (_) {
        emit(UserError());
      }
    }
  }

  Future<void> updateTokenUser(int tokens) async {
    final String? token = await firebaseUser.getIdToken();
    await Config.initializeClient(token!).value.mutate(MutationOptions(
            document: gql(Mutations.updateUser()),
            variables: <String, dynamic>{
              'uuid': firebaseUser.uid,
              'token': tokens,
            }));
  }

  Future<void> updateCurrentCheckIn(DateTime date, int tokens) async {
    final String? token = await firebaseUser.getIdToken();
    await Config.initializeClient(token!).value.mutate(MutationOptions(
            document: gql(Mutations.updateDateCheckIn()),
            variables: <String, dynamic>{
              'uuid': firebaseUser.uid,
              'date_checkin': date.toIso8601String(),
              'token': tokens,
            }));
  }

  Future<UserModel?> updateSlotRecentFace(
      int slotRecentFace, int tokens) async {
    final String? token = await firebaseUser.getIdToken();
    UserModel? userModel;
    await Config.initializeClient(token!)
        .value
        .mutate(MutationOptions(
            document: gql(Mutations.updateSlotRecentFace()),
            variables: <String, dynamic>{
              'uuid': firebaseUser.uid,
              'slot_recent_face': slotRecentFace,
              'token': tokens
            }))
        .then((value) {
      if (value.data!.isNotEmpty && value.data!['update_User'].isNotEmpty) {
        userModel = UserModel.fromJson(value.data!['update_User']);
      }
    });
    return userModel;
  }

  Future<UserModel?> updateSlotHistory(int slotHistory, int tokens) async {
    final String? token = await firebaseUser.getIdToken();
    UserModel? userModel;
    await Config.initializeClient(token!)
        .value
        .mutate(MutationOptions(
            document: gql(Mutations.updateSlotHistory()),
            variables: <String, dynamic>{
              'uuid': firebaseUser.uid,
              'slot_history': slotHistory,
              'token': tokens
            }))
        .then((value) {
      if (value.data!.isNotEmpty && value.data!['update_User'].isNotEmpty) {
        userModel = UserModel.fromJson(value.data!['update_User']);
      }
    });
    return userModel;
  }

  Future<void> updateLanguageUser(String language) async {
    final String? token = await firebaseUser.getIdToken();
    Config.initializeClient(token!).value.mutate(MutationOptions(
            document: gql(Mutations.updateLanguageUser()),
            variables: <String, dynamic>{
              'uuid': firebaseUser.uid,
              'language': language,
            }));
  }
}
