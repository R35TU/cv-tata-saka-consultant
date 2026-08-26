import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StorageService {
  /// Mengunggah foto ke Cloudinary menggunakan Unsigned Upload Preset.
  /// Mengembalikan URL aman (secure_url) dari gambar yang berhasil diunggah.
  Future<String?> uploadPhoto(File file) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName == null || cloudName.isEmpty || uploadPreset == null || uploadPreset.isEmpty) {
      throw Exception('Konfigurasi Cloudinary belum diset di .env');
    }

    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);
      
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonMap = jsonDecode(responseData);
        return jsonMap['secure_url'];
      } else {
        final responseData = await response.stream.bytesToString();
        throw Exception('Gagal mengunggah gambar ke Cloudinary. Status: ${response.statusCode}, Response: $responseData');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengunggah foto: $e');
    }
  }

  /// Mengunggah file dari image_picker XFile
  Future<String?> uploadXFile(dynamic file) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName == null || cloudName.isEmpty || uploadPreset == null || uploadPreset.isEmpty) {
      throw Exception('Konfigurasi Cloudinary belum diset di .env');
    }

    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);
      
      request.fields['upload_preset'] = uploadPreset;
      final bytes = await file.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: file.name ?? 'upload.jpg'));

      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonMap = jsonDecode(responseData);
        return jsonMap['secure_url'];
      } else {
        final responseData = await response.stream.bytesToString();
        throw Exception('Gagal mengunggah gambar ke Cloudinary. Status: ${response.statusCode}, Response: $responseData');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengunggah foto: $e');
    }
  }
}
