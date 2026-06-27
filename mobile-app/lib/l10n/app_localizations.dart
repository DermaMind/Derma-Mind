import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @whereAiMeetsSkinHealth.
  ///
  /// In en, this message translates to:
  /// **'Where AI Meets Skin Health'**
  String get whereAiMeetsSkinHealth;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Password'**
  String get enterYourPassword;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget Password'**
  String get forgetPassword;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an Account?'**
  String get dontHaveAnAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @passwordEnteredIsWrong.
  ///
  /// In en, this message translates to:
  /// **'*The password you entered is wrong'**
  String get passwordEnteredIsWrong;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Name'**
  String get enterYourName;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'What’s your skin type?'**
  String get question;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'We’ll recommend the ingredients your skin will love.'**
  String get subtitle;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @question2.
  ///
  /// In en, this message translates to:
  /// **'What’s your gender?'**
  String get question2;

  /// No description provided for @subtitle2.
  ///
  /// In en, this message translates to:
  /// **'This will help us adjust your routine steps based on your gender'**
  String get subtitle2;

  /// No description provided for @question_age.
  ///
  /// In en, this message translates to:
  /// **'What is your age group?'**
  String get question_age;

  /// No description provided for @subtitle_age.
  ///
  /// In en, this message translates to:
  /// **'This will help us personalize your product suggestions based on your age group.'**
  String get subtitle_age;

  /// No description provided for @question_skin_concern.
  ///
  /// In en, this message translates to:
  /// **'What is your skin health concern?'**
  String get question_skin_concern;

  /// No description provided for @subtitle_skin_concern.
  ///
  /// In en, this message translates to:
  /// **'You can choose more than one answer.'**
  String get subtitle_skin_concern;

  /// No description provided for @messageSucceed.
  ///
  /// In en, this message translates to:
  /// **'You can check your skin factors in profile'**
  String get messageSucceed;

  /// No description provided for @goto_home.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goto_home;

  /// No description provided for @home_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s take care of your skin journey.'**
  String get home_subtitle;

  /// No description provided for @testSkinTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Skin Type'**
  String get testSkinTypeTitle;

  /// No description provided for @testSkinTypeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Your Skin Type In \nMinutes.'**
  String get testSkinTypeSubtitle;

  /// No description provided for @skinTest.
  ///
  /// In en, this message translates to:
  /// **'Skin Test'**
  String get skinTest;

  /// No description provided for @diagnose_title.
  ///
  /// In en, this message translates to:
  /// **'Diagnose Your Skin'**
  String get diagnose_title;

  /// No description provided for @diagnose_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture or upload an image now.'**
  String get diagnose_subtitle;

  /// No description provided for @assistant_title.
  ///
  /// In en, this message translates to:
  /// **'DermaMind Assistant'**
  String get assistant_title;

  /// No description provided for @assistant_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about your case.'**
  String get assistant_subtitle;

  /// No description provided for @shop_title.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop_title;

  /// No description provided for @shop_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Safe picks based on your condition.'**
  String get shop_subtitle;

  /// No description provided for @doctors_title.
  ///
  /// In en, this message translates to:
  /// **'Nearby Dermatologists'**
  String get doctors_title;

  /// No description provided for @doctors_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Find clinics & specialists near you.'**
  String get doctors_subtitle;

  /// No description provided for @popular_products.
  ///
  /// In en, this message translates to:
  /// **'Popular Products'**
  String get popular_products;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get see_all;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get filterUnread;

  /// No description provided for @filterReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get filterReminders;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @noNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get noNotificationsSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
