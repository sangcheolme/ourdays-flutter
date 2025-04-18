import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/index.dart';
import '../../models/media.dart';

class MediaDetailScreen extends StatefulWidget {
  final Media media;

  const MediaDetailScreen({
    super.key,
    required this.media,
  });

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _setSystemUIOverlays();
  }

  @override
  void dispose() {
    // Restore system UI overlays when the screen is disposed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _setSystemUIOverlays() {
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _setSystemUIOverlays();
    });
  }

  void _shareMedia() async {
    await Share.share(
      '우리의 추억을 공유합니다: ${widget.media.url}',
      subject: '우리의 추억',
    );
  }

  void _downloadMedia() async {
    // In a real app, this would download the media to the device
    // For now, we'll just open the URL in the browser
    final url = Uri.parse(widget.media.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullScreen
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _shareMedia,
                  tooltip: '공유',
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _downloadMedia,
                  tooltip: '다운로드',
                ),
              ],
            ),
      body: GestureDetector(
        onTap: _toggleFullScreen,
        child: Center(
          child: _buildMediaContent(),
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    if (widget.media.type == MediaType.VIDEO) {
      return _buildVideoPlayer();
    } else {
      return _buildImageViewer();
    }
  }

  Widget _buildImageViewer() {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: CachedNetworkImage(
        imageUrl: widget.media.url,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        errorWidget: (context, url, error) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '이미지를 불러올 수 없습니다',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    // In a real app, this would use a video player package
    // For now, we'll just show a placeholder
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.play_circle_fill,
          color: AppColors.primary,
          size: 64,
        ),
        const SizedBox(height: 16),
        const Text(
          '동영상 재생',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '실제 앱에서는 동영상 플레이어가 표시됩니다',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
