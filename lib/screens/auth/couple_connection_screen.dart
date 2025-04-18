import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../constants/index.dart';
import '../../providers/couple_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/index.dart';

class CoupleConnectionScreen extends StatefulWidget {
  const CoupleConnectionScreen({super.key});

  @override
  State<CoupleConnectionScreen> createState() => _CoupleConnectionScreenState();
}

class _CoupleConnectionScreenState extends State<CoupleConnectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _inviteFormKey = GlobalKey<FormState>();
  final _acceptFormKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  String? _generatedInviteCode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
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

  Future<void> _createInvite() async {
    if (!_inviteFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _generatedInviteCode = null;
    });

    try {
      final coupleProvider = Provider.of<CoupleProvider>(context, listen: false);
      final success = await coupleProvider.createInviteCode(_selectedDate);

      if (!mounted) return;

      if (success) {
        setState(() {
          _generatedInviteCode = coupleProvider.inviteCode;
        });
      } else {
        setState(() {
          _errorMessage = '초대 코드 생성에 실패했습니다. 다시 시도해주세요.';
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

  Future<void> _acceptInvite() async {
    if (!_acceptFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final coupleProvider = Provider.of<CoupleProvider>(context, listen: false);
      final success = await coupleProvider.acceptInvite(_inviteCodeController.text.trim(), _selectedDate);

      if (!mounted) return;

      if (success) {
        // Navigate to home screen
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          _errorMessage = '초대 코드가 유효하지 않습니다. 다시 확인해주세요.';
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

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('커플 연결'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: '로그아웃',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '초대 코드 생성'),
            Tab(text: '초대 코드 입력'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Create invite code tab
          _buildCreateInviteTab(),

          // Accept invite code tab
          _buildAcceptInviteTab(),
        ],
      ),
    );
  }

  Widget _buildCreateInviteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _inviteFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '커플 연결을 위해 기념일을 선택하고 초대 코드를 생성하세요.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Anniversary date picker
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 16),
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
                          DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Error message
            if (_errorMessage != null && _generatedInviteCode == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Generated invite code
            if (_generatedInviteCode != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Column(
                  children: [
                    const Text(
                      '초대 코드가 생성되었습니다!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _generatedInviteCode!,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '이 코드를 파트너에게 공유하세요.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

            // Create invite button
            CustomButton(
              text: '초대 코드 생성',
              onPressed: _isLoading ? null : _createInvite,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptInviteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _acceptFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '파트너로부터 받은 초대 코드를 입력하세요.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Invite code field
            CustomTextField(
              controller: _inviteCodeController,
              labelText: '초대 코드',
              hintText: '초대 코드를 입력하세요',
              prefixIcon: Icons.vpn_key,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '초대 코드를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Accept invite button
            CustomButton(
              text: '초대 수락',
              onPressed: _isLoading ? null : _acceptInvite,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
