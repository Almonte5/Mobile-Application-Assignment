import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ImageUploadService {
  static const _cloudName = 'dnho7hzwo';
  static const _uploadPreset = 'mq_marketplace_unsigned';

  Future<String> uploadImage(XFile imageFile) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final bytes = await imageFile.readAsBytes();
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: imageFile.name,
        ),
      );

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Image upload failed (${response.statusCode})');
    }

    final body = await response.stream.bytesToString();
    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url'] as String;
  }
}