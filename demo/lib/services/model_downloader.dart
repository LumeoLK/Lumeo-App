import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ModelDownloader {
  static final Dio _dio = Dio();

  /// Downloads .glb from [url] and returns the local file path
  static Future<String> downloadModel(
    String url, {
    Function(int received, int total)? onProgress,
  }) async {
    // Get app's cache directory on the device
    final cacheDir = await getApplicationCacheDirectory();

    // Use filename from URL (e.g. "chair.glb")
    final fileName = url.split('/').last;
    final filePath = '${cacheDir.path}/$fileName';

    // If already downloaded before, skip re-downloading
    if (await File(filePath).exists()) {
      print('Model already cached: $filePath');
      return filePath;
    }

    // Download the file
    await _dio.download(url, filePath, onReceiveProgress: onProgress);

    print('Model downloaded to: $filePath');
    return filePath;
  }
}
