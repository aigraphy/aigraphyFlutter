import 'dart:typed_data';

import 'package:aigraphy_flutter/config/config_color.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../config/config_font_styles.dart';
import '../../config/config_helper.dart';
import '../../config_model/history_model.dart';
import '../../util/upload_file_DO.dart';
import '../person/bloc_person.dart';
import 'bloc_swap_img.dart';

class SwapImgBloc extends Bloc<SwapImgEvent, SwapImgState> {
  SwapImgBloc() : super(SwapImgLoading()) {
    on<InitialSwapImg>(_onInitialGenerateImage);
    on<EditSwapImg>(_onEditGenerateImage);
  }

  User userFB = FirebaseAuth.instance.currentUser!;
  Uint8List? result;
  String? url;
  int? requestId;
  String? errorText;

  Future<void> _onInitialGenerateImage(
      InitialSwapImg event, Emitter<SwapImgState> emit) async {
    emit(SwapImgLoading());
    try {
      result = null;
      url = null;
      errorText = null;
      requestId = null;
      result = await handleImage(event.srcPath, event.dstPath, event.context);
      if (result != null) {
        final res = await uploadImage(result, event.context);
        if (res != null && res['url'] != null && res['request_id'] != null) {
          url = res['url'];
          requestId = res['request_id'];
          if (event.handleCoin) {
            final userBloc = event.context.read<PersonBloc>();
            userBloc.add(UpdateCoinUser(userBloc.userModel!.coin - TOKEN_SWAP));
          }
          emit(SwapImgLoaded(imageRes: result, url: url, requestId: requestId));
        }
      } else {
        emit(const SwapImgError(error: SOMETHING_WENT_WRONG));
      }
    } catch (e) {
      emit(SwapImgError(error: e.toString()));
    }
  }

  Future<void> _onEditGenerateImage(
      EditSwapImg event, Emitter<SwapImgState> emit) async {
    emit(SwapImgLoading());
    try {
      result = event.result;
      url = event.url;
      requestId = event.requestId;
      emit(SwapImgLoaded(imageRes: result, url: url, requestId: requestId));
    } catch (e) {
      emit(SwapImgError(error: e.toString()));
    }
  }

  void showSnackBar(String input, BuildContext context) {
    BotToast.showText(text: input, textStyle: style7(color: white));
  }

  Future<Uint8List?> handleImage(
      String srcPath, String dstPath, BuildContext context) async {
    Uint8List? result;
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$apiEndpoint/swap_image'));
      request.files.addAll([
        await http.MultipartFile.fromPath('srcPath', srcPath),
        await http.MultipartFile.fromPath('dstPath', dstPath)
      ]);
      request.fields['uuid'] = userFB.uid;
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

  Future<Map<String, dynamic>?> uploadImage(
      Uint8List? res, BuildContext context) async {
    String? url;
    HistoryModel? requestModel;
    final imageFile = await createFileUploadDO(res!);
    url = await uploadFileDO(imageFile: imageFile);
    if (url != null) {
      requestModel = await insertRequest(url, context);
    }
    return {'url': url, 'request_id': requestModel!.id};
  }
}
