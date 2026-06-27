import 'package:dermamind_app/Authentication/forget_password_screen.dart';
import 'package:dermamind_app/Authentication/login.dart';
import 'package:dermamind_app/HomeScreen/wiidget/SlidePageRoute.dart';
import 'package:dermamind_app/providers/auth_provider.dart';
import 'package:dermamind_app/providers/locale_provider.dart';
import 'package:dermamind_app/providers/notification_provider.dart';
import 'package:dermamind_app/providers/skin_test_provider.dart';
import 'package:dermamind_app/providers/theme_provider.dart';
import 'package:dermamind_app/settings/edit_profile_screen.dart';
import 'package:dermamind_app/settings/faq_screen.dart';
import 'package:dermamind_app/settings/terms_privacy_screen.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = 'settingsScreen';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Language picker ────────────────────────────────────────────────────────

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final currentLocale = context.read<LocaleProvider>().locale;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Text(
                'Select Language',
                style: AppStyle.semi40linear.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _LanguageOption(
                label: 'English',
                nativeLabel: 'English',
                selected: currentLocale.languageCode == 'en',
                onTap: () async {
                  Navigator.pop(ctx);
                  await context
                      .read<LocaleProvider>()
                      .setLocale(const Locale('en'));
                },
              ),
              const SizedBox(height: 8),
              _LanguageOption(
                label: 'Arabic',
                nativeLabel: 'العربية',
                selected: currentLocale.languageCode == 'ar',
                onTap: () async {
                  Navigator.pop(ctx);
                  await context
                      .read<LocaleProvider>()
                      .setLocale(const Locale('ar'));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Contact Support ────────────────────────────────────────────────────────

  Future<void> _launchSupportEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@dermamind.app',
      query: 'subject=DermaMind Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open email app'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeCode =
        context.watch<LocaleProvider>().locale.languageCode;
    final languageLabel = localeCode == 'ar' ? 'العربية' : 'English';
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.blueColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: AppStyle.semi40linear
              .copyWith(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── User card ────────────────────────────────────────────────────
          _buildUserCard(context, auth),
          const SizedBox(height: 24),

          // ── PREFERENCES ──────────────────────────────────────────────────
          _sectionLabel('PREFERENCES'),
          const SizedBox(height: 8),
          _sectionCard(children: [
            _ToggleItem(
              icon: Icons.notifications_outlined,
              iconColor: AppColor.blueColor,
              iconBg: const Color(0xFFEFF6FF),
              title: 'Push Notifications',
              subtitle: 'Scan reminders, tips',
              value: context.watch<NotificationProvider>().pushNotifications,
              onChanged: (v) => context
                  .read<NotificationProvider>()
                  .togglePushNotifications(v),
            ),
            _divider(),
            _ToggleItem(
              icon: Icons.bar_chart_outlined,
              iconColor: const Color(0xFF8B5CF6),
              iconBg: const Color(0xFFF5F3FF),
              title: 'Weekly Skin Report',
              subtitle: 'Every Sunday at 9:00 AM',
              value: context.watch<NotificationProvider>().weeklyReport,
              onChanged: (v) =>
                  context.read<NotificationProvider>().toggleWeeklyReport(v),
            ),
            _divider(),
            _ToggleItem(
              icon: Icons.dark_mode_outlined,
              iconColor: AppColor.grayColor,
              iconBg: const Color(0xFFF3F4F6),
              title: 'Dark Mode',
              subtitle: 'Use system default',
              value: context.watch<ThemeProvider>().isDarkMode,
              onChanged: (v) =>
                  context.read<ThemeProvider>().toggleDarkMode(v),
            ),
          ]),
          const SizedBox(height: 20),

          // ── ACCOUNT ───────────────────────────────────────────────────────
          _sectionLabel('ACCOUNT'),
          const SizedBox(height: 8),
          _sectionCard(children: [
            _ToggleItem(
              icon: Icons.fingerprint,
              iconColor: const Color(0xFF10B981),
              iconBg: const Color(0xFFF0FDF4),
              title: 'Biometric Sign-in',
              subtitle: 'Coming soon',
              value: false,
              onChanged: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Biometric sign-in coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            _divider(),
            _ArrowItem(
              icon: Icons.language_outlined,
              iconColor: AppColor.blueColor,
              iconBg: const Color(0xFFEFF6FF),
              title: 'Language',
              trailing: languageLabel,
              onTap: _showLanguagePicker,
            ),
            _divider(),
            _ArrowItem(
              icon: Icons.lock_outline,
              iconColor: AppColor.grayColor,
              iconBg: const Color(0xFFF3F4F6),
              title: 'Change Password',
              onTap: () => Navigator.pushNamed(
                context,
                ForgetPasswordScreen.routeName,
                arguments: {
                  'email': auth.email,
                  'prefilled': true,
                },
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // ── SUPPORT ───────────────────────────────────────────────────────
          _sectionLabel('SUPPORT'),
          const SizedBox(height: 8),
          _sectionCard(children: [
            _ArrowItem(
              icon: Icons.help_outline,
              iconColor: const Color(0xFFF97316),
              iconBg: const Color(0xFFFFF7ED),
              title: 'Help & FAQ',
              onTap: () =>
                  Navigator.pushNamed(context, FaqScreen.routeName),
            ),
            _divider(),
            _ArrowItem(
              icon: Icons.support_agent_outlined,
              iconColor: const Color(0xFF8B5CF6),
              iconBg: const Color(0xFFF5F3FF),
              title: 'Contact Support',
              trailing: 'support@dermamind.app',
              onTap: _launchSupportEmail,
            ),
            _divider(),
            _ArrowItem(
              icon: Icons.description_outlined,
              iconColor: AppColor.grayColor,
              iconBg: const Color(0xFFF3F4F6),
              title: 'Terms & Privacy',
              onTap: () =>
                  Navigator.pushNamed(context, TermsPrivacyScreen.routeName),
            ),
          ]),
          const SizedBox(height: 20),

          // ── ACCOUNT ACTIONS ───────────────────────────────────────────────
          _sectionLabel('ACCOUNT ACTIONS'),
          const SizedBox(height: 8),
          _sectionCard(children: [
            _ArrowItem(
              icon: Icons.logout,
              iconColor: Colors.red,
              iconBg: const Color(0xFFFFE4E4),
              title: 'Logout',
              titleColor: Colors.red,
              trailingColor: Colors.red,
              onTap: () async {
                await context.read<SkinTestProvider>().clearResult();
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    LoginScreen.RoutName,
                    (route) => false,
                  );
                }
              },
            ),
          ]),
          const SizedBox(height: 24),

          // ── Version ───────────────────────────────────────────────────────
          Center(
            child: Text(
              'Version 1.0.0 · Build 2701',
              style: AppStyle.regular.copyWith(
                color: AppColor.grayColor,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── User card ──────────────────────────────────────────────────────────────

  Widget _buildUserCard(BuildContext context, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.white2Color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.blueColor.withValues(alpha: 0.12),
              border: Border.all(
                  color: AppColor.blueColor.withValues(alpha: 0.3),
                  width: 2),
            ),
            child: const Icon(Icons.person,
                color: AppColor.blueColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.userName.isNotEmpty ? auth.userName : 'User',
                  style: AppStyle.regular.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  auth.email.isNotEmpty ? auth.email : '',
                  style: AppStyle.regular.copyWith(
                    color: AppColor.grayColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              SlidePageRoute(page: const EditProfileScreen()),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColor.blueColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Edit',
                style: AppStyle.regular.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: AppStyle.regular.copyWith(
          color: AppColor.grayColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white2Color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        indent: 58,
        color: Colors.grey.shade100,
      );
}

// ── Toggle item ───────────────────────────────────────────────────────────────

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyle.regular.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppStyle.regular.copyWith(
                      color: AppColor.grayColor,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColor.blueColor,
            activeTrackColor: AppColor.blueColor.withValues(alpha: 0.4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// ── Arrow item ────────────────────────────────────────────────────────────────

class _ArrowItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final Color? titleColor;
  final String? trailing;
  final Color? trailingColor;
  final VoidCallback onTap;

  const _ArrowItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.titleColor,
    this.trailing,
    this.trailingColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppStyle.regular.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? AppColor.blackColor,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: AppStyle.regular.copyWith(
                  color: trailingColor ?? AppColor.grayColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.chevron_right,
              color: trailingColor ?? AppColor.grayColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Language option ────────────────────────────────────────────────────────────

class _LanguageOption extends StatelessWidget {
  final String label;
  final String nativeLabel;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.nativeLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.blueColor.withValues(alpha: 0.07)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColor.blueColor.withValues(alpha: 0.3)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppStyle.regular.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColor.blueColor
                          : AppColor.blackColor,
                    ),
                  ),
                  Text(
                    nativeLabel,
                    style: AppStyle.regular.copyWith(
                      fontSize: 12,
                      color: AppColor.grayColor,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColor.blueColor, size: 20),
          ],
        ),
      ),
    );
  }
}
