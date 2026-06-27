// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get whereAiMeetsSkinHealth => 'Where AI Meets Skin Health';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get enterYourEmail => 'Enter Your Email';

  @override
  String get enterYourPassword => 'Enter Your Password';

  @override
  String get forgetPassword => 'Forget Password';

  @override
  String get dontHaveAnAccount => 'Don\'t have an Account?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get or => 'OR';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get login => 'Login';

  @override
  String get passwordEnteredIsWrong => '*The password you entered is wrong';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get name => 'Name';

  @override
  String get enterYourName => 'Enter Your Name';

  @override
  String get signUp => 'Sign Up';

  @override
  String get question => 'What\'s your skin type?';

  @override
  String get subtitle =>
      'We\'ll recommend the ingredients your skin will love.';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get skip => 'Skip';

  @override
  String get cancel => 'Cancel';

  @override
  String questionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get analyzingSkin => 'Analyzing your skin...';

  @override
  String get skipSkinTestTitle => 'Skip Skin Test?';

  @override
  String get skipSkinTestMessage => 'You can always take it later.';

  @override
  String get question2 => 'What\'s your gender?';

  @override
  String get subtitle2 =>
      'This will help us adjust your routine steps based on your gender';

  @override
  String get question_age => 'What is your age group?';

  @override
  String get subtitle_age =>
      'This will help us personalize your product suggestions based on your age group.';

  @override
  String get question_skin_concern => 'What is your skin health concern?';

  @override
  String get subtitle_skin_concern => 'You can choose more than one answer.';

  @override
  String get messageSucceed => 'You can check your skin factors in profile';

  @override
  String get goto_home => 'Go to Home';

  @override
  String get home_subtitle => 'Let\'s take care of your skin journey.';

  @override
  String get testSkinTypeTitle => 'Test Skin Type';

  @override
  String get testSkinTypeSubtitle => 'Discover Your Skin Type In \nMinutes.';

  @override
  String get skinTest => 'Skin Test';

  @override
  String get diagnose_title => 'Diagnose Your Skin';

  @override
  String get diagnose_subtitle => 'Capture or upload an image now.';

  @override
  String get assistant_title => 'DermaMind Assistant';

  @override
  String get assistant_subtitle => 'Ask anything about your case.';

  @override
  String get shop_title => 'Shop';

  @override
  String get shop_subtitle => 'Safe picks based on your condition.';

  @override
  String get doctors_title => 'Nearby Dermatologists';

  @override
  String get doctors_subtitle => 'Find clinics & specialists near you.';

  @override
  String get popular_products => 'Popular Products';

  @override
  String get see_all => 'See all';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get today => 'Today';

  @override
  String get earlier => 'Earlier';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnread => 'Unread';

  @override
  String get filterReminders => 'Reminders';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get noNotificationsSubtitle => 'You\'re all caught up!';

  @override
  String get products => 'Products';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get allCategories => 'All';

  @override
  String get reviews => 'reviews';

  @override
  String get description => 'Description';

  @override
  String get suitableForSkinTypes => 'Suitable for skin types';

  @override
  String get keyIngredients => 'Key Ingredients';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get addedToCart => 'added to cart!';

  @override
  String get viewCart => 'View Cart';

  @override
  String get proceedToCheckout => 'Proceed to Checkout';

  @override
  String get myCart => 'My Cart';

  @override
  String get clearCart => 'Clear Cart';

  @override
  String get clearCartConfirm => 'Remove all items from your cart?';

  @override
  String get clear => 'Clear';

  @override
  String get emptyCart => 'Your cart is empty';

  @override
  String get emptyCartSubtitle => 'Add products to get started';

  @override
  String get browseProducts => 'Browse Products';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String subtotal(int count) {
    return 'Subtotal ($count items)';
  }

  @override
  String get discount => 'Discount';

  @override
  String get delivery => 'Delivery';

  @override
  String get free => 'Free';

  @override
  String get total => 'Total';

  @override
  String get placingOrder => 'Placing Order...';

  @override
  String get promoCodeHint => 'Enter promo code';

  @override
  String get apply => 'Apply';

  @override
  String get promoInvalid => 'Promo code not valid';

  @override
  String get orderPlaced => 'Order Placed!';

  @override
  String get orderPlacedMessage => 'Your order has been placed successfully.';

  @override
  String get ok => 'OK';

  @override
  String get checkoutFailed => 'Checkout failed. Please try again.';

  @override
  String get settings => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdated => 'Profile updated successfully!';

  @override
  String get mySkinProfile => 'My Skin Profile';

  @override
  String get retakeSkinTest => 'Retake Skin Test';

  @override
  String get settingsPrivacy => 'Settings & Privacy';

  @override
  String get logout => 'Logout';

  @override
  String get skinType => 'Skin Type';

  @override
  String get skinHistory => 'Skin History';

  @override
  String get lastScan => 'Last Scan';

  @override
  String get notTakenYet => 'Not taken yet';

  @override
  String get scanHistory => 'Scan History';

  @override
  String get noScanHistory => 'No scan history yet';

  @override
  String get noScanHistorySubtitle => 'Your scan results will appear here';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get paymobPayment => 'Paymob Payment';

  @override
  String get completePayment => 'Complete your payment';

  @override
  String get paymentBrowserMessage =>
      'The Paymob secure payment page has been opened in your browser. Return here after completing payment.';

  @override
  String get openPaymentAgain => 'Open Payment Page Again';

  @override
  String get paymentCompleted => 'I Completed Payment';

  @override
  String get skinTypeResult => 'Skin Type Result';

  @override
  String get skinMostLikelyPrefix => 'Your skin is most likely';
}
