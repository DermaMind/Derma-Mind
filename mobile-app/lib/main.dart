import 'package:dermamind_app/product_screen/product_screen.dart';
import 'package:dermamind_app/services/notification_service.dart';
import 'package:dermamind_app/Authentication/forget_password_screen.dart';
import 'package:dermamind_app/Authentication/register.dart';
import 'package:dermamind_app/Authentication/reset_password_screen.dart';
import 'package:dermamind_app/Authentication/verify_otp_screen.dart';
import 'package:dermamind_app/chatbot/chatbot_screen.dart';
import 'package:dermamind_app/HomeScreen/HomeScreen.dart';
import 'package:dermamind_app/doctors/doctors_screen.dart';
import 'package:dermamind_app/notifications/notifications_screen.dart';
import 'package:dermamind_app/cart/cart_screen.dart';
import 'package:dermamind_app/providers/auth_provider.dart';
import 'package:dermamind_app/providers/cart_provider.dart';
import 'package:dermamind_app/providers/favorites_provider.dart';
import 'package:dermamind_app/providers/locale_provider.dart';
import 'package:dermamind_app/providers/notification_provider.dart';
import 'package:dermamind_app/providers/scan_history_provider.dart';
import 'package:dermamind_app/providers/skin_test_provider.dart';
import 'package:dermamind_app/providers/theme_provider.dart';
import 'package:dermamind_app/settings/faq_screen.dart';
import 'package:dermamind_app/settings/settings_screen.dart';
import 'package:dermamind_app/settings/edit_profile_screen.dart';
import 'package:dermamind_app/settings/terms_privacy_screen.dart';
import 'package:dermamind_app/payment/paymob_payment_screen.dart';
import 'package:dermamind_app/models/checkout_response_model.dart';
import 'package:dermamind_app/Scan_Screen/scan_followup_screen.dart';
import 'package:dermamind_app/Scan_Screen/scan_result_screen.dart';
import 'package:dermamind_app/skin_test/Question_screen.dart';
import 'package:dermamind_app/skin_test/sucessedScreen.dart';
import 'package:dermamind_app/utils/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Authentication/login.dart';
import 'HomeScreen/wiidget/main_layout.dart';
import 'Scan_Screen/camera_scan.dart';
import 'Scan_Screen/scan_face_screen.dart';
import 'Scan_Screen/scan_history_screen.dart';
import 'l10n/app_localizations.dart';
import 'splash/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService.initialize();
    await NotificationService.requestPermission();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }
  final authProvider = AuthProvider();
  await authProvider.loadFromPrefs();
  final skinTestProvider = SkinTestProvider();
  await skinTestProvider.loadFromPrefs();
  final notificationProvider = NotificationProvider();
  await notificationProvider.loadFromPrefs();
  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFromPrefs();
  final themeProvider = ThemeProvider();
  await themeProvider.loadFromPrefs();
  final localeProvider = LocaleProvider();
  await localeProvider.loadFromPrefs();
  final scanHistoryProvider = ScanHistoryProvider();
  await scanHistoryProvider.loadHistory();
  runApp(MyApp(
    authProvider: authProvider,
    skinTestProvider: skinTestProvider,
    scanHistoryProvider: scanHistoryProvider,
    notificationProvider: notificationProvider,
    favoritesProvider: favoritesProvider,
    themeProvider: themeProvider,
    localeProvider: localeProvider,
  ));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  final SkinTestProvider skinTestProvider;
  final ScanHistoryProvider scanHistoryProvider;
  final NotificationProvider notificationProvider;
  final FavoritesProvider favoritesProvider;
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;

  const MyApp({
    super.key,
    required this.authProvider,
    required this.skinTestProvider,
    required this.scanHistoryProvider,
    required this.notificationProvider,
    required this.favoritesProvider,
    required this.themeProvider,
    required this.localeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<SkinTestProvider>.value(value: skinTestProvider),
        ChangeNotifierProvider<ScanHistoryProvider>.value(value: scanHistoryProvider),
        ChangeNotifierProvider<NotificationProvider>.value(value: notificationProvider),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<FavoritesProvider>.value(value: favoritesProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),

      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeP, localeP, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: SplashScreen.routeName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeP.themeMode,
          locale: localeP.locale,
          routes: {
            SplashScreen.routeName: (context) => const SplashScreen(),
            LoginScreen.RoutName: (context) => LoginScreen(),
            RegisterScreen.RoutName: (context) => RegisterScreen(),
            QuestionScreen.RoutName: (context) => QuestionScreen(),
            SuccessScreen.RoutName: (context) => SuccessScreen(),
            ScanHistoryScreen.routeName: (context) => const ScanHistoryScreen(),
            HomeScreen.RoutName: (context) => HomeScreen(),
            mainLayout.routeName: (context) => mainLayout(),
            ProductsScreen.routeName: (context) => ProductsScreen(),
            ScanFaceScreen.routeName: (context) => ScanFaceScreen(),
            CameraScreen.routeName: (context) => const CameraScreen(),
            ScanFollowupScreen.routeName: (context) => const ScanFollowupScreen(),
            ScanResultScreen.routeName: (context) => const ScanResultScreen(),
            DoctorsScreen.routeName: (context) => const DoctorsScreen(),
            NotificationsScreen.routeName: (context) => const NotificationsScreen(),
            SettingsScreen.routeName: (context) => const SettingsScreen(),
            EditProfileScreen.routeName: (context) => const EditProfileScreen(),
            CartScreen.routeName: (context) => const CartScreen(),
            PaymobPaymentScreen.routeName: (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as CheckoutResponseModel?;
              return PaymobPaymentScreen(
                paymentUrl: args?.paymentUrl ?? '',
                orderId: args?.orderId,
              );
            },
            ChatbotScreen.routeName: (context) => const ChatbotScreen(),
            ForgetPasswordScreen.routeName: (context) => const ForgetPasswordScreen(),
            VerifyOtpScreen.routeName: (context) => const VerifyOtpScreen(),
            ResetPasswordScreen.routeName: (context) => const ResetPasswordScreen(),
            FaqScreen.routeName: (context) => const FaqScreen(),
            TermsPrivacyScreen.routeName: (context) => const TermsPrivacyScreen(),
          },
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }
}
