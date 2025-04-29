//services/video_service.dart
import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class VideoService {
  // Compress video to 360p with H.264/AAC
  Future<File?> compressVideo(File videoFile, BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.mp4';

      // Primary command: Auto-detect input, 360p, 24 FPS
      final command = '-i "${videoFile.path}" -vf scale=640:360,fps=24 -c:v libx264 -preset ultrafast -crf 30 -c:a aac -b:a 96k -y "$outputPath"';
      print('Executing FFmpeg command: $command');

      final result = await FFmpegKit.execute(command);

      if (result == null) {
        print('FFmpeg execution failed: result is null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to compress video: FFmpeg execution returned null')),
        );
        return null;
      }

      final returnCode = await result.getReturnCode();
      final logs = await result.getAllLogsAsString();
      final failReason = await result.getFailStackTrace();
      print('FFmpeg logs: $logs');
      if (failReason != null) {
        print('FFmpeg fail stack trace: $failReason');
      }

      if (returnCode != null && returnCode.isValueSuccess()) {
        print('Video compression successful');
        return File(outputPath);
      } else {
        print('Video compression failed with return code: $returnCode');
        // Fallback command: Even simpler settings
        final fallbackCommand = '-i "${videoFile.path}" -vf scale=480:270,fps=24 -c:v libx264 -preset superfast -crf 32 -c:a aac -b:a 64k -y "$outputPath"';
        print('Attempting fallback FFmpeg command: $fallbackCommand');
        final fallbackResult = await FFmpegKit.execute(fallbackCommand);

        if (fallbackResult == null) {
          print('Fallback FFmpeg execution failed: result is null');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to compress video: Fallback execution returned null')),
          );
          return null;
        }

        final fallbackReturnCode = await fallbackResult.getReturnCode();
        final fallbackLogs = await fallbackResult.getAllLogsAsString();
        final fallbackFailReason = await fallbackResult.getFailStackTrace();
        print('Fallback FFmpeg logs: $fallbackLogs');
        if (fallbackFailReason != null) {
          print('Fallback FFmpeg fail stack trace: $fallbackFailReason');
        }

        if (fallbackReturnCode != null && fallbackReturnCode.isValueSuccess()) {
          print('Fallback video compression successful');
          return File(outputPath);
        } else {
          print('Fallback video compression failed with return code: $fallbackReturnCode');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to compress video: ${fallbackFailReason ?? fallbackLogs}')),
          );
          return null;
        }
      }
    } catch (e) {
      print('Error compressing video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error compressing video: $e')),
      );
      return null;
    }
  }

  // Generate and upload video thumbnail
  Future<String?> generateAndUploadThumbnail(File videoFile, String userId) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      );

      if (thumbnailPath == null) {
        print('Failed to generate thumbnail');
        return null;
      }

      final thumbnailFile = File(thumbnailPath);
      final filename = '${DateTime.now().millisecondsSinceEpoch}_thumbnail.jpg';
      final storageRef = FirebaseStorage.instance.ref().child('thumbnails/$userId/$filename');
      final uploadTask = await storageRef.putFile(thumbnailFile);
      final thumbnailUrl = await uploadTask.ref.getDownloadURL();

      print('Thumbnail uploaded successfully: $thumbnailUrl');
      return thumbnailUrl;
    } catch (e) {
      print('Error generating/uploading thumbnail: $e');
      return null;
    }
  }

  // Validate video duration (max 60 seconds) and resolution
  Future<Map<String, dynamic>> validateVideo(File videoFile) async {
    try {
      final controller = VideoPlayerController.file(videoFile);
      await controller.initialize();
      final duration = controller.value.duration;
      final size = controller.value.size;
      await controller.dispose();

      return {
        'isValidDuration': duration.inSeconds <= 60,
        'width': size.width.toInt(),
        'height': size.height.toInt(),
      };
    } catch (e) {
      print('Error validating video: $e');
      return {
        'isValidDuration': false,
        'width': 0,
        'height': 0,
      };
    }
  }
}