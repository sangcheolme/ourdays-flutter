import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_theme.dart';
import '../../models/date_record.dart';
import '../../models/special_date.dart';
import '../../providers/auth_provider.dart';
import '../../providers/couple_provider.dart';
import '../../providers/date_record_provider.dart';
import '../../widgets/index.dart';
import '../date_record/date_record_detail_screen.dart';
import '../date_record/date_record_create_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;
  List<DateRecord> _recentDateRecords = [];
  List<SpecialDate> _upcomingSpecialDates = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dateRecordProvider = Provider.of<DateRecordProvider>(context, listen: false);
      final records = await dateRecordProvider.getRecentDateRecords(limit: 3);

      setState(() {
        _recentDateRecords = records;
      });

      // In a real app, we would also load upcoming special dates here
      // final specialDateProvider = Provider.of<SpecialDateProvider>(context, listen: false);
      // final specialDates = await specialDateProvider.getUpcomingSpecialDates(limit: 3);
      // setState(() {
      //   _upcomingSpecialDates = specialDates;
      // });
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToScreen(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        // Already on home screen
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/calendar');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/memories');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/settings');
        break;
    }
  }

  Future<void> _createDateRecord() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DateRecordCreateScreen(),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _viewDateRecord(DateRecord record) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DateRecordDetailScreen(dateRecordId: record.id),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final coupleProvider = Provider.of<CoupleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Couple info card
              _buildCoupleInfoCard(coupleProvider),
              const SizedBox(height: 24),

              // Recent date records
              _buildSectionHeader('최근 데이트', '더보기', () {
                Navigator.of(context).pushReplacementNamed('/calendar');
              }),
              const SizedBox(height: 8),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recentDateRecords.isEmpty
                      ? _buildEmptyState('아직 데이트 기록이 없어요.\n첫 데이트를 기록해보세요!')
                      : Column(
                          children: _recentDateRecords
                              .map((record) => _buildDateRecordCard(record))
                              .toList(),
                        ),
              const SizedBox(height: 24),

              // Upcoming special dates
              _buildSectionHeader('다가오는 기념일', '더보기', () {
                // Navigate to special dates screen
              }),
              const SizedBox(height: 8),
              _upcomingSpecialDates.isEmpty
                  ? _buildEmptyState('다가오는 기념일이 없어요.\n특별한 날을 등록해보세요!')
                  : Column(
                      children: _upcomingSpecialDates
                          .map((date) => _buildSpecialDateCard(date))
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createDateRecord,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
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

  Widget _buildCoupleInfoCard(CoupleProvider coupleProvider) {
    final couple = coupleProvider.couple;

    if (couple == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              '커플 정보를 불러올 수 없습니다.',
              style: TextStyle(
                color: AppColors.error,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.favorite,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '우리의 ${coupleProvider.daysSinceAnniversary}일째',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '기념일: ${DateFormat('yyyy년 MM월 dd일').format(couple.anniversaryDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  '다음 기념일',
                  '${coupleProvider.daysUntilNextAnniversary}일 남음',
                  Icons.cake,
                ),
                _buildInfoItem(
                  '데이트 횟수',
                  '${_recentDateRecords.length}회',
                  Icons.favorite,
                ),
                _buildInfoItem(
                  '특별한 날',
                  '${_upcomingSpecialDates.length}개',
                  Icons.star,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRecordCard(DateRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewDateRecord(record),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      DateFormat('yyyy.MM.dd').format(record.date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _getEmotionIcon(record.emotion),
                    color: _getEmotionColor(record.emotion),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                record.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                record.memo == null || record.memo!.isEmpty
                    ? '메모 없음'
                    : record.memo!.length > 100
                        ? '${record.memo!.substring(0, 100)}...'
                        : record.memo!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialDateCard(SpecialDate date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getSpecialDateIcon(date.type),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy년 MM월 dd일').format(date.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  'D-${_getDaysUntil(date.date)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_neutral,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
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
      default:
        return Icons.sentiment_neutral;
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
      default:
        return Colors.grey;
    }
  }

  IconData _getSpecialDateIcon(SpecialDateType type) {
    switch (type) {
      case SpecialDateType.ANNIVERSARY:
        return Icons.favorite;
      case SpecialDateType.BIRTHDAY:
        return Icons.cake;
      case SpecialDateType.SPECIAL_EVENT:
        return Icons.star;
      default:
        return Icons.event;
    }
  }

  int _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }
}
