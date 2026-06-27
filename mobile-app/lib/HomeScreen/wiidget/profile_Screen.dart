import 'package:dermamind_app/Authentication/login.dart';
import 'package:dermamind_app/HomeScreen/wiidget/SlidePageRoute.dart';
import 'package:dermamind_app/providers/auth_provider.dart';
import 'package:dermamind_app/providers/skin_test_provider.dart';
import 'package:dermamind_app/settings/settings_screen.dart';
import 'package:dermamind_app/skin_test/Question_screen.dart';
import 'package:dermamind_app/skin_test/sucessedScreen.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:dermamind_app/utils/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../Scan_Screen/scan_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColor.blueColor,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Blue top section ───────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.38,
              child: _buildBlueHeader(context, l10n),
            ),

            // ── White panel (slides up, overlaps blue) ─────────────────────
            Positioned(
              top: screenHeight * 0.30,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: _buildMenuList(context, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Blue header: avatar + name + stat cards ────────────────────────────────

  Widget _buildBlueHeader(BuildContext context, AppLocalizations l10n) {
    final auth = context.watch<AuthProvider>();
    final skinTest = context.watch<SkinTestProvider>();
    final hasResult = skinTest.hasSkinResult;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Avatar
          ProfileAvatar(
            networkUrl: auth.profileImageUrl,
            size: 80,
          ),
          const SizedBox(height: 10),
          // Name
          Text(
            auth.userName.isNotEmpty ? auth.userName : 'there',
            style: AppStyle.nameLinear.copyWith(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 14),
          // Stat cards row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _StatCard(
                    value: hasResult ? skinTest.skinType : '—',
                    label: l10n.skinType,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    value: hasResult ? skinTest.skinHistory : l10n.notTakenYet,
                    label: l10n.skinHistory,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    value: hasResult ? skinTest.lastScan : '—',
                    label: l10n.lastScan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Menu list ──────────────────────────────────────────────────────────────

  Widget _buildMenuList(BuildContext context, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        _MenuItem(
          icon: Icons.person_outline,
          iconColor: AppColor.blueColor,
          iconBg: const Color(0xFFEFF6FF),
          title: l10n.mySkinProfile,
          onTap: () => Navigator.pushNamed(
            context,
            ScanHistoryScreen.routeName,
          ),
        ),
        _MenuItem(
          icon: Icons.assignment_outlined,
          iconColor: const Color(0xFF8B5CF6),
          iconBg: const Color(0xFFF5F3FF),
          title: l10n.retakeSkinTest,
          onTap: () {
            context.read<SkinTestProvider>().resetTest();
            Navigator.pushNamed(context, QuestionScreen.RoutName);
          },
        ),
        _MenuItem(
          icon: Icons.settings_outlined,
          iconColor: AppColor.grayColor,
          iconBg: const Color(0xFFF3F4F6),
          title: l10n.settingsPrivacy,
          onTap: () => Navigator.push(
            context,
            SlidePageRoute(page: const SettingsScreen()),
          ),
        ),
        _MenuItem(
          icon: Icons.help_outline,
          iconColor: const Color(0xFFF97316),
          iconBg: const Color(0xFFFFF7ED),
          title: 'FAQs',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Coming soon!'),
              duration: Duration(seconds: 2),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _LogoutTile(label: l10n.logout),
      ],
    );
  }
}

// ── Stat card (inside blue header) ────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppStyle.regular.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppStyle.regular.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu item ─────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white2Color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: AppStyle.regular.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right,
            color: AppColor.grayColor, size: 22),
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ── Logout tile ───────────────────────────────────────────────────────────────

class _LogoutTile extends StatelessWidget {
  final String label;

  const _LogoutTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE4E4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.logout, color: Colors.red, size: 20),
        ),
        title: Text(
          label,
          style: AppStyle.regular.copyWith(
            color: Colors.red,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
