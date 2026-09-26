import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/stream_source.dart';
import '../models/media_item.dart';

enum DownloadStatus { pending, downloading, paused, completed, failed }

class DownloadTask {
  final String id;
  final MediaItem media;
  final StreamSource source;
  final String savePath;
  DownloadStatus status;
  double progress;
  int downloadedBytes;
  int totalBytes;
  CancelToken? cancelToken;

  DownloadTask({
    required this.id,
    required this.media,
    required this.source,
    required this.savePath,
    this.status = DownloadStatus.pending,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.cancelToken,
  });
}

class DownloadService extends ChangeNotifier {
  final Dio _dio = Dio();
  final Map<String, DownloadTask> _tasks = {};

  List<DownloadTask> get tasks => _tasks.values.toList();

  Future<void> startDownload(MediaItem media, StreamSource source) async {
    final taskId = '${media.id}_${DateTime.now().millisecondsSinceEpoch}';
    final dir = await getApplicationDocumentsDirectory();
    final cleanTitle = media.name.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    final filePath = '${dir.path}/${cleanTitle}_${source.quality}.mp4';

    final task = DownloadTask(
      id: taskId,
      media: media,
      source: source,
      savePath: filePath,
      status: DownloadStatus.downloading,
      cancelToken: CancelToken(),
    );

    _tasks[taskId] = task;
    notifyListeners();

    try {
      await _dio.download(
        source.url,
        filePath,
        cancelToken: task.cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            task.progress = received / total;
            task.downloadedBytes = received;
            task.totalBytes = total;
            notifyListeners();
          }
        },
      );
      task.status = DownloadStatus.completed;
      task.progress = 1.0;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        task.status = DownloadStatus.paused;
      } else {
        task.status = DownloadStatus.failed;
      }
    } catch (_) {
      task.status = DownloadStatus.failed;
    }
    notifyListeners();
  }

  void pauseDownload(String taskId) {
    final task = _tasks[taskId];
    if (task != null && task.status == DownloadStatus.downloading) {
      task.cancelToken?.cancel('Paused by user');
      task.status = DownloadStatus.paused;
      notifyListeners();
    }
  }

  void cancelDownload(String taskId) {
    final task = _tasks[taskId];
    if (task != null) {
      task.cancelToken?.cancel('Cancelled');
      final file = File(task.savePath);
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (_) {}
      }
      _tasks.remove(taskId);
      notifyListeners();
    }
  }
}
