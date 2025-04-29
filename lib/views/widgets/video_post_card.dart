//views/widgets/video_post_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../models/post_model.dart';
import 'custom_video_player.dart';

class VideoPostCard extends StatelessWidget {
  final PostModel post;
  final bool isThumbnailOnly;

  const VideoPostCard({
    Key? key,
    required this.post,
    this.isThumbnailOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          if (post.type == 'video' && post.videoUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: isThumbnailOnly && post.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: post.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                cacheManager: DefaultCacheManager(),
              )
                  : CustomVideoPlayer(videoUrl: post.videoUrl),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(post.caption),
          ),
        ],
      ),
    );
  }
}

class CachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget Function(BuildContext, String) placeholder;
  final Widget Function(BuildContext, String, dynamic) errorWidget;
  final BaseCacheManager cacheManager;

  const CachedNetworkImage({
    Key? key,
    required this.imageUrl,
    required this.fit,
    required this.placeholder,
    required this.errorWidget,
    required this.cacheManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FileInfo?>(
      future: cacheManager.getFileFromCache(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.file.existsSync()) {
          return Image.file(
            snapshot.data!.file,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => errorWidget(context, imageUrl, error),
          );
        }
        return Image.network(
          imageUrl,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder(context, imageUrl);
          },
          errorBuilder: (context, error, stackTrace) => errorWidget(context, imageUrl, error),
        );
      },
    );
  }
}
