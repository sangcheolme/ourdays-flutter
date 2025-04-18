import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/index.dart';
import '../../models/date_record.dart';
import '../../models/place.dart';
import '../../models/media.dart';
import '../../models/comment.dart';
import '../../providers/date_record_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/index.dart';
import '../media/media_detail_screen.dart';
import 'date_record_edit_screen.dart';

// Extended Comment class with userName for UI purposes
class ExtendedComment extends Comment {
  final String userName;
  
  ExtendedComment({
    required String super.id,
    required super.dateRecordId,
    required super.userId,
    required super.content,
    super.createdAt,
    super.updatedAt,
    required this.userName,
  });
}

class DateRecordDetailScreen extends StatefulWidget {
  final String dateRecordId;
  
  const DateRecordDetailScreen({
    super.key,
    required this.dateRecordId,
  });

  @override
  State<DateRecordDetailScreen> createState() => _DateRecordDetailScreenState();
}

class _DateRecordDetailScreenState extends State<DateRecordDetailScreen> {
  bool _isLoading = true;
  DateRecord? _dateRecord;
  List<Place> _places = [];
  List<Media> _media = [];
  List<ExtendedComment> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadDateRecord();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadDateRecord() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final dateRecordProvider = Provider.of<DateRecordProvider>(context, listen: false);
      await dateRecordProvider.getDateRecord(widget.dateRecordId);
      
