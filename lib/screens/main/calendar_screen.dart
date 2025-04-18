import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../constants/index.dart';
import '../../models/date_record.dart';
import '../../providers/date_record_provider.dart';
import '../../widgets/custom_button.dart';
import '../date_record/date_record_detail_screen.dart';
import '../date_record/date_record_create_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final int _currentIndex = 1;
  bool _isLoading = false;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<DateRecord> _selectedDayRecords = [];
  
  @override
  void initState() {
    super.initState();
    _loadCalendarData();
  }
  
  Future<void> _loadCalendarData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final dateRecordProvider = Provider.of<DateRecordProvider>(context, listen: false);
      await dateRecordProvider.loadCalendarMonth(_focusedDay);
      _updateSelectedDayRecords();
    } catch (e) {
      debugPrint('Error loading calendar data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _updateSelectedDayRecords() {
    final dateRecordProvider = Provider.of<DateRecordProvider>(context, listen: false);
    final selectedDate = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    
    setState(() {
      _selectedDayRecords = dateRecordProvider.calendarRecords[selectedDate] ?? [];
    });
  }
  
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    
    _updateSelectedDayRecords();
  }
  
  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
    
    // Load data for the new month if needed
    final dateRecordProvider = Provider.of<DateRecordProvider>(context, listen: false);
    dateRecordProvider.loadCalendarMonth(focusedDay);
  }
  
  void _navigateToScreen(int index) {
    if (index == _currentIndex) return;
    
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        // Already on calendar screen
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
        builder: (context) => DateRecordCreateScreen(initialDate: _selectedDay),
      ),
    );
    
    if (result == true) {
      _loadCalendarData();
    }
  }
  
  Future<void> _viewDateRecord(DateRecord record) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DateRecordDetailScreen(dateRecordId: record.id),
      ),
    );
    
    if (result == true) {
      _loadCalendarData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final dateRecordProvider = Provider.of<DateRecordProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Calendar
          _buildCalendar(dateRecordProvider),
          
          // Selected day info
          _buildSelectedDayHeader(),
          
          // Date records for selected day
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedDayRecords.isEmpty
                    ? _buildEmptyState()
                    : _buildDateRecordsList(),
          ),
        ],
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
  
  Widget _buildCalendar(DateRecordProvider dateRecordProvider) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      onPageChanged: _onPageChanged,
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: AppColors.primary,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: AppColors.primary,
        ),
      ),
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
      ),
      eventLoader: (day) {
        final date = DateTime(day.year, day.month, day.day);
        return dateRecordProvider.calendarRecords[date] ?? [];
      },
    );
  }
  
  Widget _buildSelectedDayHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Text(
            DateFormat('yyyy년 MM월 dd일').format(_selectedDay),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${_selectedDayRecords.length}개의 기록',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDateRecordsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedDayRecords.length,
      itemBuilder: (context, index) {
        final record = _selectedDayRecords[index];
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
                      Text(
                        record.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      _buildEmotionChip(record.emotion),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    record.memo.length > 100
                        ? '${record.memo.substring(0, 100)}...'
                        : record.memo,
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
      },
    );
  }
  
  Widget _buildEmotionChip(Emotion emotion) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getEmotionColor(emotion).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getEmotionIcon(emotion),
            size: 16,
            color: _getEmotionColor(emotion),
          ),
          const SizedBox(width: 4),
          Text(
            _getEmotionText(emotion),
            style: TextStyle(
              fontSize: 12,
              color: _getEmotionColor(emotion),
              fontWeight: FontWeight.bold,
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
            Icons.event_busy,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '이 날의 기록이 없어요.\n새로운 추억을 기록해보세요!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: '데이트 기록하기',
            onPressed: _createDateRecord,
            width: 200,
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
      default:
        return Colors.grey;
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
      default:
        return '보통';
    }
  }
}