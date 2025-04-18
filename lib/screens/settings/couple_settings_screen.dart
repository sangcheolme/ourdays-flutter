import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../constants/index.dart';
import '../../models/couple.dart';
import '../../providers/couple_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/index.dart';

class CoupleSettingsScreen extends StatefulWidget {
  const CoupleSettingsScreen({super.key});

  @override
  State<CoupleSettingsScreen> createState() => _CoupleSettingsScreenState();
}

class _CoupleSettingsScreenState extends State<CoupleSettingsScreen> {
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  void _initializeData() {
    final coupleProvider = Provider.of<CoupleProvider>(context, listen: false);
    final couple = coupleProvider.couple;
    
    if (couple != null) {
      _selectedDate = couple.anniversaryDate;
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
  
  Future<void> _updateCouple() async {
    if (_selectedDate == null) {
      setState(() {
        _errorMessage = '기념일을 선택해주세요.';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final coupleProvider = Provider.of<CoupleProvider>(context, listen: false);
      final couple = coupleProvider.couple;
      
      if (couple == null) {
        throw Exception('커플 정보를 찾을 수 없습니다.');
      }
      
      // Update couple
      final updatedCouple = Couple(
        id: couple.id,
        user1Id: couple.user1Id,
        user2Id: couple.user2Id,
        anniversaryDate: _selectedDate!,
        status: couple.status,
        createdAt: couple.createdAt,
        updatedAt: DateTime.now(),
      );

      final success = await coupleProvider.updateCouple(_selectedDate!);

      if (!mounted) return;
      
      if (success) {
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = '커플 정보 업데이트에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '오류가 발생했습니다: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _disconnectCouple() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('커플 연결 해제'),
        content: const Text('정말 커플 연결을 해제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '해제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final coupleProvider = Provider.of<CoupleProvider>(context, listen: false);
      final success = await coupleProvider.deleteCouple();
      
      if (!mounted) return;
      
      if (success) {
        Navigator.of(context).pushReplacementNamed('/couple-connection');
      } else {
        setState(() {
          _errorMessage = '커플 연결 해제에 실패했습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '오류가 발생했습니다: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final coupleProvider = Provider.of<CoupleProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final couple = coupleProvider.couple;
    final user = userProvider.user;
    
    if (couple == null || user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('커플 설정'),
          elevation: 0,
        ),
        body: const Center(
          child: Text('커플 정보를 불러올 수 없습니다.'),
        ),
      );
    }
    
    // Determine partner ID
    final partnerId = user.id == couple.user1Id ? couple.user2Id : couple.user1Id;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('커플 설정'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateCouple,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Couple info card
            _buildCoupleInfoCard(couple, partnerId),
            const SizedBox(height: 24),
            
            // Anniversary date picker
            const Text(
              '기념일',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDatePicker(),
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
              onPressed: _isLoading ? null : _updateCouple,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 32),
            
            // Disconnect button
            CustomButton(
              text: '커플 연결 해제',
              onPressed: _isLoading ? null : _disconnectCouple,
              isLoading: _isLoading,
              isOutlined: true,
              textColor: AppColors.error,
              backgroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCoupleInfoCard(Couple couple, String partnerId) {
    return Card(
      elevation: 2,
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
                        '우리의 ${couple.daysSinceAnniversary}일째',
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
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text(
                  '파트너:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '파트너 정보 로딩 중...', // In a real app, this would be the partner's name
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text(
                  '다음 기념일:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${couple.daysUntilNextAnniversary}일 남음',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
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
                  '기념일',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedDate != null
                      ? DateFormat('yyyy년 MM월 dd일').format(_selectedDate!)
                      : '날짜를 선택하세요',
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
}