import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/index.dart';
import '../../models/media.dart';
import '../../providers/date_record_provider.dart';
import '../media/media_detail_screen.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  int _currentIndex = 2;
  bool _isLoading = false;
  List<Media> _mediaList = [];
  MediaType _selectedMediaType = MediaType.IMAGE;
  
  @override
  void initState() {
    super.initState();
    _loadMedia();
  }
  
  Future<void> _loadMedia() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // In a real app, we would use a MediaProvider to load media
      // final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
      // final media = await mediaProvider.getAllMedia(type: _selectedMediaType);
      
      // For now, we'll use dummy data
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _mediaList = _getDummyMedia();
      });
    } catch (e) {
      debugPrint('Error loading media: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  List<Media> _getDummyMedia() {
    // This is just for demonstration purposes
    // In a real app, this data would come from the API
    return List.generate(
      20,
      (index) => Media(
        id: 'media_$index',
        referenceId: 'date_record_${index % 5}',
        referenceType: ReferenceType.DATE_RECORD,
        type: index % 3 == 0 ? MediaType.VIDEO : MediaType.IMAGE,
        url: 'https://picsum.photos/500/500?random=$index',
        thumbnailUrl: 'https://picsum.photos/200/200?random=$index',
        createdAt: DateTime.now().subtract(Duration(days: index)),
        updatedAt: DateTime.now().subtract(Duration(days: index)),
      ),
    );
  }
  
  void _navigateToScreen(int index) {
    if (index == _currentIndex) return;
    
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/calendar');
        break;
      case 2:
        // Already on memories screen
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/settings');
        break;
    }
  }
  
  void _viewMedia(Media media) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaDetailScreen(media: media),
      ),
    );
  }
  
  void _changeMediaType(MediaType type) {
    if (type != _selectedMediaType) {
      setState(() {
        _selectedMediaType = type;
      });
      _loadMedia();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추억'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: '필터',
          ),
        ],
      ),
      body: Column(
        children: [
          // Media type selector
          _buildMediaTypeSelector(),
          
          // Media grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _mediaList.isEmpty
                    ? _buildEmptyState()
                    : _buildMediaGrid(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToScreen,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: '추억',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
  
  Widget _buildMediaTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMediaTypeButton(
            '모든 미디어',
            Icons.perm_media,
            null,
          ),
          _buildMediaTypeButton(
            '사진',
            Icons.photo,
            MediaType.IMAGE,
          ),
          _buildMediaTypeButton(
            '동영상',
            Icons.videocam,
            MediaType.VIDEO,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMediaTypeButton(String label, IconData icon, MediaType? type) {
    final isSelected = type == _selectedMediaType || (type == null && _selectedMediaType == MediaType.IMAGE);
    
    return InkWell(
      onTap: () => type != null ? _changeMediaType(type) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMediaGrid() {
    return RefreshIndicator(
      onRefresh: _loadMedia,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _mediaList.length,
        itemBuilder: (context, index) {
          final media = _mediaList[index];
          return _buildMediaItem(media);
        },
      ),
    );
  }
  
  Widget _buildMediaItem(Media media) {
    return GestureDetector(
      onTap: () => _viewMedia(media),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: media.thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.error),
              ),
            ),
          ),
          
          // Video indicator
          if (media.type == MediaType.VIDEO)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 추억이 없어요.\n데이트를 기록하고 사진을 추가해보세요!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('필터'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date range selector
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('날짜 범위'),
              subtitle: const Text('모든 기간'),
              onTap: () {
                Navigator.pop(context);
                _showDateRangeDialog();
              },
            ),
            
            // Category selector
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('카테고리'),
              subtitle: const Text('모든 카테고리'),
              onTap: () {
                Navigator.pop(context);
                _showCategoryDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadMedia();
            },
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }
  
  void _showDateRangeDialog() {
    // In a real app, this would show a date range picker
    // and apply the selected range to the filter
  }
  
  void _showCategoryDialog() {
    // In a real app, this would show a category selector
    // and apply the selected categories to the filter
  }
}