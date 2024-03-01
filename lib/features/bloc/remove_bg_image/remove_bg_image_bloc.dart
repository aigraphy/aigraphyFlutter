import 'dart:typed_data';

import 'package:aigraphy_flutter/common/constant/colors.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import '../../../common/bloc/user/bloc_user.dart';
import '../../../common/constant/error_code.dart';
import '../../../common/constant/helper.dart';
import '../../../common/constant/styles.dart';
import '../../../common/util/upload_image.dart';
import 'bloc_remove_bg_image.dart';

class RemoveBGImageBloc extends Bloc<RemoveBGImageEvent, RemoveBGImageState> {
  RemoveBGImageBloc() : super(RemoveBGImageLoading()) {
    on<InitialRemoveBGImage>(_onInitialRemoveBGImage);
    on<RemoveBGImage>(_onRemoveBGImage);
    on<ResetRemoveBGImage>(_onResetRemoveBGImage);
  }

  User firebaseUser = FirebaseAuth.instance.currentUser!;
  Uint8List? result;
  String? url;
  String? errorText;

  Future<void> _onInitialRemoveBGImage(
      InitialRemoveBGImage event, Emitter<RemoveBGImageState> emit) async {
    emit(RemoveBGImageLoading());
    try {
      result = null;
      url = null;
      errorText = null;
      result =
          await removeBGImage(event.context, event.link, option: event.option);
      if (result != null) {
        url = await uploadImage(result, event.requestId, event.context);
        if (url != null) {
          final UserBloc userBloc = event.context.read<UserBloc>();
          userBloc.add(
              UpdateTokenUser(userBloc.userModel!.token - TOKEN_REMOVE_BG));
          EasyLoading.dismiss();
          emit(RemoveBGImageLoaded(imageRes: result, url: url));
        }
      } else {
        EasyLoading.dismiss();
        emit(const RemoveBGImageError(error: SOMETHING_WENT_WRONG));
      }
    } catch (e) {
      EasyLoading.dismiss();
      emit(RemoveBGImageError(error: e.toString()));
    }
  }

  Future<void> _onRemoveBGImage(
      RemoveBGImage event, Emitter<RemoveBGImageState> emit) async {
    emit(RemoveBGImageLoading());
    try {
      result = null;
      url = null;
      emit(RemoveBGImageLoaded(imageRes: result, url: url));
    } catch (e) {
      emit(RemoveBGImageError(error: e.toString()));
    }
  }

  Future<void> _onResetRemoveBGImage(
      ResetRemoveBGImage event, Emitter<RemoveBGImageState> emit) async {
    emit(RemoveBGImageLoading());
    try {
      result = null;
      url = null;
      errorText = null;
      if (event.hasLoaded) {
        emit(RemoveBGImageLoaded(imageRes: result, url: url));
      }
    } catch (e) {
      emit(RemoveBGImageError(error: e.toString()));
    }
  }

  void showSnackBar(String input, BuildContext context) {
    BotToast.showText(text: input, textStyle: body(color: grey1100));
  }

  Future<Uint8List?> removeBGImage(BuildContext context, String link,
      {String? option}) async {
    Uint8List? result;
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$apiEndpoint/remove_bg'));

      request.fields['uuid'] = firebaseUser.uid;
      request.fields['link'] = link;
      if (option != null) {
        request.fields['option'] = option;
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        result = response.bodyBytes;
      } else {
        errorText = SOMETHING_WENT_WRONG;
        showSnackBar(SOMETHING_WENT_WRONG, context);
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return result;
  }

  Future<String?> uploadImage(
      Uint8List? res, int requestId, BuildContext context) async {
    String? url;
    final imageFile = await createFileUploadDO(res!);
    url = await uploadFile(imageFile: imageFile);
    if (url != null) {
      insertImageRemBG(requestId, url, context);
    }
    return url;
  }
}
