import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/index.dart';
import '../../models/date_record.dart';
import '../../models/place.dart';
import '../../models/media.dart';
import '../../providers/date_record_provider.dart';
import '../../widgets/index.dart';

class DateRecordEditScreen extends StatefulWidget {
  final DateRecord dateRecord;

  const DateRecordEditScreen({
    super.key,
    required this.dateRecord,
  });

  @override
  State<DateRecordEditScreen> createState() => _DateRecordEditScreenState();
}

class _DateRecordEditScreenState extends State<DateRecordEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _memoController;

  late DateTime _selectedDate;
  late Emotion _selectedEmotion;
  List<Place> _places = [];
  List<Media> _media = [];
  List<XFile> _newMediaFiles = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _titleController = TextEditingController(text: widget.dateRecord.title);
    _memoController = TextEditingController(text: widget.dateRecord.memo);
    _selectedDate = widget.dateRecord.date;
    _selectedEmotion = widget.dateRecord.emotion;

    // In a real app, we would load places and media from their respective providers
    // For now, we'll use dummy data
    _loadPlacesAndMedia();
  }

  void _loadPlacesAndMedia() {
    // This is just for demonstration purposes
    _places = List.generate(
      2,
      (index) => Place(
        id: 'place_$index',
        dateRecordId: widget.dateRecord.id,
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

    _media = List.generate(
      3,
      (index) => Media(
        id: 'media_$index',
        referenceId: widget.dateRecord.id,
        referenceType: ReferenceType.DATE_RECORD,
        type: index == 0 ? MediaType.VIDEO : MediaType.IMAGE,
        url: 'https://picsum.photos/500/500?random=$index',
        thumbnailUrl: 'https://picsum.photos/200/200?random=$index',
        createdAt: DateTime.now().subtract(Duration(hours: index)),
        updatedAt: DateTime.now().subtract(Duration(hours: index)),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addPlace() async {
    // In a real app, this would navigate to a place search/add screen
    // For now, we'll just add a dummy place
    setState(() {
      _places.add(
        Place(
          id: 'place_${_places.length}',
          dateRecordId: widget.dateRecord.id,
          name: '새로운 장소 ${_places.length + 1}',
          address: '서울시 강남구',
          latitude: 37.5,
          longitude: 127.0,
          category: PlaceCategory.CAFE,
          rating: 4,
          review: '좋은 곳이었어요!',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    });
  }

  void _removePlace(int index) {
    setState(() {
      _places.removeAt(index);
    });
  }

  void _removeMedia(int index) {
    setState(() {
      _media.removeAt(index);
    });
  }

  void _removeNewMedia(int index) {
    setState(() {
      _newMediaFiles.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _newMediaFiles.addAll(images);
      });
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        _newMediaFiles.add(video);
      });
    }
  }

  void _showMediaPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('미디어 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('사진 추가'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('동영상 추가'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDateRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dateRecordProvider = Provider.of<DateRecordProvider>(context, listen: false);

      final updatedDateRecord = widget.dateRecord.copyWith(
        title: _titleController.text,
        memo: _memoController.text,
        emotion: _selectedEmotion,
      );

      final success = await dateRecordProvider.updateDateRecord(updatedDateRecord);

      if (!mounted) return;

      if (success) {
        // In a real app, we would also update places and media
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = '데이트 기록 수정에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('데이트 기록 수정'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateDateRecord,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '저장',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker
              _buildDatePicker(),
              const SizedBox(height: 16),

              // Emotion selector
              _buildEmotionSelector(),
              const SizedBox(height: 24),

              // Title field
              CustomTextField(
                controller: _titleController,
                labelText: '제목',
                hintText: '데이트 제목을 입력하세요',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Memo field
              CustomTextField(
                controller: _memoController,
                labelText: '메모',
                hintText: '데이트에 대한 메모를 입력하세요',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '메모를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Places section
              _buildSectionHeader('방문한 장소', '장소 추가', _addPlace),
              const SizedBox(height: 8),
              _places.isEmpty
                  ? _buildEmptyPlacesMessage()
                  : Column(
                      children: List.generate(
                        _places.length,
                        (index) => _buildPlaceCard(_places[index], index),
                      ),
                    ),
              const SizedBox(height: 24),

              // Media section
              _buildSectionHeader('사진 및 동영상', '미디어 추가', _showMediaPickerDialog),
              const SizedBox(height: 8),
              _media.isEmpty && _newMediaFiles.isEmpty
                  ? _buildEmptyMediaMessage()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_media.isNotEmpty) ...[
                          const Text(
                            '기존 미디어',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildMediaGrid(),
                          const SizedBox(height: 16),
                        ],
                        if (_newMediaFiles.isNotEmpty) ...[
                          const Text(
                            '새 미디어',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildNewMediaGrid(),
                        ],
                      ],
                    ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Save button
              CustomButton(
                text: '저장하기',
                onPressed: _isLoading ? null : _updateDateRecord,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '날짜',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '감정',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEmotionOption(Emotion.HAPPY, '행복'),
                _buildEmotionOption(Emotion.EXCITED, '신남'),
                _buildEmotionOption(Emotion.NORMAL, '보통'),
                _buildEmotionOption(Emotion.SAD, '슬픔'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEmotionOption(Emotion.ANGRY, '화남'),
                _buildEmotionOption(Emotion.SURPRISED, '놀람'),
                _buildEmotionOption(Emotion.LOVED, '사랑'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmotionOption(Emotion emotion, String label) {
    final isSelected = _selectedEmotion == emotion;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEmotion = emotion;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? _getEmotionColor(emotion).withOpacity(0.2)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: _getEmotionColor(emotion), width: 2)
                  : null,
            ),
            child: Icon(
              _getEmotionIcon(emotion),
              color: isSelected ? _getEmotionColor(emotion) : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? _getEmotionColor(emotion) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.add),
          label: Text(actionText),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPlacesMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.place,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '방문한 장소를 추가해보세요',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Place place, int index) {
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
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _removePlace(index),
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('평점: '),
                _buildRatingStars(place.rating),
              ],
            ),
            if (place.review != null && place.review!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                place.review!,
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

  Widget _buildEmptyMediaMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.photo_library,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '사진이나 동영상을 추가해보세요',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
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
        return _buildMediaItem(media, index);
      },
    );
  }

  Widget _buildNewMediaGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _newMediaFiles.length,
      itemBuilder: (context, index) {
        final file = _newMediaFiles[index];
        return _buildNewMediaItem(file, index);
      },
    );
  }

  Widget _buildMediaItem(Media media, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            media.thumbnailUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.error),
              );
            },
          ),
        ),
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
        Positioned(
          top: 8,
          right: media.type == MediaType.VIDEO ? 32 : 8,
          child: GestureDetector(
            onTap: () => _removeMedia(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewMediaItem(XFile file, int index) {
    final isVideo = file.name.toLowerCase().endsWith('.mp4') ||
                    file.name.toLowerCase().endsWith('.mov');

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FutureBuilder<String>(
            future: Future.value(file.path),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return Image.asset(
                  'assets/images/placeholder.png',
                  fit: BoxFit.cover,
                );
              }
              return Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
        if (isVideo)
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
        Positioned(
          top: 8,
          right: isVideo ? 32 : 8,
          child: GestureDetector(
            onTap: () => _removeNewMedia(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getEmotionColor(Emotion emotion) {
    switch (emotion) {
      case Emotion.HAPPY:
        return Colors.amber;
      case Emotion.EXCITED:
        return Colors.orange;
      case Emotion.NORMAL:
        return Colors.blue;
      case Emotion.SAD:
        return Colors.indigo;
      case Emotion.ANGRY:
        return Colors.red;
      case Emotion.SURPRISED:
        return Colors.purple;
      case Emotion.LOVED:
        return Colors.pink;
    }
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

  Color _getCategoryColor(PlaceCategory category) {
    switch (category) {
      case PlaceCategory.RESTAURANT:
        return Colors.orange;
      case PlaceCategory.CAFE:
        return Colors.brown;
      case PlaceCategory.MOVIE:
        return Colors.indigo;
      case PlaceCategory.SHOPPING:
        return Colors.pink;
      case PlaceCategory.ACTIVITY:
        return Colors.green;
      case PlaceCategory.OTHER:
        return Colors.grey;
      case PlaceCategory.ATTRACTION:
        return Colors.blue;
      case PlaceCategory.ACCOMMODATION:
        return Colors.purple;
      case PlaceCategory.TRAVEL:
        return Colors.teal;
    }
  }

  IconData _getCategoryIcon(PlaceCategory category) {
    switch (category) {
      case PlaceCategory.RESTAURANT:
        return Icons.restaurant;
      case PlaceCategory.CAFE:
        return Icons.coffee;
      case PlaceCategory.MOVIE:
        return Icons.movie;
      case PlaceCategory.SHOPPING:
        return Icons.shopping_bag;
      case PlaceCategory.ACTIVITY:
        return Icons.sports;
      case PlaceCategory.OTHER:
        return Icons.place;
      case PlaceCategory.ATTRACTION:
        return Icons.attractions;
      case PlaceCategory.ACCOMMODATION:
        return Icons.hotel;
      case PlaceCategory.TRAVEL:
        return Icons.flight_takeoff;
    }
  }
}
    