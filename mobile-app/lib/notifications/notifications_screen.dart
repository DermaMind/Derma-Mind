import 'package:dermamind_app/Scan_Screen/scan_result_screen.dart';
import 'package:dermamind_app/doctors/doctors_screen.dart';
import 'package:dermamind_app/product_screen/product_screen.dart';
import 'package:dermamind_app/providers/notification_provider.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../HomeScreen/wiidget/main_layout.dart';
import '../l10n/app_localizations.dart';
import 'notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = 'notificationsScreen';

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationCategory _selectedFilter = NotificationCategory.all;
  late List<NotificationModel> _notifications;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifications = _buildDummyData(context);
  }

  List<NotificationModel> _buildDummyData(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return [
      NotificationModel(
        id: '1',
        title: isAr ? 'نتائج الفحص جاهزة!' : 'Scan Results Ready!',
        body: isAr
            ? 'تم اكتمال تحليل بشرتك. تم اكتشاف مناطق إكزيما خفيفة.'
            : 'Your skin scan analysis is complete. Mild acne-prone areas detected.',
        timestamp: isAr ? 'منذ ٢ دقيقة' : '2m ago',
        isRead: false,
        icon: Icons.document_scanner_outlined,
        iconBg: const Color(0xFFE8F0FE),
        iconColor: AppColor.blueColor,
        isToday: true,
        actionLabel: isAr ? 'عرض النتائج' : 'View Results',
      ),
      NotificationModel(
        id: '2',
        title: isAr ? 'نصيحة للعناية بالبشرة ☀️' : 'Skincare Tip For You ☀️',
        body: isAr
            ? 'هل تعلم؟ تطبيق SPF يوميًا يقلل خطر فرط التصبغ بنسبة 80%.'
            : 'Did you know? Applying SPF every morning reduces the risk of hyperpigmentation by up to 80%!',
        timestamp: isAr ? 'منذ ٣ ساعات' : '3h ago',
        isRead: false,
        icon: Icons.lightbulb_outline_rounded,
        iconBg: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFF59E0B),
        isToday: true,
        actionLabel: null,
      ),
      NotificationModel(
        id: '3',
        title: isAr ? 'تذكير الروتين الصباحي' : 'Morning Routine Reminder',
        body: isAr
            ? 'حان وقت روتين العناية الصباحي! لا تنسَ واقي الشمس اليوم.'
            : 'Time for your morning skincare routine! Don\'t forget your SPF today.',
        timestamp: isAr ? 'الساعة ٩:٠٠ صباحًا' : '9:00 AM',
        isRead: true,
        icon: Icons.alarm_outlined,
        iconBg: const Color(0xFFD1FAE5),
        iconColor: const Color(0xFF10B981),
        isToday: true,
        actionLabel: isAr ? 'عرض الروتين' : 'View Routine',
        isReminder: true,
      ),
      NotificationModel(
        id: '4',
        title: isAr ? 'عرض خاص 25% خصم!' : 'Special Offer 25% Off!',
        body: isAr
            ? 'بعض المنتجات بخصم 25% اليوم فقط. المنتجات الموصى بها لنوع بشرتك OSPT معروضة للبيع!'
            : 'Certain products are 25% off today only. Products recommended for your OSPT skin type are on sale!',
        timestamp: isAr ? 'أمس' : 'Yesterday',
        isRead: true,
        icon: Icons.local_offer_outlined,
        iconBg: const Color(0xFFD1FAE5),
        iconColor: const Color(0xFF10B981),
        isToday: false,
        actionLabel: isAr ? 'تسوق الآن' : 'Shop Now',
      ),
      NotificationModel(
        id: '5',
        title: isAr ? 'طبيب جلدية قريب منك' : 'Dermatologist Near You',
        body: isAr
            ? 'د. سارة أحمد — على بعد ٠.٦ كم — تقبل مرضى جدد. متخصصة في علاج حب الشباب.'
            : 'Dr. Sarah Ahmed — 0.6 km away — is accepting new patients. Specializes in acne treatment.',
        timestamp: isAr ? 'أمس' : 'Yesterday',
        isRead: true,
        icon: Icons.location_on_outlined,
        iconBg: const Color(0xFFEDE9FE),
        iconColor: const Color(0xFF8B5CF6),
        isToday: false,
        actionLabel: isAr ? 'عرض الملف' : 'View Profile',
      ),
      NotificationModel(
        id: '6',
        title: isAr ? 'تقرير البشرة الأسبوعي' : 'Weekly Skin Report',
        body: isAr
            ? 'تحسّنت بشرتك بنسبة 12% هذا الأسبوع! زادت مستويات الترطيب وتقلصت البقع الداكنة.'
            : 'Your skin improved by 12% this week! Hydration levels are up and dark spots reduced.',
        timestamp: isAr ? 'الأحد ٩:٠٠ ص' : 'Sun, 9:00 AM',
        isRead: false,
        icon: Icons.bar_chart_rounded,
        iconBg: const Color(0xFFE8F0FE),
        iconColor: AppColor.blueColor,
        isToday: false,
        actionLabel: isAr ? 'قراءة التقرير' : 'Read Report',
      ),
    ];
  }

  List<NotificationModel> get _filtered {
    switch (_selectedFilter) {
      case NotificationCategory.unread:
        return _notifications.where((n) => !n.isRead).toList();
      case NotificationCategory.reminders:
        return _notifications.where((n) => n.isReminder).toList();
      case NotificationCategory.all:
        return _notifications;
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() => _notifications.forEach((n) => n.isRead = true));
    context.read<NotificationProvider>().markAllRead();
  }

  void _dismiss(String id) =>
      setState(() => _notifications.removeWhere((n) => n.id == id));

  void _handleAction(String id) {
    switch (id) {
      case '1': // View Results
        Navigator.pushNamed(context, ScanResultScreen.routeName);
        break;
      case '3': // View Routine → home
        Navigator.pushNamed(context, mainLayout.routeName);
        break;
      case '4': // Shop Now
        Navigator.pushNamed(context, ProductsScreen.routeName);
        break;
      case '5': // View Profile → dermatologist
        Navigator.pushNamed(context, DoctorsScreen.routeName);
        break;
      case '6': // Read Report
        Navigator.pushNamed(context, ScanResultScreen.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final todayItems = _filtered.where((n) => n.isToday).toList();
    final earlierItems = _filtered.where((n) => !n.isToday).toList();
    final isEmpty = _filtered.isEmpty;

    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.blueColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.notifications,
          style: AppStyle.semi40linear.copyWith(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _unreadCount > 0 ? _markAllRead : null,
            child: Text(
              loc.markAllRead,
              style: TextStyle(
                color: _unreadCount > 0 ? Colors.white : Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterRow(loc),
          Expanded(
            child: isEmpty
                ? _buildEmptyState(loc)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    children: [
                      if (todayItems.isNotEmpty) ...[
                        _SectionHeader(title: loc.today),
                        ...todayItems.map((n) => _buildDismissible(n)),
                      ],
                      if (earlierItems.isNotEmpty) ...[
                        if (todayItems.isNotEmpty) const SizedBox(height: 4),
                        _SectionHeader(title: loc.earlier),
                        ...earlierItems.map((n) => _buildDismissible(n)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(AppLocalizations loc) {
    return Container(
      color: AppColor.blueColor,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
      child: Row(
        children: [
          _FilterChip(
            label: loc.filterAll,
            selected: _selectedFilter == NotificationCategory.all,
            onTap: () => setState(() => _selectedFilter = NotificationCategory.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '${loc.filterUnread}${_unreadCount > 0 ? ' $_unreadCount' : ''}',
            selected: _selectedFilter == NotificationCategory.unread,
            onTap: () => setState(() => _selectedFilter = NotificationCategory.unread),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: loc.filterReminders,
            selected: _selectedFilter == NotificationCategory.reminders,
            onTap: () =>
                setState(() => _selectedFilter = NotificationCategory.reminders),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissible(NotificationModel n) {
    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => _dismiss(n.id),
      child: _NotificationCard(
        notification: n,
        onTap: () => setState(() => n.isRead = true),
        onActionTap: () {
          setState(() => n.isRead = true);
          _handleAction(n.id);
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColor.blueColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded,
                size: 52, color: AppColor.blueColor),
          ),
          const SizedBox(height: 20),
          Text(loc.noNotificationsYet,
              style: AppStyle.semi40linear.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          Text(loc.noNotificationsSubtitle,
              style: AppStyle.regular.copyWith(color: AppColor.grayColor)),
        ],
      ),
    );
  }
}

// ── Filter chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.white60,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColor.blueColor : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Text(
        title.toUpperCase(),
        style: AppStyle.regular.copyWith(
          color: AppColor.grayColor,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

// ── Notification card ─────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onActionTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? Colors.grey.shade200
                : AppColor.blueColor.withOpacity(0.25),
            width: notification.isRead ? 1 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: notification.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(notification.icon,
                  color: notification.iconColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppStyle.productNameText.copyWith(
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        notification.timestamp,
                        style: AppStyle.regular.copyWith(
                          color: AppColor.grayColor,
                          fontSize: 11,
                        ),
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1ECFA3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyle.regular.copyWith(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  if (notification.actionLabel != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onActionTap,
                      child: Text(
                        notification.actionLabel!,
                        style: AppStyle.regular.copyWith(
                          color: AppColor.blueColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
