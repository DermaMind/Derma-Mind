import 'package:dermamind_app/notifications/notifications_screen.dart';
import 'package:dermamind_app/providers/notification_provider.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:dermamind_app/utils/assets_Maneger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';


class HomeHeader   extends StatelessWidget {
  final String userName;
  const HomeHeader({super.key,required this.userName});


  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello,$userName 👋",style: AppStyle.nameLinear,),
            SizedBox(height: 8,),
            Text(AppLocalizations.of(context)!.home_subtitle,
              style: AppStyle.regular.copyWith(color: Colors.grey),)
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            NotificationsScreen.routeName,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Icon(Icons.notifications,
                    color: AppColor.blueColor, size: 30),
              ),
              if (unreadCount > 0)
              Positioned(
                top: 2,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1ECFA3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        )
      ],

    );
  }
}