import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import '../../config/config_color.dart';
import '../../config/config_font_styles.dart';
import '../../config/config_helper.dart';
import '../../util/upload_file_DO.dart';
import '../person/bloc_person.dart';
import 'bloc_rem_bg_img.dart';

class RemBGImgBloc extends Bloc<RemBGImgEvent, RemBGImgState> {
  RemBGImgBloc() : super(RemBGImgLoading()) {
    on<InitialRemBGImg>(_onInitialRemBGImg);
    on<RemBGImg>(_onRemBGImg);
    on<ResetRemBGImg>(_onResetRemBGImg);
  }

  User userFB = FirebaseAuth.instance.currentUser!;
  Uint8List? result;
  String? url;
  String? errorText;

  Future<void> _onInitialRemBGImg(
      InitialRemBGImg event, Emitter<RemBGImgState> emit) async {
    emit(RemBGImgLoading());
    try {
      result = null;
      url = null;
      errorText = null;
      result = await removeBGImage(event.context, event.link);
      if (result != null) {
        url = await uploadImage(result, event.requestId, event.context);
        if (url != null) {
          final userBloc = event.context.read<PersonBloc>();
          userBloc
              .add(UpdateCoinUser(userBloc.userModel!.coin - TOKEN_REMOVE_BG));
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

  Future<void> _onRemBGImg(RemBGImg event, Emitter<RemBGImgState> emit) async {
    emit(RemBGImgLoading());
    try {
      result = null;
      url = null;
      emit(RemoveBGImageLoaded(imageRes: result, url: url));
    } catch (e) {
      emit(RemoveBGImageError(error: e.toString()));
    }
  }

  Future<void> _onResetRemBGImg(
      ResetRemBGImg event, Emitter<RemBGImgState> emit) async {
    emit(RemBGImgLoading());
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
    BotToast.showText(text: input, textStyle: style7(color: white));
  }

  Future<Uint8List?> removeBGImage(BuildContext context, String link) async {
    Uint8List? result;
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$apiEndpoint/remove_bg'));

      request.fields['uuid'] = userFB.uid;
      request.fields['link'] = link;
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
    url = await uploadFileDO(imageFile: imageFile);
    if (url != null) {
      insertImgRemBG(requestId, url, context);
    }
    return url;
  }
}