      setState(() {
        _dateRecord = dateRecordProvider.currentDateRecord;
        
        // In a real app, we would load places, media, and comments from their respective providers
        // For now, we'll use dummy data
        _places = _getDummyPlaces();
        _media = _getDummyMedia();
        _comments = _getDummyComments();
      });
    } catch (e) {
      debugPrint('Error loading date record: $e');
      // Show error message
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  List<Place> _getDummyPlaces() {
    // This is just for demonstration purposes
    return List.generate(
      2,
      (index) => Place(
        id: 'place_$index',
        dateRecordId: widget.dateRecordId,
        name: index == 0 ? '스타벅스 강남점' : '롯데시네마 월드타워',
        address: index == 0 ? '서울시 강남구 강남대로 390' : '서울시 송파구 올림픽로 300',
        latitude: 37.5 + (index * 0.01),
        longitude: 127.0 + (index * 0.01),
        category: index == 0 ? PlaceCategory.CAFE : PlaceCategory.MOVIE,
        rating: 4 + (index % 2),
        review: index == 0 ? '커피가 맛있었어요. 다음에 또 오고 싶어요.' : '영화가 재미있었어요. 팝콘도 맛있었어요.',
        createdAt: DateTime.now().subtract(Duration(hours: index)),
        updatedAt: DateTime.now().subtract(Duration(hours: index)),
      ),
    );
  }
  
  List<Media> _getDummyMedia() {
    // This is just for demonstration purposes
    return List.generate(
      4,
      (index) => Media(
        id: 'media_$index',
        referenceId: widget.dateRecordId,
        referenceType: ReferenceType.DATE_RECORD,
        type: index == 0 ? MediaType.VIDEO : MediaType.IMAGE,
        url: 'https://picsum.photos/500/500?random=$index',
        thumbnailUrl: 'https://picsum.photos/200/200?random=$index',
        createdAt: DateTime.now().subtract(Duration(hours: index)),
        updatedAt: DateTime.now().subtract(Duration(hours: index)),
      ),
    );
  }
  
  List<ExtendedComment> _getDummyComments() {
    // This is just for demonstration purposes
    return List.generate(
      2,
      (index) => ExtendedComment(
        id: 'comment_$index',
        dateRecordId: widget.dateRecordId,
        userId: 'user_${index % 2}',
        content: index == 0 
            ? '정말 즐거운 데이트였어요! 다음에 또 가요.' 
            : '커피가 정말 맛있었어요. 영화도 재미있었고요.',
        createdAt: DateTime.now().subtract(Duration(hours: index * 2)),
        updatedAt: DateTime.now().subtract(Duration(hours: index * 2)),
        userName: index == 0 ? '김철수' : '이영희',
      ),
    );
  }
  
  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    // In a real app, we would add the comment through a provider
    // For now, we'll just add it to the local list
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    setState(() {
      _comments.insert(
        0,
        ExtendedComment(
          id: 'comment_${_comments.length}',
          dateRecordId: widget.dateRecordId,
          userId: user?.id ?? 'unknown',
          content: _commentController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userName: user?.name ?? '사용자',
        ),
      );
      _commentController.clear();
    });
  }
  
  Future<void> _editDateRecord() async {
    if (_dateRecord == null) return;
    
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DateRecordEditScreen(dateRecord: _dateRecord!),
      ),
    );
    
    if (result == true) {
      _loadDateRecord();
    }
  }
  
  Future<void> _deleteDateRecord() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이트 기록 삭제'),
        content: const Text('정말 이 데이트 기록을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '삭제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final dateRecordProvider = Provider.of<DateRecordProvider>(context, listen: false);
        final success = await dateRecordProvider.deleteDateRecord(widget.dateRecordId);
        
        if (!mounted) return;
        
        if (success) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('데이트 기록 삭제에 실패했습니다.')),
          );
        }
      } catch (e) {
        debugPrint('Error deleting date record: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }
  
  void _viewMedia(Media media) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaDetailScreen(media: media),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('데이트 상세'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isLoading || _dateRecord == null ? null : _editDateRecord,
            tooltip: '수정',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading || _dateRecord == null ? null : _deleteDateRecord,
            tooltip: '삭제',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dateRecord == null
              ? _buildErrorState()
              : _buildContent(),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '데이트 기록을 불러올 수 없습니다.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: '다시 시도',
            onPressed: _loadDateRecord,
            width: 200,
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and emotion
          _buildDateHeader(),
          const SizedBox(height: 16),
          
          // Title and memo
          _buildTitleAndMemo(),
          const SizedBox(height: 24),
          
          // Places
          if (_places.isNotEmpty) ...[
            _buildSectionHeader('방문한 장소'),
            const SizedBox(height: 8),
            ..._places.map((place) => _buildPlaceCard(place)),
            const SizedBox(height: 24),
          ],
          
          // Media
          if (_media.isNotEmpty) ...[
            _buildSectionHeader('사진 및 동영상'),
            const SizedBox(height: 8),
            _buildMediaGrid(),
            const SizedBox(height: 24),
          ],
          
          // Comments
          _buildSectionHeader('댓글'),
          const SizedBox(height: 8),
          _buildCommentInput(),
          const SizedBox(height: 16),
          ..._comments.map((comment) => _buildCommentCard(comment)),
        ],
      ),
    );
  }
  
  Widget _buildDateHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            DateFormat('yyyy년 MM월 dd일').format(_dateRecord!.date),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _getEmotionColor(_dateRecord!.emotion).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                _getEmotionIcon(_dateRecord!.emotion),
                size: 16,
                color: _getEmotionColor(_dateRecord!.emotion),
              ),
              const SizedBox(width: 4),
              Text(
                _getEmotionText(_dateRecord!.emotion),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getEmotionColor(_dateRecord!.emotion),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTitleAndMemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _dateRecord!.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _dateRecord!.memo ?? '',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildPlaceCard(Place place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(place.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(place.category),
                    color: _getCategoryColor(place.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRatingStars(place.rating),
              ],
            ),
            if (place.review.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                place.review,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? Colors.amber : Colors.grey,
          size: 16,
        );
      }),
    );
  }
  
  Widget _buildMediaGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _media.length,
      itemBuilder: (context, index) {
        final media = _media[index];
        return _buildMediaItem(media);
      },
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
              imageUrl: media.thumbnailUrl ?? '',
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
  
  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: '댓글을 입력하세요',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _addComment,
          color: AppColors.primary,
        ),
      ],
    );
  }
  
  Widget _buildCommentCard(ExtendedComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('yyyy.MM.dd HH:mm').format(comment.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.content),
        ],
      ),
    );
  }
  
  IconData _getEmotionIcon(Emotion emotion) {
    switch (emotion) {
      case Emotion.HAPPY:
        return Icons.sentiment_very_satisfied;
      case Emotion.EXCITED:
        return Icons.mood;
      case Emotion.NORMAL:
        return Icons.sentiment_neutral;
      case Emotion.SAD:
        return Icons.sentiment_dissatisfied;
      case Emotion.ANGRY:
        return Icons.sentiment_very_dissatisfied;
      case Emotion.SURPRISED:
        return Icons.sentiment_satisfied_alt;
      case Emotion.LOVED:
        return Icons.favorite;
      }
  }
  
  Color _getEmotionColor(Emotion emotion) {
    switch (emotion) {
      case Emotion.HAPPY:
        return Colors.green;
      case Emotion.EXCITED:
        return Colors.amber;
      case Emotion.NORMAL:
        return Colors.blue;
      case Emotion.SAD:
        return Colors.red;
      case Emotion.ANGRY:
        return Colors.deepOrange;
      case Emotion.SURPRISED:
        return Colors.purple;
      case Emotion.LOVED:
        return Colors.pink;
      }
  }
  
  String _getEmotionText(Emotion emotion) {
    switch (emotion) {
      case Emotion.HAPPY:
        return '행복';
      case Emotion.EXCITED:
        return '신남';
      case Emotion.NORMAL:
        return '보통';
      case Emotion.SAD:
        return '슬픔';
      case Emotion.ANGRY:
        return '화남';
      case Emotion.SURPRISED:
        return '놀람';
      case Emotion.LOVED:
        return '사랑';
      }
  }
  
  IconData _getCategoryIcon(PlaceCategory category) {
    switch (category) {
      case PlaceCategory.RESTAURANT:
        return Icons.restaurant;
      case PlaceCategory.CAFE:
        return Icons.local_cafe;
      case PlaceCategory.MOVIE:
        return Icons.movie;
      case PlaceCategory.SHOPPING:
        return Icons.shopping_bag;
      case PlaceCategory.ATTRACTION:
        return Icons.attractions;
      case PlaceCategory.ACTIVITY:
        return Icons.sports;
      case PlaceCategory.ACCOMMODATION:
        return Icons.hotel;
      case PlaceCategory.TRAVEL:
        return Icons.flight;
      case PlaceCategory.OTHER:
        return Icons.more_horiz;
      }
  }
  
  Color _getCategoryColor(PlaceCategory category) {
    switch (category) {
      case PlaceCategory.RESTAURANT:
        return Colors.orange;
      case PlaceCategory.CAFE:
        return Colors.brown;
      case PlaceCategory.MOVIE:
        return Colors.purple;
      case PlaceCategory.SHOPPING:
        return Colors.pink;
      case PlaceCategory.ATTRACTION:
        return Colors.amber;
      case PlaceCategory.ACTIVITY:
        return Colors.green;
      case PlaceCategory.ACCOMMODATION:
        return Colors.indigo;
      case PlaceCategory.TRAVEL:
        return Colors.blue;
      case PlaceCategory.OTHER:
        return Colors.grey;
      }
  }
}