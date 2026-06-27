
import 'package:dermamind_app/HomeScreen/model/service_model.dart';
import 'package:dermamind_app/providers/auth_provider.dart';
import 'package:dermamind_app/providers/skin_test_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dermamind_app/doctors/doctors_screen.dart';
import 'package:dermamind_app/HomeScreen/wiidget/SlidePageRoute.dart';
import 'package:dermamind_app/HomeScreen/wiidget/TestCard.dart';
import 'package:dermamind_app/HomeScreen/wiidget/homeHeader.dart';
import 'package:dermamind_app/HomeScreen/wiidget/popular_produt.dart';
import 'package:dermamind_app/HomeScreen/wiidget/scrvice_card.dart';
import 'package:dermamind_app/HomeScreen/wiidget/searchbar.dart';
import 'package:dermamind_app/skin_test/Question_screen.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:dermamind_app/utils/assets_Maneger.dart';
import 'package:flutter/material.dart';


import '../Scan_Screen/scan_face_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../l10n/app_localizations.dart';
import '../product_screen/product_screen.dart';

class HomeScreen  extends StatefulWidget {
  static const String RoutName = 'homeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ── Weather & Skin Alert card ─────────────────────────────────────────────────

class _WeatherSkinCard extends StatelessWidget {
  const _WeatherSkinCard();

  Map<String, dynamic> _getWeatherAlert() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return {
        'temp': '22°',
        'title': 'Morning',
        'icon': Icons.wb_cloudy_outlined,
        'tip': '🌤 Apply SPF 30\nin the morning',
        'uvLabel': 'UV: Low',
      };
    } else if (hour >= 12 && hour < 16) {
      return {
        'temp': '35°',
        'title': 'Peak Sun',
        'icon': Icons.wb_sunny_rounded,
        'tip': '☀️ Apply SPF 50+\nbefore going out',
        'uvLabel': 'UV: Very High',
      };
    } else if (hour >= 16 && hour < 19) {
      return {
        'temp': '30°',
        'title': 'Afternoon',
        'icon': Icons.cloud_outlined,
        'tip': '🧴 Reapply sunscreen\nif outdoors',
        'uvLabel': 'UV: Moderate',
      };
    } else {
      return {
        'temp': '20°',
        'title': 'Evening',
        'icon': Icons.nights_stay_outlined,
        'tip': '🌙 Apply night cream\n& repair serum',
        'uvLabel': 'UV: None',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final alert = _getWeatherAlert();
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM').format(now);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF0277BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left: info ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather & Skin Alert',
                  style: AppStyle.regular.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert['temp'] as String,
                  style: AppStyle.nameLinear.copyWith(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: AppStyle.regular.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        'Cairo, Egypt',
                        style: AppStyle.regular.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Right: icon + tip ───────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(alert['icon'] as IconData,
                  color: Colors.white, size: 64),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxWidth: 110),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alert['tip'] as String,
                  textAlign: TextAlign.center,
                  style: AppStyle.regular.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SkinTestProvider>().loadFromPrefs();
    });
  }
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final skinTest = context.watch<SkinTestProvider>();
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final List<ServiceModel> services = [
    ServiceModel(
        title:AppLocalizations.of(context)!.diagnose_title,
        subtitle: AppLocalizations.of(context)!.diagnose_subtitle,
        iconPath: AssetsManager.diagnosisIcon,
        color: 0xFFFFFFFF,
        iconColor: 0xFF0C81E4,
        watermarkIcon: Icons.document_scanner_outlined,
        onTap: (){
          Navigator.push(
            context,
            SlidePageRoute(page:ScanFaceScreen()),
          );
        }),
    ServiceModel(
        title:AppLocalizations.of(context)!.assistant_title,
        subtitle: AppLocalizations.of(context)!.assistant_subtitle,
        iconPath: AssetsManager.smartAsistIcon,
        color: 0xFFFFFFFF,
        iconColor: 0xFF8B5CF6,
        watermarkIcon: Icons.psychology_outlined,
        onTap: () => Navigator.pushNamed(context, ChatbotScreen.routeName)),
    ServiceModel(
        title:AppLocalizations.of(context)!.shop_title,
        subtitle: AppLocalizations.of(context)!.shop_subtitle,
        iconPath: AssetsManager.shopIcon,
        color: 0xFFFFFFFF,
        iconColor: 0xFF10B981,
        watermarkIcon: Icons.shopping_bag_outlined,
        onTap: (){
          Navigator.push(
            context,
            SlidePageRoute(page:ProductsScreen()),
          );
        }),
    ServiceModel(
        title:AppLocalizations.of(context)!.doctors_title,
        subtitle: AppLocalizations.of(context)!.doctors_subtitle,
        iconPath: AssetsManager.nearbyIcon,
        color: 0xFFFFFFFF,
        iconColor: 0xFFF97316,
        watermarkIcon: Icons.location_on_outlined,
        onTap: (){
          Navigator.push(
            context,
            SlidePageRoute(page: const DoctorsScreen()),
          );
        }),
    ];


    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: height*0.12,right: 16,left: 16),
                child: ListView(
                  children: [
                    SizedBox(height: 20,),
                SearchBarWidget(title: "Search doctor, drugs, articles...",),
                    SizedBox(height: 20,),
                    TestCard(
                      hasResult: skinTest.hasSkinResult,
                      skinType: skinTest.skinType,
                      skinHistory: skinTest.skinHistory,
                      lastScan: skinTest.lastScan,
                      onStartTest: () async {

                        await Navigator.pushNamed(
                          context,
                          QuestionScreen.RoutName,
                        );

                        if (mounted) {
                          await context
                              .read<SkinTestProvider>()
                              .loadFromPrefs();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Services",
                      style: AppStyle.SkinTestCard,

                    ),
                    const SizedBox(height: 16),
                      GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                        itemCount: services.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context,index){
                          final service = services[index];
                          return ServiceCard(
                              title: service.title,
                              subtitle: service.subtitle,
                              iconPath: service.iconPath,
                              iconColor: Color(service.iconColor),
                              watermarkIcon: service.watermarkIcon,
                              onTap: service.onTap,);


                        }
                         ),
                    const SizedBox(height: 20),
                    const _WeatherSkinCard(),
                    const SizedBox(height: 20),
                    const popularProduct(),
                    const SizedBox(height: 20),



                  ],

                ),
              ),
              Container(
                height: 100,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                decoration: BoxDecoration(
                    color: AppColor.primaryColor.withValues(alpha: 0.95),

                 boxShadow: [
                   BoxShadow(
                       color: Colors.black.withValues(alpha: 0.05),
                     blurRadius: 10,
                   )
                 ]
                ),
                child: HomeHeader(userName: auth.userName.isNotEmpty ? auth.userName : 'there'),
              ),



            ],
          ),
      ),
    );

  }
}
