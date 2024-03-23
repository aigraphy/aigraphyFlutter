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
import 'bloc_remove_bg_image.dart';

class RemoveBGImageBloc extends Bloc<RemoveBGImageEvent, RemoveBGImageState> {
  RemoveBGImageBloc() : super(RemoveBGImageLoading()) {
    on<InitialRemoveBGImage>(_onInitialRemoveBGImage);
    on<RemoveBGImage>(_onRemoveBGImage);
    on<ResetRemoveBGImage>(_onResetRemoveBGImage);
  }

  User userFB = FirebaseAuth.instance.currentUser!;
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
    BotToast.showText(text: input, textStyle: style7(color: white));
  }

  Future<Uint8List?> removeBGImage(BuildContext context, String link,
      {String? option}) async {
    Uint8List? result;
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$apiEndpoint/remove_bg'));

      request.fields['uuid'] = userFB.uid;
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
    url = await uploadFileDO(imageFile: imageFile);
    if (url != null) {
      insertImageRemBG(requestId, url, context);
    }
    return url;
  }
}
