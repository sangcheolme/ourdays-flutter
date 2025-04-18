import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/index.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/couple_provider.dart';
import '../settings/profile_edit_screen.dart';
import '../settings/couple_settings_screen.dart';
import '../settings/notification_settings_screen.dart';
import '../settings/app_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 3;
  
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
        Navigator.of(context).pushReplacementNamed('/memories');
        break;
      case 3:
        // Already on settings screen
        break;
    }
  }
  
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '로그아웃',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
  
  void _navigateToProfileEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileEditScreen(),
      ),
    );
  }
  
  void _navigateToCoupleSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CoupleSettingsScreen(),
      ),
    );
  }
  
  void _navigateToNotificationSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }
  
  void _navigateToAppSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AppSettingsScreen(),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final coupleProvider = Provider.of<CoupleProvider>(context);
    final user = userProvider.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // User profile section
          _buildProfileSection(user?.name ?? '사용자', user?.email ?? ''),
          
          const Divider(),
          
          // Settings sections
          _buildSettingsSection(
            '계정 설정',
            [
              _buildSettingItem(
                '프로필 수정',
                Icons.person,
                _navigateToProfileEdit,
              ),
              _buildSettingItem(
                '커플 설정',
                Icons.favorite,
                _navigateToCoupleSettings,
              ),
              _buildSettingItem(
                '로그아웃',
                Icons.logout,
                _logout,
                isDestructive: true,
              ),
            ],
          ),
          
          const Divider(),
          
          _buildSettingsSection(
            '앱 설정',
            [
              _buildSettingItem(
                '알림 설정',
                Icons.notifications,
                _navigateToNotificationSettings,
              ),
              _buildSettingItem(
                '앱 테마 및 언어',
                Icons.settings,
                _navigateToAppSettings,
              ),
            ],
          ),
          
          const Divider(),
          
          _buildSettingsSection(
            '정보',
            [
              _buildSettingItem(
                '앱 버전',
                Icons.info,
                () {},
                subtitle: '1.0.0',
                showArrow: false,
              ),
              _buildSettingItem(
                '개인정보 처리방침',
                Icons.privacy_tip,
                () {},
              ),
              _buildSettingItem(
                '이용약관',
                Icons.description,
                () {},
              ),
            ],
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
  
  Widget _buildProfileSection(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToProfileEdit,
            tooltip: '프로필 수정',
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
  
  Widget _buildSettingItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    String? subtitle,
    bool isDestructive = false,
    bool showArrow = true,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : null,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: showArrow ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}