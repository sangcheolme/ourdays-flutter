import 'package:flutter/foundation.dart';

import '../models/date_record.dart';
import '../services/date_record_service.dart';

class DateRecordProvider with ChangeNotifier {
  final DateRecordService _dateRecordService;
  
  List<DateRecord> _dateRecords = [];
  Map<DateTime, List<DateRecord>> _calendarRecords = {};
  DateRecord? _currentDateRecord;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  int _currentPage = 1;
  bool _hasMorePages = true;
  
  DateRecordProvider(this._dateRecordService);
  
  List<DateRecord> get dateRecords => _dateRecords;
  Map<DateTime, List<DateRecord>> get calendarRecords => _calendarRecords;
  DateRecord? get currentDateRecord => _currentDateRecord;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  bool get hasMorePages => _hasMorePages;
  
  // Update provider state based on authentication
  void update(bool isAuthenticated, String? token) {
    if (isAuthenticated && token != null && !_isInitialized) {
      _fetchDateRecords();
      _fetchCalendarRecords();
    } else if (!isAuthenticated) {
      _dateRecords = [];
      _calendarRecords = {};
      _currentDateRecord = null;
      _isInitialized = false;
      _currentPage = 1;
      _hasMorePages = true;
      notifyListeners();
    }
  }
  
  // Fetch date records
  Future<void> _fetchDateRecords({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePages = true;
    }
    
    if (!_hasMorePages && !refresh) return;
    
    _setLoading(true);
    
    try {
      final response = await _dateRecordService.getDateRecords(
        page: _currentPage,
        limit: 10,
      );
      
      if (refresh) {
        _dateRecords = response;
      } else {
        _dateRecords = [..._dateRecords, ...response];
      }

      _hasMorePages = response.length >= 10;
      _currentPage++;
      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = 'Failed to load date records: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Fetch calendar records
  Future<void> _fetchCalendarRecords({DateTime? month}) async {
    _setLoading(true);
    
    try {
      final now = DateTime.now();
      final targetMonth = month ?? DateTime(now.year, now.month);
      
      final records = await _dateRecordService.getCalendarRecords(
        year: targetMonth.year,
        month: targetMonth.month,
      );
      
      // Group by date
      final Map<DateTime, List<DateRecord>> grouped = {};
      for (var record in records) {
        final date = DateTime(record.date.year, record.date.month, record.date.day);
        if (!grouped.containsKey(date)) {
          grouped[date] = [];
        }
        grouped[date]!.add(record);
      }
      
      if (month != null) {
        // Update only the requested month
        _calendarRecords.addAll(grouped);
      } else {
        _calendarRecords = grouped;
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to load calendar records: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Load more date records
  Future<void> loadMoreDateRecords() async {
    if (!_hasMorePages || _isLoading) return;
    await _fetchDateRecords();
  }
  
  // Refresh date records
  Future<void> refreshDateRecords() async {
    await _fetchDateRecords(refresh: true);
  }
  
  // Load calendar records for a specific month
  Future<void> loadCalendarMonth(DateTime month) async {
    final targetMonth = DateTime(month.year, month.month);
    
    // Check if we already have data for this month
    bool hasMonth = false;
    for (var date in _calendarRecords.keys) {
      if (date.year == targetMonth.year && date.month == targetMonth.month) {
        hasMonth = true;
        break;
      }
    }
    
    if (!hasMonth) {
      await _fetchCalendarRecords(month: targetMonth);
    }
  }
  
  // Get date record by ID
  Future<void> getDateRecord(String id) async {
    _setLoading(true);
    
    try {
      final record = await _dateRecordService.getDateRecord(id);
      _currentDateRecord = record;
      _error = null;
    } catch (e) {
      _error = 'Failed to load date record: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Create date record
  Future<bool> createDateRecord(DateRecord dateRecord) async {
    _setLoading(true);
    
    try {
      final record = await _dateRecordService.createDateRecord(dateRecord);
      _dateRecords = [record, ..._dateRecords];
      
      // Update calendar records
      final date = DateTime(record.date.year, record.date.month, record.date.day);
      if (!_calendarRecords.containsKey(date)) {
        _calendarRecords[date] = [];
      }
      _calendarRecords[date]!.add(record);
      
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to create date record: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update date record
  Future<bool> updateDateRecord(DateRecord dateRecord) async {
    _setLoading(true);
    
    try {
      final record = await _dateRecordService.updateDateRecord(dateRecord);
      
      // Update in list
      final index = _dateRecords.indexWhere((r) => r.id == record.id);
      if (index >= 0) {
        _dateRecords[index] = record;
      }
      
      // Update in calendar
      final oldDate = _currentDateRecord?.date;
      final newDate = record.date;
      
      if (oldDate != null && 
          (oldDate.year != newDate.year || 
           oldDate.month != newDate.month || 
           oldDate.day != newDate.day)) {
        // Date changed, update both old and new dates in calendar
        final oldDateKey = DateTime(oldDate.year, oldDate.month, oldDate.day);
        final newDateKey = DateTime(newDate.year, newDate.month, newDate.day);
        
        if (_calendarRecords.containsKey(oldDateKey)) {
          _calendarRecords[oldDateKey]!.removeWhere((r) => r.id == record.id);
          if (_calendarRecords[oldDateKey]!.isEmpty) {
            _calendarRecords.remove(oldDateKey);
          }
        }
        
        if (!_calendarRecords.containsKey(newDateKey)) {
          _calendarRecords[newDateKey] = [];
        }
        _calendarRecords[newDateKey]!.add(record);
      } else {
        // Same date, just update the record
        final dateKey = DateTime(newDate.year, newDate.month, newDate.day);
        if (_calendarRecords.containsKey(dateKey)) {
          final calIndex = _calendarRecords[dateKey]!.indexWhere((r) => r.id == record.id);
          if (calIndex >= 0) {
            _calendarRecords[dateKey]![calIndex] = record;
          } else {
            _calendarRecords[dateKey]!.add(record);
          }
        }
      }
      
      _currentDateRecord = record;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to update date record: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete date record
  Future<bool> deleteDateRecord(String id) async {
    _setLoading(true);
    
    try {
      await _dateRecordService.deleteDateRecord(id);
      
      // Remove from list
      _dateRecords.removeWhere((record) => record.id == id);
      
      // Remove from calendar
      for (var date in _calendarRecords.keys) {
        _calendarRecords[date]!.removeWhere((record) => record.id == id);
        if (_calendarRecords[date]!.isEmpty) {
          _calendarRecords.remove(date);
        }
      }
      
      if (_currentDateRecord?.id == id) {
        _currentDateRecord = null;
      }
      
      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to delete date record: $e';
      debugPrint(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Get recent date records
  Future<List<DateRecord>> getRecentDateRecords({int limit = 5}) async {
    try {
      return await _dateRecordService.getRecentDateRecords(limit: limit);
    } catch (e) {
      _error = 'Failed to load recent date records: $e';
      debugPrint(_error);
      return [];
    }
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}