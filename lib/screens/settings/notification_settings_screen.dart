import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/index.dart';
import '../../widgets/index.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  
  // Notification settings
  bool _anniversaryNotifications = true;
  bool _specialDateNotifications = true;
  bool _commentNotifications = true;
  bool _partnerActivityNotifications = true;
  bool _appUpdateNotifications = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // In a real app, these settings would be loaded from a user preferences API
      // For now, we'll use shared preferences
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _anniversaryNotifications = prefs.getBool('anniversary_notifications') ?? true;
        _specialDateNotifications = prefs.getBool('special_date_notifications') ?? true;
        _commentNotifications = prefs.getBool('comment_notifications') ?? true;
        _partnerActivityNotifications = prefs.getBool('partner_activity_notifications') ?? true;
        _appUpdateNotifications = prefs.getBool('app_update_notifications') ?? true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '설정을 불러오는 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // In a real app, these settings would be saved to a user preferences API
      // For now, we'll use shared preferences
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('anniversary_notifications', _anniversaryNotifications);
      await prefs.setBool('special_date_notifications', _specialDateNotifications);
      await prefs.setBool('comment_notifications', _commentNotifications);
      await prefs.setBool('partner_activity_notifications', _partnerActivityNotifications);
      await prefs.setBool('app_update_notifications', _appUpdateNotifications);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 설정이 저장되었습니다.')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = '설정을 저장하는 중 오류가 발생했습니다: $e';
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
        title: const Text('알림 설정'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSettings,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  
                  // Notification settings
                  const Text(
                    '알림 설정',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Anniversary notifications
                  _buildNotificationSetting(
                    '기념일 알림',
                    '기념일이 다가오면 알림을 받습니다.',
                    _anniversaryNotifications,
                    (value) {
                      setState(() {
                        _anniversaryNotifications = value;
                      });
                    },
                  ),
                  
                  // Special date notifications
                  _buildNotificationSetting(
                    '특별한 날 알림',
                    '특별한 날이 다가오면 알림을 받습니다.',
                    _specialDateNotifications,
                    (value) {
                      setState(() {
                        _specialDateNotifications = value;
                      });
                    },
                  ),
                  
                  // Comment notifications
                  _buildNotificationSetting(
                    '댓글 알림',
                    '파트너가 댓글을 남기면 알림을 받습니다.',
                    _commentNotifications,
                    (value) {
                      setState(() {
                        _commentNotifications = value;
                      });
                    },
                  ),
                  
                  // Partner activity notifications
                  _buildNotificationSetting(
                    '파트너 활동 알림',
                    '파트너가 새로운 데이트 기록을 추가하면 알림을 받습니다.',
                    _partnerActivityNotifications,
                    (value) {
                      setState(() {
                        _partnerActivityNotifications = value;
                      });
                    },
                  ),
                  
                  // App update notifications
                  _buildNotificationSetting(
                    '앱 업데이트 알림',
                    '새로운 앱 업데이트가 있을 때 알림을 받습니다.',
                    _appUpdateNotifications,
                    (value) {
                      setState(() {
                        _appUpdateNotifications = value;
                      });
                    },
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
                    onPressed: _isLoading ? null : _saveSettings,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '알림 설정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '중요한 순간을 놓치지 않도록 알림을 설정하세요.',
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
      ),
    );
  }
  
  Widget _buildNotificationSetting(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
}