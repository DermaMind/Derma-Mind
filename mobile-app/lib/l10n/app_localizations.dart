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
  /// **'Don\'t have an Account?'**
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

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

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
  /// **'What\'s your skin type?'**
  String get question;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll recommend the ingredients your skin will love.'**
  String get subtitle;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @questionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionProgress(int current, int total);

  /// No description provided for @analyzingSkin.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your skin...'**
  String get analyzingSkin;

  /// No description provided for @skipSkinTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip Skin Test?'**
  String get skipSkinTestTitle;

  /// No description provided for @skipSkinTestMessage.
  ///
  /// In en, this message translates to:
  /// **'You can always take it later.'**
  String get skipSkinTestMessage;

  /// No description provided for @question2.
  ///
  /// In en, this message translates to:
  /// **'What\'s your gender?'**
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
  /// **'Let\'s take care of your skin journey.'**
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

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @suitableForSkinTypes.
  ///
  /// In en, this message translates to:
  /// **'Suitable for skin types'**
  String get suitableForSkinTypes;

  /// No description provided for @keyIngredients.
  ///
  /// In en, this message translates to:
  /// **'Key Ingredients'**
  String get keyIngredients;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'added to cart!'**
  String get addedToCart;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// No description provided for @clearCartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all items from your cart?'**
  String get clearCartConfirm;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @emptyCart.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get emptyCart;

  /// No description provided for @emptyCartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add products to get started'**
  String get emptyCartSubtitle;

  /// No description provided for @browseProducts.
  ///
  /// In en, this message translates to:
  /// **'Browse Products'**
  String get browseProducts;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal ({count} items)'**
  String subtotal(int count);

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @placingOrder.
  ///
  /// In en, this message translates to:
  /// **'Placing Order...'**
  String get placingOrder;

  /// No description provided for @promoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter promo code'**
  String get promoCodeHint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @promoInvalid.
  ///
  /// In en, this message translates to:
  /// **'Promo code not valid'**
  String get promoInvalid;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed!'**
  String get orderPlaced;

  /// No description provided for @orderPlacedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed successfully.'**
  String get orderPlacedMessage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @checkoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Checkout failed. Please try again.'**
  String get checkoutFailed;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdated;

  /// No description provided for @mySkinProfile.
  ///
  /// In en, this message translates to:
  /// **'My Skin Profile'**
  String get mySkinProfile;

  /// No description provided for @retakeSkinTest.
  ///
  /// In en, this message translates to:
  /// **'Retake Skin Test'**
  String get retakeSkinTest;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Settings & Privacy'**
  String get settingsPrivacy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @skinType.
  ///
  /// In en, this message translates to:
  /// **'Skin Type'**
  String get skinType;

  /// No description provided for @skinHistory.
  ///
  /// In en, this message translates to:
  /// **'Skin History'**
  String get skinHistory;

  /// No description provided for @lastScan.
  ///
  /// In en, this message translates to:
  /// **'Last Scan'**
  String get lastScan;

  /// No description provided for @notTakenYet.
  ///
  /// In en, this message translates to:
  /// **'Not taken yet'**
  String get notTakenYet;

  /// No description provided for @scanHistory.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHistory;

  /// No description provided for @noScanHistory.
  ///
  /// In en, this message translates to:
  /// **'No scan history yet'**
  String get noScanHistory;

  /// No description provided for @noScanHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your scan results will appear here'**
  String get noScanHistorySubtitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @paymobPayment.
  ///
  /// In en, this message translates to:
  /// **'Paymob Payment'**
  String get paymobPayment;

  /// No description provided for @completePayment.
  ///
  /// In en, this message translates to:
  /// **'Complete your payment'**
  String get completePayment;

  /// No description provided for @paymentBrowserMessage.
  ///
  /// In en, this message translates to:
  /// **'The Paymob secure payment page has been opened in your browser. Return here after completing payment.'**
  String get paymentBrowserMessage;

  /// No description provided for @openPaymentAgain.
  ///
  /// In en, this message translates to:
  /// **'Open Payment Page Again'**
  String get openPaymentAgain;

  /// No description provided for @paymentCompleted.
  ///
  /// In en, this message translates to:
  /// **'I Completed Payment'**
  String get paymentCompleted;

  /// No description provided for @skinTypeResult.
  ///
  /// In en, this message translates to:
  /// **'Skin Type Result'**
  String get skinTypeResult;

  /// No description provided for @skinMostLikelyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Your skin is most likely'**
  String get skinMostLikelyPrefix;
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
