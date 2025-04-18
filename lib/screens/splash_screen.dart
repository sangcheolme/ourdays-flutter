import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/index.dart';
import '../providers/auth_provider.dart';
import '../providers/couple_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Delay for splash screen animation
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      // User is authenticated, check if they have a couple
      final coupleProvider = Provider.of<CoupleProvider>(context, listen: false);
      
      // Wait for couple data to load
      if (!coupleProvider.isInitialized) {
        await Future.delayed(const Duration(seconds: 1));
      }
      
      if (!mounted) return;
      
      if (coupleProvider.hasCouple) {
        // User has a couple, navigate to home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // User doesn't have a couple, navigate to couple connection
        Navigator.of(context).pushReplacementNamed('/couple-connection');
      }
    } else {
      // User is not authenticated, navigate to login
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.favorite,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            // App name
            Text(
              AppStrings.appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}