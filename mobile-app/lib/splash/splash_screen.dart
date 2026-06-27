import 'package:dermamind_app/Authentication/login.dart';
import 'package:dermamind_app/HomeScreen/wiidget/main_layout.dart';
import 'package:dermamind_app/providers/auth_provider.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/assets_Maneger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = 'splash_screen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _splashDuration = Duration(seconds: 5);

  late final AnimationController _logoController;
  late final Animation<double> _slideX;
  late final Animation<double> _slideY;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _slideX = Tween<double>(begin: -0.55, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _slideY = Tween<double>(begin: -0.45, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _logoScale = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _logoController.forward();
    Future.delayed(_splashDuration, _navigateNext);
  }

  void _navigateNext() {
    if (!mounted) return;
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
    Navigator.pushReplacementNamed(
      context,
      isLoggedIn ? mainLayout.routeName : LoginScreen.RoutName,
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.primaryColor,
              Color(0xFFEAF2FB),
              AppColor.white2Color,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _logoController,
            builder: (context, child) {
              return Opacity(
                opacity: _logoOpacity.value,
                child: Transform.translate(
                  offset: Offset(
                    _slideX.value * size.width,
                    _slideY.value * size.height,
                  ),
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: child,
                  ),
                ),
              );
            },
            child: Image.asset(
              AssetsManager.logo,
              height: size.height * 0.22,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
