import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../constant/helper.dart';

Future<String?> uploadFile({required File imageFile}) async {
  final User user = FirebaseAuth.instance.currentUser!;
  String? image;

  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUploadImageEndpoint/upload_file'),
    );

    final fileStream = http.ByteStream(imageFile.openRead());
    final length = await imageFile.length();

    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: '${user.uid}_${DateTime.now().toIso8601String()}.jpg',
    );
    request.files.add(multipartFile);

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final parsedData = json.decode(responseData);
      image = parsedData['link'];
    } else {
      BotToast.showText(
          text: 'Data upload failed with status: ${response.statusCode}');
    }

    return image!;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<void> deleteFile(String linkImage) async {
  try {
    final url = Uri.parse('$apiUploadImageEndpoint/delete_file');
    final body = {'linkImage': linkImage};
    await http.post(url, body: body);
  } catch (e) {
    print(e);
  }
}
