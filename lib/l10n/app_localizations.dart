import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'hello'**
  String get hello;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @oneStopShopDescription.
  ///
  /// In en, this message translates to:
  /// **'We are your one-stop online shop for everything you need. Fast delivery , great prices, and trusted brands all in one place.'**
  String get oneStopShopDescription;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'create'**
  String get create;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @usernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Username or Email'**
  String get usernameOrEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPwd.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPwd;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'- OR Continue with -'**
  String get continueWith;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create An Account'**
  String get createAnAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'create an account'**
  String get createAccount;

  /// No description provided for @anAccount.
  ///
  /// In en, this message translates to:
  /// **'an account'**
  String get anAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @createSimple.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createSimple;

  /// No description provided for @createAnAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'create an account'**
  String get createAnAccountLogin;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @passworConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get passworConfirmation;

  /// No description provided for @becomeASeller.
  ///
  /// In en, this message translates to:
  /// **'Do you wanna become a Seller / Vendor ?'**
  String get becomeASeller;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @byClickingThe.
  ///
  /// In en, this message translates to:
  /// **'By clicking the'**
  String get byClickingThe;

  /// No description provided for @publicOffer.
  ///
  /// In en, this message translates to:
  /// **'button,you agree to the public offer'**
  String get publicOffer;

  /// No description provided for @newsletter.
  ///
  /// In en, this message translates to:
  /// **'Sign up for newsletter'**
  String get newsletter;

  /// No description provided for @enableremoteshoppinghelp.
  ///
  /// In en, this message translates to:
  /// **'Enable remote shopping help'**
  String get enableremoteshoppinghelp;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'I Already Have an Account '**
  String get alreadyHaveAnAccount;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @resetPwd.
  ///
  /// In en, this message translates to:
  /// **'I want to reset my password'**
  String get resetPwd;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification\ncode'**
  String get verificationCode;

  /// No description provided for @sentTheVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'We have sent the verification code to'**
  String get sentTheVerificationCode;

  /// No description provided for @noCode.
  ///
  /// In en, this message translates to:
  /// **'Didn’t receive the code ?'**
  String get noCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @performances.
  ///
  /// In en, this message translates to:
  /// **'Performances'**
  String get performances;

  /// No description provided for @legalAndPolicies.
  ///
  /// In en, this message translates to:
  /// **'Legal And Policies'**
  String get legalAndPolicies;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @trailLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get trailLanguage;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get streetAddress;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @zipPostalCode.
  ///
  /// In en, this message translates to:
  /// **'ZIP / Postal Code'**
  String get zipPostalCode;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid Code'**
  String get invalidCode;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @payPal.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get payPal;

  /// No description provided for @applePay.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get applePay;

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'card holder name'**
  String get cardholderName;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry (MM/YY)'**
  String get expiry;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password Changed Successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @enteryourcurrentpassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Current Password'**
  String get enteryourcurrentpassword;

  /// No description provided for @reenternewpassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter New Password'**
  String get reenternewpassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @changeNow.
  ///
  /// In en, this message translates to:
  /// **'Change Now'**
  String get changeNow;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enternewpassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enternewpassword;

  /// No description provided for @purchaseCompleted.
  ///
  /// In en, this message translates to:
  /// **'Purchase Completed'**
  String get purchaseCompleted;

  /// No description provided for @orderPacked.
  ///
  /// In en, this message translates to:
  /// **'Order Packed'**
  String get orderPacked;

  /// No description provided for @minago.
  ///
  /// In en, this message translates to:
  /// **'min ago'**
  String get minago;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @discountApplied.
  ///
  /// In en, this message translates to:
  /// **'Discount Applied'**
  String get discountApplied;

  /// No description provided for @newFeatureUpdate.
  ///
  /// In en, this message translates to:
  /// **'New Feature Update'**
  String get newFeatureUpdate;

  /// No description provided for @searchFavorites.
  ///
  /// In en, this message translates to:
  /// **'Search favorites'**
  String get searchFavorites;

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Sample description for the product goes here.'**
  String get productDescription;

  /// No description provided for @currentPrice.
  ///
  /// In en, this message translates to:
  /// **'AED 499'**
  String get currentPrice;

  /// No description provided for @originalPrice.
  ///
  /// In en, this message translates to:
  /// **'AED 999'**
  String get originalPrice;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'50% Off'**
  String get discount;

  /// No description provided for @product0Name.
  ///
  /// In en, this message translates to:
  /// **'Nike Running Shoes'**
  String get product0Name;

  /// No description provided for @product1Name.
  ///
  /// In en, this message translates to:
  /// **'Adidas Sports Sneakers'**
  String get product1Name;

  /// No description provided for @product2Name.
  ///
  /// In en, this message translates to:
  /// **'Puma Casual Shoes'**
  String get product2Name;

  /// No description provided for @product3Name.
  ///
  /// In en, this message translates to:
  /// **'Reebok Gym Trainers'**
  String get product3Name;

  /// No description provided for @product4Name.
  ///
  /// In en, this message translates to:
  /// **'New Balance Walkers'**
  String get product4Name;

  /// No description provided for @product5Name.
  ///
  /// In en, this message translates to:
  /// **'ASICS Marathon Shoes'**
  String get product5Name;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

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

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @humanFriendly.
  ///
  /// In en, this message translates to:
  /// **'Introduction and overview'**
  String get humanFriendly;

  /// No description provided for @legalMumboJumbo.
  ///
  /// In en, this message translates to:
  /// **'Details of our policy'**
  String get legalMumboJumbo;

  /// No description provided for @privacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Our human-friendly Terms of Service for the platform prevails over the detailed one, which specifies all rights and obligations in more complex legalese.\n\nIn case of contradiction between the two documents, the human-friendly Terms shall prevail. That means no nasty surprises if you read only the human-friendly version.'**
  String get privacyDescription;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @searchTopics.
  ///
  /// In en, this message translates to:
  /// **'Search for topics...'**
  String get searchTopics;

  /// No description provided for @helpTopic0.
  ///
  /// In en, this message translates to:
  /// **'How to create a profile on kolshy website?'**
  String get helpTopic0;

  /// No description provided for @helpTopic1.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods ?'**
  String get helpTopic1;

  /// No description provided for @helpTopic2.
  ///
  /// In en, this message translates to:
  /// **'Track the order from the seller ?'**
  String get helpTopic2;

  /// No description provided for @helpTopic3.
  ///
  /// In en, this message translates to:
  /// **'Tracking For Customer?'**
  String get helpTopic3;

  /// No description provided for @helpTopic4.
  ///
  /// In en, this message translates to:
  /// **'What is your return policy?'**
  String get helpTopic4;

  /// No description provided for @helpTopicContent.
  ///
  /// In en, this message translates to:
  /// **' '**
  String get helpTopicContent;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @sendHint.
  ///
  /// In en, this message translates to:
  /// **'Send a message here...'**
  String get sendHint;

  /// No description provided for @presetFasterDelivery.
  ///
  /// In en, this message translates to:
  /// **'Faster Delivery time'**
  String get presetFasterDelivery;

  /// No description provided for @presetProductIssue.
  ///
  /// In en, this message translates to:
  /// **'Trouble with a product'**
  String get presetProductIssue;

  /// No description provided for @presetOther.
  ///
  /// In en, this message translates to:
  /// **'Something else...'**
  String get presetOther;

  /// No description provided for @thankYouTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for\nshopping with us!'**
  String get thankYouTitle;

  /// No description provided for @thankYouSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your order number 16 is confirmed\nand in processing'**
  String get thankYouSubtitle;

  /// No description provided for @thankYouDescription.
  ///
  /// In en, this message translates to:
  /// **'Porem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.'**
  String get thankYouDescription;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get orderNumber;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get orderDate;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orderStatus;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @customerInfo.
  ///
  /// In en, this message translates to:
  /// **'Customer Info'**
  String get customerInfo;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @sneakers.
  ///
  /// In en, this message translates to:
  /// **'Sneakers'**
  String get sneakers;

  /// No description provided for @orderTotal.
  ///
  /// In en, this message translates to:
  /// **'Order Total'**
  String get orderTotal;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

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

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @editDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Details'**
  String get editDetails;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @addCoupon.
  ///
  /// In en, this message translates to:
  /// **'Add coupon code'**
  String get addCoupon;

  /// No description provided for @couponApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied: 10% off!'**
  String get couponApplied;

  /// No description provided for @invalidCoupon.
  ///
  /// In en, this message translates to:
  /// **'Invalid coupon code'**
  String get invalidCoupon;

  /// No description provided for @earnPointsFreeShipping.
  ///
  /// In en, this message translates to:
  /// **'You’ll earn 34 points · Free shipping'**
  String get earnPointsFreeShipping;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get proceedToCheckout;

  /// No description provided for @productTitle.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productTitle;

  /// No description provided for @productBrand.
  ///
  /// In en, this message translates to:
  /// **'By Day Dissolve'**
  String get productBrand;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionContent.
  ///
  /// In en, this message translates to:
  /// **'Corem ipsum dolor sit amet, consectetur adipiscing elit...'**
  String get descriptionContent;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @ingredientsContent.
  ///
  /// In en, this message translates to:
  /// **'Water, Glycerin, Aloe Vera...'**
  String get ingredientsContent;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get howToUse;

  /// No description provided for @howToUseContent.
  ///
  /// In en, this message translates to:
  /// **'Apply a small amount...'**
  String get howToUseContent;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @freeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free delivery'**
  String get freeDelivery;

  /// No description provided for @availableInStore.
  ///
  /// In en, this message translates to:
  /// **'Available in the nearest store'**
  String get availableInStore;

  /// No description provided for @customerReviews.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get customerReviews;

  /// No description provided for @recommendedProducts.
  ///
  /// In en, this message translates to:
  /// **'Products you may also like'**
  String get recommendedProducts;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add To Cart'**
  String get addToCart;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get electronics;

  /// No description provided for @computerSoftware.
  ///
  /// In en, this message translates to:
  /// **'Computer & Software'**
  String get computerSoftware;

  /// No description provided for @fashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get fashion;

  /// No description provided for @homeKitchen.
  ///
  /// In en, this message translates to:
  /// **'Home & Kitchen'**
  String get homeKitchen;

  /// No description provided for @healthBeauty.
  ///
  /// In en, this message translates to:
  /// **'Health & Beauty'**
  String get healthBeauty;

  /// No description provided for @groceriesFood.
  ///
  /// In en, this message translates to:
  /// **'Groceries & Food'**
  String get groceriesFood;

  /// No description provided for @childrenToys.
  ///
  /// In en, this message translates to:
  /// **'Children & Toys'**
  String get childrenToys;

  /// No description provided for @carsAccessories.
  ///
  /// In en, this message translates to:
  /// **'Cars & Accessories'**
  String get carsAccessories;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// No description provided for @sportsFitness.
  ///
  /// In en, this message translates to:
  /// **'Sports & Fitness'**
  String get sportsFitness;

  /// No description provided for @hiUser.
  ///
  /// In en, this message translates to:
  /// **'Hi {user}'**
  String hiUser(Object user);

  /// No description provided for @promo.
  ///
  /// In en, this message translates to:
  /// **'Promo'**
  String get promo;

  /// No description provided for @exploreProducts.
  ///
  /// In en, this message translates to:
  /// **'Explore thousands of products'**
  String get exploreProducts;

  /// No description provided for @fastDelivery.
  ///
  /// In en, this message translates to:
  /// **'Fast delivery across the Middle East'**
  String get fastDelivery;

  /// No description provided for @summerSale.
  ///
  /// In en, this message translates to:
  /// **'Summer sale 50% OFF'**
  String get summerSale;

  /// No description provided for @selectedItems.
  ///
  /// In en, this message translates to:
  /// **'On selected items, limited time!'**
  String get selectedItems;

  /// No description provided for @newArrivalsBanner.
  ///
  /// In en, this message translates to:
  /// **'New arrivals are here!'**
  String get newArrivalsBanner;

  /// No description provided for @freshestStyles.
  ///
  /// In en, this message translates to:
  /// **'Check the freshest styles now'**
  String get freshestStyles;

  /// No description provided for @bestSeller.
  ///
  /// In en, this message translates to:
  /// **'Best Seller'**
  String get bestSeller;

  /// No description provided for @shopByCategory.
  ///
  /// In en, this message translates to:
  /// **'Shop by Category'**
  String get shopByCategory;

  /// No description provided for @newArrivals.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get newArrivals;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Forem ipsum'**
  String get productName;

  /// No description provided for @discountBanner.
  ///
  /// In en, this message translates to:
  /// **'50–40% OFF'**
  String get discountBanner;

  /// No description provided for @shopNowText.
  ///
  /// In en, this message translates to:
  /// **'On selected products\nShop now with big discounts!'**
  String get shopNowText;

  /// No description provided for @shopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop Now'**
  String get shopNow;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @howtocontactus.
  ///
  /// In en, this message translates to:
  /// **'How to contact us ?'**
  String get howtocontactus;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @humanFriendlyPolicyText.
  ///
  /// In en, this message translates to:
  /// **'Introduction\nWe at Kolshy E-Commerce Solutions, a platform fully owned by Kolshy E-Commerce LLC, officially registered in the United Arab Emirates under license number 1401296 and solely owned by Mr. Ahmed Mohamed El-Farmawy, operate with our headquarters located at Office No. 43, Building 44, Dubai – UAE.\nWe place great importance on respecting your privacy and strive to protect all personal data collected when you use our website\nwww.kolshy.ae\nor the associated mobile application.\nFor any inquiries, you can contact us via:\n• Email: info@kolshy.ae\n• Phone / WhatsApp: +971551228825\n• Privacy Policy\nThis policy (\"Privacy Policy\") explains the basis on which we collect and use your personal data, whether collected directly from you or from other sources, in the context of accessing the platform or using any of the services we provide, including but not limited to: promotional messages, and integrated social media features (collectively referred to as \"services\").\nWe fully understand the importance of protecting your personal data and are committed to respecting and safeguarding your privacy.\nPlease read this policy carefully to understand how we handle your personal data.\nBy using the platform or services, you acknowledge and agree to the collection and use of your personal data as described in this policy.\nFor the purposes of this policy, \"personal data\" refers to all types of data mentioned in Clause (2) of this document.\nTerms such as \"user,\" \"you,\" or similar refer to the natural or legal person using the platform or services, as applicable.\nOur platform may contain links to third-party websites, plugins, or applications provided by third parties.\nWhen you click on any of these links or activate such plugins, third parties may be able to collect or share information about you.\nPlease note that we have no control over, and are not responsible for, the privacy policies or practices of such external sites.\nWhen you leave our platform, we strongly recommend that you review the privacy policy of each website you visit to ensure you fully understand how they handle your data.'**
  String get humanFriendlyPolicyText;

  /// No description provided for @legalMumboJumboPolicyText.
  ///
  /// In en, this message translates to:
  /// **'• 1. No collection of children\'s data\nThis platform is intended for adults only, in accordance with applicable laws defining the age of majority.\nThe platform is not in any way targeted at individuals under the legal age.\nHowever, we cannot always prevent some users, including minors, from providing false information about their age to access the platform.\nIf you are a parent or legal guardian and believe that we have inadvertently collected personal information about your child, please contact us immediately using the contact methods specified in Clause 12 of this Privacy Policy.\n\n• 2. What personal data do we collect from or about you?\nWe collect your personal data to continuously provide and improve our services and platform.\n\"Personal data\" means any information that can be used to identify you as an individual through direct or indirect identifiers.\nPersonal data does not include information that has been anonymized (where all identifiers have been removed).\nWe collect, store, use, and transfer various types of personal data, which can be classified as follows:\n1. Identity data: first name, middle name, last name, username or similar identifiers, gender, title, nationality, and date of birth.\n2. Contact data: residential address, email address, and phone number.\n3. Transaction data: details of payments received or made, payment methods used, and data about products or services purchased from us.\n4. Technical data: IP address, login information, browser type and version, operating system, mobile app version, time zone settings, location data, device type, advertising identifiers (e.g., in iOS), and other internet usage information. This may be collected using cookies, sessions, web beacons, and other tracking tools.\n5. Profile data: username, password, your interests and preferences, comments, preferred language, and responses to surveys.\n6. Purchase data: all previous orders, account purchases, refund information, fulfillment details, and browsing records of products and services.\n7. Interaction data: related to how you interact with our website, products, and services.\n8. Marketing and communication data: preferences for receiving promotional offers or marketing messages from us or third parties, and your preferred communication method.\nAdditionally, we may collect, use, and share statistical or demographic data known as \"aggregated data.\" These are derived from your personal data but do not reveal your identity after removing all identifiers.\nExample: we may use aggregated browsing data to analyze the percentage of users engaging with a specific feature on the platform.\n\n3. How do we collect your personal data?\nWe collect your personal data through three main methods:\n1. Directly from you:\nWe collect your data directly when you:\n- Register on the platform or log in via social media or any other registration method.\n- Make payments, request refunds, or select your preferred payment method.\n- Participate in competitions, promotions, or special programs.\n- Provide comments, reviews, or testimonials.\n- Submit support requests or complaints related to services.\n- Communicate with us via phone, email, or other channels (where correspondence is recorded).\n- Browse or engage in any activity within the platform.\n2. Indirectly:\nWe may obtain your personal data from third parties or related parties, such as:\n- Friends or relatives making purchases for you or on your behalf.\n- Partner vendors or service providers, such as logistics and fulfillment partners, marketing providers, and payment processors.\n- Interactions via platforms like Facebook, Google, etc.\nIf you share personal data about others (e.g., friends or family), you confirm you have their consent to share it under this Privacy Policy.\n3. Automatically:\nWe collect some data automatically while you use the platform, using technologies such as:\n- Log files: including IP address, browser type, pages visited, operating system, timestamps, and other technical details.\n- Cookies & sessions: small files stored on your device to improve your experience by enabling platform features, remembering your preferences, understanding your interactions, showing personalized ads, and analyzing traffic.\nIf you do not agree to the use of cookies, you may disable them in your browser settings or stop using the platform. However, disabling some data types may affect your full experience of our services.\n\n4. Why do we collect your personal data?\nWe collect and use your personal data to enhance your experience with us, including:\n1. Providing information and services.\n2. Location-based services.\n3. Fulfilling contractual obligations.\n4. Improving services and communication.\n5. Optimizing content display.\n6. Offering personalized services for special occasions.\n7. Notifying you about updates.\n8. Improving your overall experience.\n9. Managing reward programs.\n10. Improving technical performance.\n11. Complying with local laws.\n12. Preventing fraud and ensuring security.\n\n5. How do we use your personal data?\nWe use your personal data only when necessary, including:\n1. Contract execution.\n2. Legal compliance.\n3. Legitimate interests.\n4. Marketing and communication (with opt-out options).\n\n6. Who do we share your personal data with?\n1. Affiliates and service providers.\n2. Third parties for specific purposes.\n3. In case of merger or transfer of ownership.\n4. Legal compliance and protection of rights.\n\n7. How do we store your personal data and for how long?\nWe store your data only for as long as necessary for the purposes stated or as required by law. Factors considered include data sensitivity, risk level, purpose achievement, and legal requirements.\nWe may anonymize data for indefinite research or statistical use.\n\n8. What security measures do we apply?\nWe use commercially reasonable technical, administrative, and physical safeguards, such as encryption, firewalls, restricted access, and PCI DSS compliance.\nYou are also responsible for protecting your account information.\n\n9. Your rights regarding your personal data:\n1. Right to information.\n2. Right to access.\n3. Right to request deletion.\n4. Right to withdraw consent or object.\n5. Right to correct data.\n6. No fee for exercising rights (unless legally required).\n\n10. How do we update our Privacy Policy?\nWe may update it to reflect changes in our operations. Updates will be posted on the platform and become effective upon posting (or a stated effective date).\n\n11. Contact us:\nFor any inquiries:\n• WhatsApp: +971551228825\n• Email: info@kolshy.ae\nPlease include details in your message for faster assistance.'**
  String get legalMumboJumboPolicyText;

  /// No description provided for @adminNews.
  ///
  /// In en, this message translates to:
  /// **'Admin News'**
  String get adminNews;

  /// No description provided for @recentUpdates.
  ///
  /// In en, this message translates to:
  /// **'Recent Updates'**
  String get recentUpdates;

  /// No description provided for @refreshNews.
  ///
  /// In en, this message translates to:
  /// **'Refresh news'**
  String get refreshNews;

  /// No description provided for @noNews.
  ///
  /// In en, this message translates to:
  /// **'No news available'**
  String get noNews;

  /// No description provided for @newsRefreshed.
  ///
  /// In en, this message translates to:
  /// **'News refreshed'**
  String get newsRefreshed;

  /// No description provided for @newsDeleted.
  ///
  /// In en, this message translates to:
  /// **'News deleted'**
  String get newsDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @issueFixed.
  ///
  /// In en, this message translates to:
  /// **'Issue Fixed'**
  String get issueFixed;

  /// No description provided for @issueFixedContent.
  ///
  /// In en, this message translates to:
  /// **'The reported issue has been fixed successfully.'**
  String get issueFixedContent;

  /// No description provided for @newFeature.
  ///
  /// In en, this message translates to:
  /// **'New Feature'**
  String get newFeature;

  /// No description provided for @newFeatureContent.
  ///
  /// In en, this message translates to:
  /// **'A new feature has been added.'**
  String get newFeatureContent;

  /// No description provided for @serverMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Server Maintenance'**
  String get serverMaintenance;

  /// No description provided for @serverMaintenanceContent.
  ///
  /// In en, this message translates to:
  /// **'Scheduled maintenance is in progress.'**
  String get serverMaintenanceContent;

  /// No description provided for @deliveryIssues.
  ///
  /// In en, this message translates to:
  /// **'Delivery Issues'**
  String get deliveryIssues;

  /// No description provided for @deliveryIssuesContent.
  ///
  /// In en, this message translates to:
  /// **'Some deliveries are delayed.'**
  String get deliveryIssuesContent;

  /// No description provided for @paymentUpdate.
  ///
  /// In en, this message translates to:
  /// **'Payment Update'**
  String get paymentUpdate;

  /// No description provided for @paymentUpdateContent.
  ///
  /// In en, this message translates to:
  /// **'Payment system updated.'**
  String get paymentUpdateContent;

  /// No description provided for @securityAlert.
  ///
  /// In en, this message translates to:
  /// **'Security Alert'**
  String get securityAlert;

  /// No description provided for @securityAlertContent.
  ///
  /// In en, this message translates to:
  /// **'Please update your password.'**
  String get securityAlertContent;

  /// No description provided for @refreshed1.
  ///
  /// In en, this message translates to:
  /// **'Content Refreshed'**
  String get refreshed1;

  /// No description provided for @refreshed1Content.
  ///
  /// In en, this message translates to:
  /// **'The content has been refreshed.'**
  String get refreshed1Content;

  /// No description provided for @deliveryImproved.
  ///
  /// In en, this message translates to:
  /// **'Delivery Improved'**
  String get deliveryImproved;

  /// No description provided for @deliveryImprovedContent.
  ///
  /// In en, this message translates to:
  /// **'Delivery times have been optimized.'**
  String get deliveryImprovedContent;

  /// No description provided for @paymentGatewayUpdated.
  ///
  /// In en, this message translates to:
  /// **'Payment Gateway Updated'**
  String get paymentGatewayUpdated;

  /// No description provided for @paymentGatewayUpdatedContent.
  ///
  /// In en, this message translates to:
  /// **'The payment gateway has been updated.'**
  String get paymentGatewayUpdatedContent;

  /// No description provided for @bugFixes.
  ///
  /// In en, this message translates to:
  /// **'Bug Fixes'**
  String get bugFixes;

  /// No description provided for @bugFixesContent.
  ///
  /// In en, this message translates to:
  /// **'Minor bugs have been fixed.'**
  String get bugFixesContent;

  /// No description provided for @time2mAgo.
  ///
  /// In en, this message translates to:
  /// **'2 minutes ago'**
  String get time2mAgo;

  /// No description provided for @time10mAgo.
  ///
  /// In en, this message translates to:
  /// **'10 minutes ago'**
  String get time10mAgo;

  /// No description provided for @time1hAgo.
  ///
  /// In en, this message translates to:
  /// **'1 hour ago'**
  String get time1hAgo;

  /// No description provided for @time3hAgo.
  ///
  /// In en, this message translates to:
  /// **'3 hours ago'**
  String get time3hAgo;

  /// No description provided for @time5hAgo.
  ///
  /// In en, this message translates to:
  /// **'5 hours ago'**
  String get time5hAgo;

  /// No description provided for @time1dAgo.
  ///
  /// In en, this message translates to:
  /// **'1 day ago'**
  String get time1dAgo;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @askQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask Question to Admin'**
  String get askQuestionTitle;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @subjectTooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter a clear and concise subject for your request.'**
  String get subjectTooltip;

  /// No description provided for @inputHint.
  ///
  /// In en, this message translates to:
  /// **'Input your text'**
  String get inputHint;

  /// No description provided for @yourQuery.
  ///
  /// In en, this message translates to:
  /// **'Your Query'**
  String get yourQuery;

  /// No description provided for @enterSubject.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject.'**
  String get enterSubject;

  /// No description provided for @enterQuery.
  ///
  /// In en, this message translates to:
  /// **'Please enter your query.'**
  String get enterQuery;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent successfully!'**
  String get requestSent;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @askQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask Question to Admin'**
  String get askQuestion;

  /// No description provided for @errorSubject.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject.'**
  String get errorSubject;

  /// No description provided for @errorQuery.
  ///
  /// In en, this message translates to:
  /// **'Please enter your query.'**
  String get errorQuery;

  /// No description provided for @successMessage.
  ///
  /// In en, this message translates to:
  /// **'Request sent successfully!'**
  String get successMessage;

  /// No description provided for @customerAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Customer Analytics'**
  String get customerAnalytics;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customers;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @last7days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7days;

  /// No description provided for @last30days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30days;

  /// No description provided for @lastYear.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get lastYear;

  /// No description provided for @searchCustomer.
  ///
  /// In en, this message translates to:
  /// **'Search customer'**
  String get searchCustomer;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @noCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers match your search.'**
  String get noCustomers;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Store Dashboard'**
  String get appTitle;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloUser(Object name);

  /// No description provided for @letsCheckYourStore.
  ///
  /// In en, this message translates to:
  /// **'Let\'s check your store!'**
  String get letsCheckYourStore;

  /// No description provided for @rangeAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get rangeAllTime;

  /// No description provided for @rangeLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get rangeLast30Days;

  /// No description provided for @rangeLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get rangeLast7Days;

  /// No description provided for @rangeThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get rangeThisYear;

  /// No description provided for @statRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get statRevenue;

  /// No description provided for @statOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get statOrder;

  /// No description provided for @statCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get statCustomer;

  /// No description provided for @currencyAmount.
  ///
  /// In en, this message translates to:
  /// **'{currency} {amount}'**
  String currencyAmount(Object currency, Object amount);

  /// No description provided for @deltaSinceLastWeek.
  ///
  /// In en, this message translates to:
  /// **'{delta} Last Week'**
  String deltaSinceLastWeek(String delta);

  /// No description provided for @totalSalesTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSalesTitle;

  /// No description provided for @kpiTotalSales.
  ///
  /// In en, this message translates to:
  /// **'{pct} Total Sales'**
  String kpiTotalSales(String pct);

  /// No description provided for @legendYearRange.
  ///
  /// In en, this message translates to:
  /// **'Jan 1–Dec 31, {year}'**
  String legendYearRange(String year);

  /// No description provided for @totalCustomers.
  ///
  /// In en, this message translates to:
  /// **'Total customers'**
  String get totalCustomers;

  /// No description provided for @averageOrderValue.
  ///
  /// In en, this message translates to:
  /// **'Average Order Value'**
  String get averageOrderValue;

  /// No description provided for @aovLegend.
  ///
  /// In en, this message translates to:
  /// **'Average Order Value'**
  String get aovLegend;

  /// No description provided for @topSellingProducts.
  ///
  /// In en, this message translates to:
  /// **'Top Selling Products'**
  String get topSellingProducts;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get topCategories;

  /// No description provided for @ratings.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratings;

  /// No description provided for @latestCommentsAndReviews.
  ///
  /// In en, this message translates to:
  /// **'Latest Comments and Reviews'**
  String get latestCommentsAndReviews;

  /// No description provided for @noProductFound.
  ///
  /// In en, this message translates to:
  /// **'No product found'**
  String get noProductFound;

  /// No description provided for @noCategoryFound.
  ///
  /// In en, this message translates to:
  /// **'No Category found'**
  String get noCategoryFound;

  /// No description provided for @priceWithCurrency.
  ///
  /// In en, this message translates to:
  /// **'{currency} {price}'**
  String priceWithCurrency(String currency, double price);

  /// No description provided for @soldCount.
  ///
  /// In en, this message translates to:
  /// **'Sold {count}'**
  String soldCount(Object count);

  /// No description provided for @helpful.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get helpful;

  /// No description provided for @oldCustomer.
  ///
  /// In en, this message translates to:
  /// **'Old customer'**
  String get oldCustomer;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get newCustomer;

  /// No description provided for @returningCustomer.
  ///
  /// In en, this message translates to:
  /// **'Returning customer'**
  String get returningCustomer;

  /// No description provided for @welcomePrefix.
  ///
  /// In en, this message translates to:
  /// **'Welcome '**
  String get welcomePrefix;

  /// No description provided for @welcomeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} customers'**
  String welcomeCount(String count);

  /// No description provided for @welcomeSuffix.
  ///
  /// In en, this message translates to:
  /// **' with a personal message 🥳'**
  String get welcomeSuffix;

  /// No description provided for @monthsShort.
  ///
  /// In en, this message translates to:
  /// **'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec'**
  String get monthsShort;

  /// No description provided for @weekShort.
  ///
  /// In en, this message translates to:
  /// **'Mon,Tue,Wed,Thu,Fri,Sat,Sun'**
  String get weekShort;

  /// No description provided for @days30Anchor.
  ///
  /// In en, this message translates to:
  /// **'1,5,10,15,20,25,30'**
  String get days30Anchor;

  /// No description provided for @yearsAllTime.
  ///
  /// In en, this message translates to:
  /// **'2019,2020,2021,2022,2023,2024'**
  String get yearsAllTime;

  /// No description provided for @kpiAov.
  ///
  /// In en, this message translates to:
  /// **'{pct} Average Order Value'**
  String kpiAov(String pct);

  /// No description provided for @priceRating.
  ///
  /// In en, this message translates to:
  /// **'Price Rating'**
  String get priceRating;

  /// No description provided for @valueRating.
  ///
  /// In en, this message translates to:
  /// **'Value Rating'**
  String get valueRating;

  /// No description provided for @qualityRating.
  ///
  /// In en, this message translates to:
  /// **'Quality Rating'**
  String get qualityRating;

  /// No description provided for @checkStore.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Check Your Store!'**
  String get checkStore;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// No description provided for @latestReviews.
  ///
  /// In en, this message translates to:
  /// **'Latest Comments and Reviews'**
  String get latestReviews;

  /// No description provided for @checkBoxMsg.
  ///
  /// In en, this message translates to:
  /// **'Please check the box to proceed.'**
  String get checkBoxMsg;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmail;

  /// No description provided for @mailSent.
  ///
  /// In en, this message translates to:
  /// **'Mail sent'**
  String get mailSent;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @bell.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get bell;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @inputYourText.
  ///
  /// In en, this message translates to:
  /// **'Input your text'**
  String get inputYourText;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @underline.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get underline;

  /// No description provided for @bulletedList.
  ///
  /// In en, this message translates to:
  /// **'Bulleted list'**
  String get bulletedList;

  /// No description provided for @numberedList.
  ///
  /// In en, this message translates to:
  /// **'Numbered list'**
  String get numberedList;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orders;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @myProductList.
  ///
  /// In en, this message translates to:
  /// **'My product list'**
  String get myProductList;

  /// No description provided for @draftProduct.
  ///
  /// In en, this message translates to:
  /// **'Draft Product'**
  String get draftProduct;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @installMainApp.
  ///
  /// In en, this message translates to:
  /// **'Install main application'**
  String get installMainApp;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @printPdf.
  ///
  /// In en, this message translates to:
  /// **'Print PDF'**
  String get printPdf;

  /// No description provided for @askSupport.
  ///
  /// In en, this message translates to:
  /// **'Ask for support'**
  String get askSupport;

  /// No description provided for @productAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get productAdd;

  /// No description provided for @productList.
  ///
  /// In en, this message translates to:
  /// **'Product List'**
  String get productList;

  /// No description provided for @productDrafts.
  ///
  /// In en, this message translates to:
  /// **'Product Drafts'**
  String get productDrafts;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @payouts.
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get payouts;

  /// No description provided for @customerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Customer Dashboard'**
  String get customerDashboard;

  /// No description provided for @askAdmin.
  ///
  /// In en, this message translates to:
  /// **'Ask Admin'**
  String get askAdmin;

  /// No description provided for @installMainApplication.
  ///
  /// In en, this message translates to:
  /// **'Install main application'**
  String get installMainApplication;

  /// No description provided for @askForSupport.
  ///
  /// In en, this message translates to:
  /// **'Ask for support'**
  String get askForSupport;

  /// No description provided for @printPDF.
  ///
  /// In en, this message translates to:
  /// **'Print PDF'**
  String get printPDF;

  /// No description provided for @askforsupport.
  ///
  /// In en, this message translates to:
  /// **'Ask for support'**
  String get askforsupport;

  /// No description provided for @installmainapplication.
  ///
  /// In en, this message translates to:
  /// **'Install main application'**
  String get installmainapplication;

  /// No description provided for @letsCheckStore.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Check Your Store!'**
  String get letsCheckStore;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @percentTotalSales.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Total Sales'**
  String percentTotalSales(Object percent);

  /// No description provided for @millionsSuffix.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get millionsSuffix;

  /// No description provided for @legendRangeYear.
  ///
  /// In en, this message translates to:
  /// **'Jan 1–Dec 31, {year}'**
  String legendRangeYear(Object year);

  /// No description provided for @catHeadphones.
  ///
  /// In en, this message translates to:
  /// **'Headphones'**
  String get catHeadphones;

  /// No description provided for @catWatches.
  ///
  /// In en, this message translates to:
  /// **'Watches'**
  String get catWatches;

  /// No description provided for @catCameras.
  ///
  /// In en, this message translates to:
  /// **'Cameras'**
  String get catCameras;

  /// No description provided for @catAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get catAccessories;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(Object count);

  /// No description provided for @latestCommentsReviews.
  ///
  /// In en, this message translates to:
  /// **'Latest Comments and Reviews'**
  String get latestCommentsReviews;

  /// No description provided for @customersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} customers'**
  String customersCount(Object count);

  /// No description provided for @withPersonalMessage.
  ///
  /// In en, this message translates to:
  /// **'with a personal message'**
  String get withPersonalMessage;

  /// No description provided for @percentAov.
  ///
  /// In en, this message translates to:
  /// **'{percent} Average Order Value'**
  String percentAov(Object percent);

  /// No description provided for @weekMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekMon;

  /// No description provided for @weekTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekTue;

  /// No description provided for @weekWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekWed;

  /// No description provided for @weekThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekThu;

  /// No description provided for @weekFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekFri;

  /// No description provided for @weekSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekSat;

  /// No description provided for @weekSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekSun;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @r1.
  ///
  /// In en, this message translates to:
  /// **'Super comfy and the battery life is crazy good.'**
  String get r1;

  /// No description provided for @r2.
  ///
  /// In en, this message translates to:
  /// **'Does everything I need. Wish the strap was softer.'**
  String get r2;

  /// No description provided for @ordersDetails.
  ///
  /// In en, this message translates to:
  /// **'Orders Details'**
  String get ordersDetails;

  /// No description provided for @searchProduct.
  ///
  /// In en, this message translates to:
  /// **'Search product'**
  String get searchProduct;

  /// No description provided for @allOrders.
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get allOrders;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders match your search.'**
  String get noOrders;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @purchasedOn.
  ///
  /// In en, this message translates to:
  /// **'Purchased on'**
  String get purchasedOn;

  /// No description provided for @baseTotal.
  ///
  /// In en, this message translates to:
  /// **'Base Total'**
  String get baseTotal;

  /// No description provided for @purchasedTotal.
  ///
  /// In en, this message translates to:
  /// **'Purchased Total'**
  String get purchasedTotal;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @onHold.
  ///
  /// In en, this message translates to:
  /// **'On Hold'**
  String get onHold;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @printPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Print PDF'**
  String get printPdfTitle;

  /// No description provided for @invoiceDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice and Packing Slip Details'**
  String get invoiceDetailsTitle;

  /// No description provided for @invoiceDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your address, VAT, and tax information for PDF documents'**
  String get invoiceDetailsSubtitle;

  /// No description provided for @invoiceDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your company address, VAT number, tax information...'**
  String get invoiceDetailsHint;

  /// No description provided for @saveInfoButton.
  ///
  /// In en, this message translates to:
  /// **'Save Information'**
  String get saveInfoButton;

  /// No description provided for @saveInfoEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter information before saving'**
  String get saveInfoEmpty;

  /// No description provided for @saveInfoSuccess.
  ///
  /// In en, this message translates to:
  /// **'Information saved successfully!'**
  String get saveInfoSuccess;

  /// No description provided for @invoiceDetailsFooter.
  ///
  /// In en, this message translates to:
  /// **'This information will be included in all your PDF invoices and packing slips.'**
  String get invoiceDetailsFooter;

  /// No description provided for @nameAndDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Name & Description'**
  String get nameAndDescriptionTitle;

  /// No description provided for @productTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Title'**
  String get productTitleLabel;

  /// No description provided for @productTitleHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter the full product name (e.g., Apple iPhone 14 Pro).'**
  String get productTitleHelp;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @categoryHelp.
  ///
  /// In en, this message translates to:
  /// **'Select the category that best fits your product.'**
  String get categoryHelp;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryApparel.
  ///
  /// In en, this message translates to:
  /// **'Apparel'**
  String get categoryApparel;

  /// No description provided for @categoryBeauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get categoryBeauty;

  /// No description provided for @categoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get categoryHome;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @tagsHelp.
  ///
  /// In en, this message translates to:
  /// **'Add keywords that describe your product.'**
  String get tagsHelp;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionHelp.
  ///
  /// In en, this message translates to:
  /// **'Detailed description of features, materials, sizing, etc.'**
  String get descriptionHelp;

  /// No description provided for @shortDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Short Description'**
  String get shortDescriptionLabel;

  /// No description provided for @shortDescriptionHelp.
  ///
  /// In en, this message translates to:
  /// **'Short summary (1–2 sentences) for listings/search results.'**
  String get shortDescriptionHelp;

  /// No description provided for @skuLabel.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get skuLabel;

  /// No description provided for @skuHelp.
  ///
  /// In en, this message translates to:
  /// **'Unique stock keeping unit (e.g., SKU-12345).'**
  String get skuHelp;

  /// No description provided for @priceTitle.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceTitle;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @amountHelp.
  ///
  /// In en, this message translates to:
  /// **'Base selling price without discounts.'**
  String get amountHelp;

  /// No description provided for @validNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get validNumber;

  /// No description provided for @specialPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Special Price'**
  String get specialPriceLabel;

  /// No description provided for @specialPriceHelp.
  ///
  /// In en, this message translates to:
  /// **'Turn on to add a promotional/sale price.'**
  String get specialPriceHelp;

  /// No description provided for @specialPriceError.
  ///
  /// In en, this message translates to:
  /// **'Special price must be less than Amount'**
  String get specialPriceError;

  /// No description provided for @specialPriceLabel2.
  ///
  /// In en, this message translates to:
  /// **'Special price'**
  String get specialPriceLabel2;

  /// No description provided for @specialPriceHelp2.
  ///
  /// In en, this message translates to:
  /// **'Discounted price that overrides the regular amount.'**
  String get specialPriceHelp2;

  /// No description provided for @priceExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., 24.99'**
  String get priceExample;

  /// No description provided for @minAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount'**
  String get minAmountLabel;

  /// No description provided for @minAmountHelp.
  ///
  /// In en, this message translates to:
  /// **'Minimum quantity a customer is allowed to purchase.'**
  String get minAmountHelp;

  /// No description provided for @maxAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount'**
  String get maxAmountLabel;

  /// No description provided for @maxAmountHelp.
  ///
  /// In en, this message translates to:
  /// **'Maximum quantity a customer is allowed to purchase.'**
  String get maxAmountHelp;

  /// No description provided for @taxesLabel.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get taxesLabel;

  /// No description provided for @taxesHelp.
  ///
  /// In en, this message translates to:
  /// **'Apply taxes to this product at checkout.'**
  String get taxesHelp;

  /// No description provided for @stockAndAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock & Availability'**
  String get stockAndAvailabilityTitle;

  /// No description provided for @stockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockLabel;

  /// No description provided for @stockHelp.
  ///
  /// In en, this message translates to:
  /// **'Number of units available.'**
  String get stockHelp;

  /// No description provided for @stockExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., 100'**
  String get stockExample;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @weightHelp.
  ///
  /// In en, this message translates to:
  /// **'Weight in kilograms (used for shipping).'**
  String get weightHelp;

  /// No description provided for @weightExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., 0.50'**
  String get weightExample;

  /// No description provided for @allowedQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Allowed Quantity per Customer'**
  String get allowedQuantityLabel;

  /// No description provided for @allowedQuantityHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional: maximum number of units a single customer can buy for this product.'**
  String get allowedQuantityHelp;

  /// No description provided for @allowedQuantityExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., 5'**
  String get allowedQuantityExample;

  /// No description provided for @nonNegativeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a non-negative number'**
  String get nonNegativeNumber;

  /// No description provided for @stockAvailabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock Availability'**
  String get stockAvailabilityLabel;

  /// No description provided for @stockAvailabilityHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose current availability status.'**
  String get stockAvailabilityHelp;

  /// No description provided for @stockInStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get stockInStock;

  /// No description provided for @stockOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get stockOutOfStock;

  /// No description provided for @visibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibilityLabel;

  /// No description provided for @visibilityHelp.
  ///
  /// In en, this message translates to:
  /// **'Invisible products are hidden from the storefront.'**
  String get visibilityHelp;

  /// No description provided for @visibilityInvisible.
  ///
  /// In en, this message translates to:
  /// **'Invisible'**
  String get visibilityInvisible;

  /// No description provided for @visibilityVisible.
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get visibilityVisible;

  /// No description provided for @metaInfosTitle.
  ///
  /// In en, this message translates to:
  /// **'Meta Infos'**
  String get metaInfosTitle;

  /// No description provided for @urlKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Url Key'**
  String get urlKeyLabel;

  /// No description provided for @urlKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'SEO-friendly slug used in the product URL.'**
  String get urlKeyHelp;

  /// No description provided for @urlKeyExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., apple-iphone-14-pro'**
  String get urlKeyExample;

  /// No description provided for @metaTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Meta Title'**
  String get metaTitleLabel;

  /// No description provided for @metaTitleHelp.
  ///
  /// In en, this message translates to:
  /// **'Title shown in search engine results.'**
  String get metaTitleHelp;

  /// No description provided for @metaTitleExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Buy the iPhone 14 Pro'**
  String get metaTitleExample;

  /// No description provided for @metaKeywordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Meta Keywords'**
  String get metaKeywordsLabel;

  /// No description provided for @metaKeywordsHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional: comma-separated keywords.'**
  String get metaKeywordsHelp;

  /// No description provided for @metaDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Meta Description'**
  String get metaDescriptionLabel;

  /// No description provided for @metaDescriptionHelp.
  ///
  /// In en, this message translates to:
  /// **'Short paragraph for search engines (150–160 chars).'**
  String get metaDescriptionHelp;

  /// No description provided for @coverImagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Cover images'**
  String get coverImagesLabel;

  /// No description provided for @coverImagesHelp.
  ///
  /// In en, this message translates to:
  /// **'Upload a clear, high-resolution product image.'**
  String get coverImagesHelp;

  /// No description provided for @clickOrDropImage.
  ///
  /// In en, this message translates to:
  /// **'Click or drop Image'**
  String get clickOrDropImage;

  /// No description provided for @saveDraftButton.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraftButton;

  /// No description provided for @publishNowButton.
  ///
  /// In en, this message translates to:
  /// **'Publish now'**
  String get publishNowButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get draftSaved;

  /// No description provided for @productPublished.
  ///
  /// In en, this message translates to:
  /// **'Product published'**
  String get productPublished;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" has been deleted'**
  String productDeleted(Object name);

  /// No description provided for @draftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get draftsTitle;

  /// No description provided for @searchDraft.
  ///
  /// In en, this message translates to:
  /// **'Search draft'**
  String get searchDraft;

  /// No description provided for @allDrafts.
  ///
  /// In en, this message translates to:
  /// **'All Drafts'**
  String get allDrafts;

  /// No description provided for @drafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get drafts;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get pendingReview;

  /// No description provided for @noDraftsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No drafts match your search.'**
  String get noDraftsMatchSearch;

  /// No description provided for @deleteDraftQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete draft?'**
  String get deleteDraftQuestion;

  /// No description provided for @deleteDraftConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will delete \"{name}\".'**
  String deleteDraftConfirmation(Object name);

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get createdLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @actionLabel.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get actionLabel;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'List of Products'**
  String get productsTitle;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get allProducts;

  /// No description provided for @enabledProducts.
  ///
  /// In en, this message translates to:
  /// **'Enabled Products'**
  String get enabledProducts;

  /// No description provided for @disabledProducts.
  ///
  /// In en, this message translates to:
  /// **'Disabled Products'**
  String get disabledProducts;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @deniedProduct.
  ///
  /// In en, this message translates to:
  /// **'Denied Product'**
  String get deniedProduct;

  /// No description provided for @noProductsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No products match your search.'**
  String get noProductsMatchSearch;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @deleteProductConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteProductConfirmation(Object name);

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get idLabel;

  /// No description provided for @quantityPerSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity Per Source'**
  String get quantityPerSourceLabel;

  /// No description provided for @salableQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Salable Quantity'**
  String get salableQuantityLabel;

  /// No description provided for @quantitySoldLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity Sold'**
  String get quantitySoldLabel;

  /// No description provided for @quantityConfirmedLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity Confirmed'**
  String get quantityConfirmedLabel;

  /// No description provided for @quantityPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity Pending'**
  String get quantityPendingLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get statusDisabled;

  /// No description provided for @statusLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get statusLowStock;

  /// No description provided for @statusOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get statusOutOfStock;

  /// No description provided for @statusDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get statusDenied;

  /// No description provided for @visibilityCatalogSearch.
  ///
  /// In en, this message translates to:
  /// **'Catalog / Search'**
  String get visibilityCatalogSearch;

  /// No description provided for @visibilityCatalogOnly.
  ///
  /// In en, this message translates to:
  /// **'Catalog Only'**
  String get visibilityCatalogOnly;

  /// No description provided for @visibilitySearchOnly.
  ///
  /// In en, this message translates to:
  /// **'Search Only'**
  String get visibilitySearchOnly;

  /// No description provided for @visibilityNotVisible.
  ///
  /// In en, this message translates to:
  /// **'Not Visible'**
  String get visibilityNotVisible;

  /// No description provided for @editProductScreen.
  ///
  /// In en, this message translates to:
  /// **'Edit Product Screen'**
  String get editProductScreen;

  /// No description provided for @customerAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Analytics'**
  String get customerAnalyticsTitle;

  /// No description provided for @customersLabel.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersLabel;

  /// No description provided for @incomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeLabel;

  /// No description provided for @searchCustomerHint.
  ///
  /// In en, this message translates to:
  /// **'Search customer'**
  String get searchCustomerHint;

  /// No description provided for @loadMoreButton.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMoreButton;

  /// No description provided for @noCustomersMatch.
  ///
  /// In en, this message translates to:
  /// **'No customers match your search.'**
  String get noCustomersMatch;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @baseTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Base Total'**
  String get baseTotalLabel;

  /// No description provided for @ordersLabel.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersLabel;

  /// No description provided for @maleLabel.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get maleLabel;

  /// No description provided for @femaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get femaleLabel;

  /// No description provided for @inputYourTextHint.
  ///
  /// In en, this message translates to:
  /// **'Input your text'**
  String get inputYourTextHint;

  /// No description provided for @addTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTagHint;

  /// No description provided for @skuHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: SKU-12345'**
  String get skuHint;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @specialPriceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 24.99'**
  String get specialPriceHint;

  /// No description provided for @stockAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Stock & Availability'**
  String get stockAvailabilityTitle;

  /// No description provided for @stockHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 100'**
  String get stockHint;

  /// No description provided for @weightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 0.50'**
  String get weightHint;

  /// No description provided for @maxQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 5'**
  String get maxQuantityHint;

  /// No description provided for @enterNonNegativeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a non-negative number'**
  String get enterNonNegativeNumber;

  /// No description provided for @invisible.
  ///
  /// In en, this message translates to:
  /// **'Invisible'**
  String get invisible;

  /// No description provided for @visible.
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get visible;

  /// No description provided for @metaInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Meta Infos'**
  String get metaInfoTitle;

  /// No description provided for @urlKeyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., apple-iphone-14-pro'**
  String get urlKeyHint;

  /// No description provided for @metaTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Buy the iPhone 14 Pro'**
  String get metaTitleHint;

  /// No description provided for @productImagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Product Images'**
  String get productImagesLabel;

  /// No description provided for @productImagesHelp.
  ///
  /// In en, this message translates to:
  /// **'It is preferable to upload 3 images of the product.'**
  String get productImagesHelp;

  /// No description provided for @threeImagesWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Preferably upload at least 3 images'**
  String get threeImagesWarning;

  /// No description provided for @linkedProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Linked Products'**
  String get linkedProductsTitle;

  /// No description provided for @deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTooltip;

  /// No description provided for @sec_name_description.
  ///
  /// In en, this message translates to:
  /// **'Name & description'**
  String get sec_name_description;

  /// No description provided for @lbl_product_title.
  ///
  /// In en, this message translates to:
  /// **'Product title'**
  String get lbl_product_title;

  /// No description provided for @help_product_title.
  ///
  /// In en, this message translates to:
  /// **'Enter the full product name (e.g., Apple iPhone 14 Pro).'**
  String get help_product_title;

  /// No description provided for @hint_input_text.
  ///
  /// In en, this message translates to:
  /// **'Input your text'**
  String get hint_input_text;

  /// No description provided for @v_required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get v_required;

  /// No description provided for @lbl_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get lbl_category;

  /// No description provided for @help_category.
  ///
  /// In en, this message translates to:
  /// **'Select the category that best fits your product.'**
  String get help_category;

  /// No description provided for @lbl_tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get lbl_tags;

  /// No description provided for @help_tags.
  ///
  /// In en, this message translates to:
  /// **'Add keywords that describe your product.'**
  String get help_tags;

  /// No description provided for @hint_add_tag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get hint_add_tag;

  /// No description provided for @lbl_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get lbl_description;

  /// No description provided for @help_description.
  ///
  /// In en, this message translates to:
  /// **'Detailed description of features, materials, sizing, etc.'**
  String get help_description;

  /// No description provided for @lbl_short_description.
  ///
  /// In en, this message translates to:
  /// **'Short Description'**
  String get lbl_short_description;

  /// No description provided for @help_short_description.
  ///
  /// In en, this message translates to:
  /// **'Short summary (1–2 sentences) for listings/search results.'**
  String get help_short_description;

  /// No description provided for @lbl_sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get lbl_sku;

  /// No description provided for @help_sku.
  ///
  /// In en, this message translates to:
  /// **'Unique stock keeping unit (e.g., SKU-12345).'**
  String get help_sku;

  /// No description provided for @hint_sku.
  ///
  /// In en, this message translates to:
  /// **'Ex: SKU-12345'**
  String get hint_sku;

  /// No description provided for @sec_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get sec_price;

  /// No description provided for @lbl_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get lbl_amount;

  /// No description provided for @help_amount.
  ///
  /// In en, this message translates to:
  /// **'Base selling price without discounts.'**
  String get help_amount;

  /// No description provided for @hint_amount_default.
  ///
  /// In en, this message translates to:
  /// **'8'**
  String get hint_amount_default;

  /// No description provided for @v_number.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get v_number;

  /// No description provided for @lbl_special_toggle.
  ///
  /// In en, this message translates to:
  /// **'Special Price'**
  String get lbl_special_toggle;

  /// No description provided for @help_special_toggle.
  ///
  /// In en, this message translates to:
  /// **'Turn on to add a promotional/sale price.'**
  String get help_special_toggle;

  /// No description provided for @lbl_special_price.
  ///
  /// In en, this message translates to:
  /// **'Special price'**
  String get lbl_special_price;

  /// No description provided for @help_special_price.
  ///
  /// In en, this message translates to:
  /// **'Discounted price that overrides the regular amount.'**
  String get help_special_price;

  /// No description provided for @hint_price_example.
  ///
  /// In en, this message translates to:
  /// **'e.g., 24.99'**
  String get hint_price_example;

  /// No description provided for @lbl_min_qty.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount'**
  String get lbl_min_qty;

  /// No description provided for @help_min_qty.
  ///
  /// In en, this message translates to:
  /// **'Minimum quantity a customer is allowed to purchase.'**
  String get help_min_qty;

  /// No description provided for @lbl_max_qty.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount'**
  String get lbl_max_qty;

  /// No description provided for @help_max_qty.
  ///
  /// In en, this message translates to:
  /// **'Maximum quantity a customer is allowed to purchase.'**
  String get help_max_qty;

  /// No description provided for @lbl_taxes.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get lbl_taxes;

  /// No description provided for @help_taxes.
  ///
  /// In en, this message translates to:
  /// **'Apply taxes to this product at checkout.'**
  String get help_taxes;

  /// No description provided for @sec_stock_availability.
  ///
  /// In en, this message translates to:
  /// **'Stock & Availability'**
  String get sec_stock_availability;

  /// No description provided for @lbl_stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get lbl_stock;

  /// No description provided for @help_stock.
  ///
  /// In en, this message translates to:
  /// **'Number of units available.'**
  String get help_stock;

  /// No description provided for @hint_stock.
  ///
  /// In en, this message translates to:
  /// **'e.g., 100'**
  String get hint_stock;

  /// No description provided for @lbl_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get lbl_weight;

  /// No description provided for @help_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight in kilograms (used for shipping).'**
  String get help_weight;

  /// No description provided for @hint_weight.
  ///
  /// In en, this message translates to:
  /// **'e.g., 0.50'**
  String get hint_weight;

  /// No description provided for @lbl_allowed_qty_per_customer.
  ///
  /// In en, this message translates to:
  /// **'Allowed Quantity per Customer'**
  String get lbl_allowed_qty_per_customer;

  /// No description provided for @help_allowed_qty_per_customer.
  ///
  /// In en, this message translates to:
  /// **'Optional: maximum number of units a single customer can buy for this product.'**
  String get help_allowed_qty_per_customer;

  /// No description provided for @hint_allowed_qty.
  ///
  /// In en, this message translates to:
  /// **'e.g., 5'**
  String get hint_allowed_qty;

  /// No description provided for @v_non_negative.
  ///
  /// In en, this message translates to:
  /// **'Enter a non-negative number'**
  String get v_non_negative;

  /// No description provided for @lbl_stock_availability.
  ///
  /// In en, this message translates to:
  /// **'Stock Availability'**
  String get lbl_stock_availability;

  /// No description provided for @help_stock_availability.
  ///
  /// In en, this message translates to:
  /// **'Choose current availability status.'**
  String get help_stock_availability;

  /// No description provided for @lbl_visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get lbl_visibility;

  /// No description provided for @help_visibility.
  ///
  /// In en, this message translates to:
  /// **'Invisible products are hidden from the storefront.'**
  String get help_visibility;

  /// No description provided for @sec_meta_infos.
  ///
  /// In en, this message translates to:
  /// **'Meta Infos'**
  String get sec_meta_infos;

  /// No description provided for @lbl_url_key.
  ///
  /// In en, this message translates to:
  /// **'Url Key'**
  String get lbl_url_key;

  /// No description provided for @help_url_key.
  ///
  /// In en, this message translates to:
  /// **'SEO-friendly slug used in the product URL.'**
  String get help_url_key;

  /// No description provided for @hint_url_key.
  ///
  /// In en, this message translates to:
  /// **'e.g., apple-iphone-14-pro'**
  String get hint_url_key;

  /// No description provided for @lbl_meta_title.
  ///
  /// In en, this message translates to:
  /// **'Meta Title'**
  String get lbl_meta_title;

  /// No description provided for @help_meta_title.
  ///
  /// In en, this message translates to:
  /// **'Title shown in search engine results.'**
  String get help_meta_title;

  /// No description provided for @hint_meta_title.
  ///
  /// In en, this message translates to:
  /// **'e.g., Buy the iPhone 14 Pro'**
  String get hint_meta_title;

  /// No description provided for @lbl_meta_keywords.
  ///
  /// In en, this message translates to:
  /// **'Meta Keywords'**
  String get lbl_meta_keywords;

  /// No description provided for @help_meta_keywords.
  ///
  /// In en, this message translates to:
  /// **'Optional: comma-separated keywords.'**
  String get help_meta_keywords;

  /// No description provided for @lbl_meta_description.
  ///
  /// In en, this message translates to:
  /// **'Meta Description'**
  String get lbl_meta_description;

  /// No description provided for @help_meta_description.
  ///
  /// In en, this message translates to:
  /// **'Short paragraph for search engines (150–160 chars).'**
  String get help_meta_description;

  /// No description provided for @lbl_product_images.
  ///
  /// In en, this message translates to:
  /// **'Product Images'**
  String get lbl_product_images;

  /// No description provided for @help_product_images.
  ///
  /// In en, this message translates to:
  /// **'It is preferable to upload 3 images of the product.'**
  String get help_product_images;

  /// No description provided for @btn_click_or_drop_image.
  ///
  /// In en, this message translates to:
  /// **'Click or drop image'**
  String get btn_click_or_drop_image;

  /// No description provided for @warn_prefer_three_images.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Preferably upload at least 3 images'**
  String get warn_prefer_three_images;

  /// No description provided for @sec_linked_products.
  ///
  /// In en, this message translates to:
  /// **'Linked Products'**
  String get sec_linked_products;

  /// No description provided for @title_product_relationships.
  ///
  /// In en, this message translates to:
  /// **'Product Relationships'**
  String get title_product_relationships;

  /// No description provided for @tab_related.
  ///
  /// In en, this message translates to:
  /// **'Related'**
  String get tab_related;

  /// No description provided for @tab_upsell.
  ///
  /// In en, this message translates to:
  /// **'Up-Sell'**
  String get tab_upsell;

  /// No description provided for @tab_crosssell.
  ///
  /// In en, this message translates to:
  /// **'Cross-Sell'**
  String get tab_crosssell;

  /// No description provided for @related_products.
  ///
  /// In en, this message translates to:
  /// **'Related Products'**
  String get related_products;

  /// No description provided for @upsell_products.
  ///
  /// In en, this message translates to:
  /// **'Up-Sell Products'**
  String get upsell_products;

  /// No description provided for @crosssell_products.
  ///
  /// In en, this message translates to:
  /// **'Cross-Sell Products'**
  String get crosssell_products;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @btn_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get btn_reset;

  /// No description provided for @btn_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get btn_apply;

  /// No description provided for @status_enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get status_enabled;

  /// No description provided for @status_disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get status_disabled;

  /// No description provided for @btn_filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get btn_filters;

  /// No description provided for @btn_filters_on.
  ///
  /// In en, this message translates to:
  /// **'Filters • On'**
  String get btn_filters_on;

  /// No description provided for @filters_showing_enabled_only.
  ///
  /// In en, this message translates to:
  /// **'Showing: Enabled only'**
  String get filters_showing_enabled_only;

  /// No description provided for @filters_showing_disabled_only.
  ///
  /// In en, this message translates to:
  /// **'Showing: Disabled only'**
  String get filters_showing_disabled_only;

  /// No description provided for @filters_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom filters'**
  String get filters_custom;

  /// No description provided for @empty_no_linked_products.
  ///
  /// In en, this message translates to:
  /// **'No linked products yet'**
  String get empty_no_linked_products;

  /// No description provided for @empty_no_linked_products_desc.
  ///
  /// In en, this message translates to:
  /// **'Add related, up-sell or cross-sell products to improve discovery and increase AOV.'**
  String get empty_no_linked_products_desc;

  /// No description provided for @btn_add_product.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get btn_add_product;

  /// No description provided for @btn_browse_catalog.
  ///
  /// In en, this message translates to:
  /// **'Browse Catalog'**
  String get btn_browse_catalog;

  /// No description provided for @btn_save_draft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get btn_save_draft;

  /// No description provided for @btn_publish_now.
  ///
  /// In en, this message translates to:
  /// **'Publish now'**
  String get btn_publish_now;

  /// No description provided for @btn_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btn_edit;

  /// No description provided for @btn_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btn_delete;

  /// No description provided for @tt_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tt_delete;

  /// No description provided for @lbl_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get lbl_price;

  /// No description provided for @id_with_value.
  ///
  /// In en, this message translates to:
  /// **'ID: {value}'**
  String id_with_value(String value);

  /// No description provided for @inventory_with_value.
  ///
  /// In en, this message translates to:
  /// **'Inventory: {value}'**
  String inventory_with_value(String value);

  /// No description provided for @price_with_currency.
  ///
  /// In en, this message translates to:
  /// **'\${value}'**
  String price_with_currency(String value);

  /// No description provided for @err_add_three_images.
  ///
  /// In en, this message translates to:
  /// **'Please add at least 3 product images'**
  String get err_add_three_images;

  /// No description provided for @err_special_lower_than_amount.
  ///
  /// In en, this message translates to:
  /// **'Special price must be less than Amount'**
  String get err_special_lower_than_amount;

  /// No description provided for @toast_draft_saved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get toast_draft_saved;

  /// No description provided for @toast_product_published.
  ///
  /// In en, this message translates to:
  /// **'Product published'**
  String get toast_product_published;

  /// No description provided for @toast_product_deleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get toast_product_deleted;

  /// No description provided for @curr_symbol.
  ///
  /// In en, this message translates to:
  /// **'\$'**
  String get curr_symbol;

  /// No description provided for @cat_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get cat_food;

  /// No description provided for @cat_electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get cat_electronics;

  /// No description provided for @cat_apparel.
  ///
  /// In en, this message translates to:
  /// **'Apparel'**
  String get cat_apparel;

  /// No description provided for @cat_beauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get cat_beauty;

  /// No description provided for @cat_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get cat_home;

  /// No description provided for @cat_home_appliances.
  ///
  /// In en, this message translates to:
  /// **'Home Appliances'**
  String get cat_home_appliances;

  /// No description provided for @cat_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cat_other;

  /// No description provided for @stock_in.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get stock_in;

  /// No description provided for @stock_out.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get stock_out;

  /// No description provided for @visibility_invisible.
  ///
  /// In en, this message translates to:
  /// **'Invisible'**
  String get visibility_invisible;

  /// No description provided for @visibility_visible.
  ///
  /// In en, this message translates to:
  /// **'Visible'**
  String get visibility_visible;

  /// No description provided for @hint_search_name_sku.
  ///
  /// In en, this message translates to:
  /// **'Search name, SKU…'**
  String get hint_search_name_sku;

  /// No description provided for @inv_in_stock_label.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inv_in_stock_label;

  /// No description provided for @inv_low_stock_label.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get inv_low_stock_label;

  /// No description provided for @inv_out_stock_label.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get inv_out_stock_label;

  /// No description provided for @demo_mouse_name.
  ///
  /// In en, this message translates to:
  /// **'Wireless Ergonomic Mouse'**
  String get demo_mouse_name;

  /// No description provided for @demo_tshirt_name.
  ///
  /// In en, this message translates to:
  /// **'Organic Cotton T-Shirt'**
  String get demo_tshirt_name;

  /// No description provided for @demo_espresso_name.
  ///
  /// In en, this message translates to:
  /// **'Espresso Coffee Machine'**
  String get demo_espresso_name;

  /// No description provided for @profile_settings.
  ///
  /// In en, this message translates to:
  /// **'Profile settings'**
  String get profile_settings;

  /// No description provided for @sec_profile_information.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get sec_profile_information;

  /// No description provided for @lbl_company_logo.
  ///
  /// In en, this message translates to:
  /// **'Company Logo'**
  String get lbl_company_logo;

  /// No description provided for @help_company_logo.
  ///
  /// In en, this message translates to:
  /// **'Upload your company logo'**
  String get help_company_logo;

  /// No description provided for @lbl_company_banner.
  ///
  /// In en, this message translates to:
  /// **'Company Banner'**
  String get lbl_company_banner;

  /// No description provided for @help_company_banner.
  ///
  /// In en, this message translates to:
  /// **'Upload your company banner'**
  String get help_company_banner;

  /// No description provided for @lbl_display_name.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get lbl_display_name;

  /// No description provided for @help_display_name.
  ///
  /// In en, this message translates to:
  /// **'The name that will be displayed on your vendor profile'**
  String get help_display_name;

  /// No description provided for @hint_company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get hint_company;

  /// No description provided for @lbl_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get lbl_location;

  /// No description provided for @help_location.
  ///
  /// In en, this message translates to:
  /// **'The physical location of your business'**
  String get help_location;

  /// No description provided for @lbl_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get lbl_phone_number;

  /// No description provided for @help_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Your company\'s contact phone number'**
  String get help_phone_number;

  /// No description provided for @hint_phone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get hint_phone;

  /// No description provided for @lbl_bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get lbl_bio;

  /// No description provided for @help_bio.
  ///
  /// In en, this message translates to:
  /// **'A short description of your company.'**
  String get help_bio;

  /// No description provided for @lbl_low_stock_qty.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Quantity'**
  String get lbl_low_stock_qty;

  /// No description provided for @help_low_stock_qty.
  ///
  /// In en, this message translates to:
  /// **'Set the threshold for low stock warnings'**
  String get help_low_stock_qty;

  /// No description provided for @lbl_tax_vat.
  ///
  /// In en, this message translates to:
  /// **'Tax/VAT Number'**
  String get lbl_tax_vat;

  /// No description provided for @help_tax_vat.
  ///
  /// In en, this message translates to:
  /// **'Your official tax or VAT identification number'**
  String get help_tax_vat;

  /// No description provided for @lbl_payment_details.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get lbl_payment_details;

  /// No description provided for @help_payment_details.
  ///
  /// In en, this message translates to:
  /// **'Details on how customers can pay for products.'**
  String get help_payment_details;

  /// No description provided for @lbl_social_ids.
  ///
  /// In en, this message translates to:
  /// **'Social Media IDs'**
  String get lbl_social_ids;

  /// No description provided for @help_social_ids.
  ///
  /// In en, this message translates to:
  /// **'Link your social media profiles'**
  String get help_social_ids;

  /// No description provided for @sm_twitter.
  ///
  /// In en, this message translates to:
  /// **'Twitter ID'**
  String get sm_twitter;

  /// No description provided for @sm_facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook ID'**
  String get sm_facebook;

  /// No description provided for @sm_instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram ID'**
  String get sm_instagram;

  /// No description provided for @sm_youtube.
  ///
  /// In en, this message translates to:
  /// **'Youtube ID'**
  String get sm_youtube;

  /// No description provided for @sm_vimeo.
  ///
  /// In en, this message translates to:
  /// **'Vimeo ID'**
  String get sm_vimeo;

  /// No description provided for @sm_pinterest.
  ///
  /// In en, this message translates to:
  /// **'Pinterest ID'**
  String get sm_pinterest;

  /// No description provided for @sm_moleskine.
  ///
  /// In en, this message translates to:
  /// **'Moleskine ID'**
  String get sm_moleskine;

  /// No description provided for @sm_tiktok.
  ///
  /// In en, this message translates to:
  /// **'Tiktok ID'**
  String get sm_tiktok;

  /// No description provided for @sec_company_policy.
  ///
  /// In en, this message translates to:
  /// **'Company Policy'**
  String get sec_company_policy;

  /// No description provided for @lbl_return_policy.
  ///
  /// In en, this message translates to:
  /// **'Return Policy'**
  String get lbl_return_policy;

  /// No description provided for @help_return_policy.
  ///
  /// In en, this message translates to:
  /// **'Describe your company’s return policy.'**
  String get help_return_policy;

  /// No description provided for @lbl_shipping_policy.
  ///
  /// In en, this message translates to:
  /// **'Shipping Policy'**
  String get lbl_shipping_policy;

  /// No description provided for @help_shipping_policy.
  ///
  /// In en, this message translates to:
  /// **'Describe your company’s shipping policy.'**
  String get help_shipping_policy;

  /// No description provided for @lbl_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get lbl_privacy_policy;

  /// No description provided for @help_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Describe your company’s privacy policy.'**
  String get help_privacy_policy;

  /// No description provided for @sec_meta_information.
  ///
  /// In en, this message translates to:
  /// **'Meta Information'**
  String get sec_meta_information;

  /// No description provided for @help_meta_keywords_profile.
  ///
  /// In en, this message translates to:
  /// **'Add your company’s meta keywords.'**
  String get help_meta_keywords_profile;

  /// No description provided for @help_meta_description_profile.
  ///
  /// In en, this message translates to:
  /// **'A short description of your company for search engines.'**
  String get help_meta_description_profile;

  /// No description provided for @lbl_google_analytics.
  ///
  /// In en, this message translates to:
  /// **'Google Analytic ID'**
  String get lbl_google_analytics;

  /// No description provided for @help_google_analytics.
  ///
  /// In en, this message translates to:
  /// **'Your Google Analytics tracking ID'**
  String get help_google_analytics;

  /// No description provided for @lbl_profile_target.
  ///
  /// In en, this message translates to:
  /// **'Profile Page Target Url Path'**
  String get lbl_profile_target;

  /// No description provided for @help_profile_target.
  ///
  /// In en, this message translates to:
  /// **'This is the final URL of your profile page.'**
  String get help_profile_target;

  /// No description provided for @lbl_profile_request.
  ///
  /// In en, this message translates to:
  /// **'Profile Page Request Url Path'**
  String get lbl_profile_request;

  /// No description provided for @help_profile_request.
  ///
  /// In en, this message translates to:
  /// **'Customize the URL of your profile page.'**
  String get help_profile_request;

  /// No description provided for @lbl_collection_target.
  ///
  /// In en, this message translates to:
  /// **'Collection Page Target Url Path'**
  String get lbl_collection_target;

  /// No description provided for @help_collection_target.
  ///
  /// In en, this message translates to:
  /// **'The final URL for your product collection page.'**
  String get help_collection_target;

  /// No description provided for @lbl_collection_request.
  ///
  /// In en, this message translates to:
  /// **'Collection Page Request Url Path'**
  String get lbl_collection_request;

  /// No description provided for @help_collection_request.
  ///
  /// In en, this message translates to:
  /// **'Customize the URL of your collection page.'**
  String get help_collection_request;

  /// No description provided for @lbl_review_target.
  ///
  /// In en, this message translates to:
  /// **'Review Page Target Url Path'**
  String get lbl_review_target;

  /// No description provided for @help_review_target.
  ///
  /// In en, this message translates to:
  /// **'The final URL for your reviews page.'**
  String get help_review_target;

  /// No description provided for @lbl_review_request.
  ///
  /// In en, this message translates to:
  /// **'Review Page Request Url Path'**
  String get lbl_review_request;

  /// No description provided for @help_review_request.
  ///
  /// In en, this message translates to:
  /// **'Customize the URL for your reviews page.'**
  String get help_review_request;

  /// No description provided for @lbl_location_target.
  ///
  /// In en, this message translates to:
  /// **'Location Page Target Url Path'**
  String get lbl_location_target;

  /// No description provided for @help_location_target.
  ///
  /// In en, this message translates to:
  /// **'The final URL for your location page.'**
  String get help_location_target;

  /// No description provided for @lbl_location_request.
  ///
  /// In en, this message translates to:
  /// **'Location Page Request Url Path'**
  String get lbl_location_request;

  /// No description provided for @help_location_request.
  ///
  /// In en, this message translates to:
  /// **'Customize the URL for your location page.'**
  String get help_location_request;

  /// No description provided for @lbl_privacy_request.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy Page Request Url Path'**
  String get lbl_privacy_request;

  /// No description provided for @help_privacy_request.
  ///
  /// In en, this message translates to:
  /// **'Customize the URL for your privacy policy page.'**
  String get help_privacy_request;

  /// No description provided for @btn_view_profile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get btn_view_profile;

  /// No description provided for @btn_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btn_save;

  /// No description provided for @btn_replace_logo.
  ///
  /// In en, this message translates to:
  /// **'Replace Logo'**
  String get btn_replace_logo;

  /// No description provided for @lbl_image_selected.
  ///
  /// In en, this message translates to:
  /// **'Image selected'**
  String get lbl_image_selected;

  /// No description provided for @toast_profile_saved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get toast_profile_saved;

  /// No description provided for @country_tunisia.
  ///
  /// In en, this message translates to:
  /// **'Tunisia'**
  String get country_tunisia;

  /// No description provided for @country_us.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get country_us;

  /// No description provided for @country_canada.
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get country_canada;

  /// No description provided for @country_uk.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get country_uk;

  /// No description provided for @country_germany.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get country_germany;

  /// No description provided for @country_france.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get country_france;

  /// No description provided for @country_japan.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get country_japan;

  /// No description provided for @country_australia.
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get country_australia;

  /// No description provided for @country_brazil.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get country_brazil;

  /// No description provided for @country_india.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get country_india;

  /// No description provided for @country_china.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get country_china;

  /// No description provided for @sec_about_us.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get sec_about_us;

  /// No description provided for @sec_our_products.
  ///
  /// In en, this message translates to:
  /// **'Our Products'**
  String get sec_our_products;

  /// No description provided for @btn_edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get btn_edit_profile;

  /// No description provided for @social_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Open {network}'**
  String social_tooltip(String network);

  /// No description provided for @cat_accessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get cat_accessories;

  /// No description provided for @earning.
  ///
  /// In en, this message translates to:
  /// **'Earning'**
  String get earning;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @totalValueOfSales.
  ///
  /// In en, this message translates to:
  /// **'Total value of sales'**
  String get totalValueOfSales;

  /// No description provided for @productViews.
  ///
  /// In en, this message translates to:
  /// **'Product views'**
  String get productViews;

  /// No description provided for @lifetimeValue.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Value'**
  String get lifetimeValue;

  /// No description provided for @customerCost.
  ///
  /// In en, this message translates to:
  /// **'Customer Cost'**
  String get customerCost;

  /// No description provided for @earningHistory.
  ///
  /// In en, this message translates to:
  /// **'Earning history'**
  String get earningHistory;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @totalEarning.
  ///
  /// In en, this message translates to:
  /// **'Total Earning'**
  String get totalEarning;

  /// No description provided for @discountAmount.
  ///
  /// In en, this message translates to:
  /// **'Discount Amount'**
  String get discountAmount;

  /// No description provided for @adminCommission.
  ///
  /// In en, this message translates to:
  /// **'Admin Commission'**
  String get adminCommission;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @positiveChangeThisWeek.
  ///
  /// In en, this message translates to:
  /// **'+{change_percentage}% this week'**
  String positiveChangeThisWeek(Object change_percentage);

  /// No description provided for @negativeChangeThisWeek.
  ///
  /// In en, this message translates to:
  /// **'-{change_percentage}% this week'**
  String negativeChangeThisWeek(Object change_percentage);

  /// No description provided for @exportedTo.
  ///
  /// In en, this message translates to:
  /// **'Exported to'**
  String get exportedTo;

  /// No description provided for @failedToExport.
  ///
  /// In en, this message translates to:
  /// **'Failed to export:'**
  String get failedToExport;

  /// No description provided for @chartNotReady.
  ///
  /// In en, this message translates to:
  /// **'Oops, chart not ready yet.'**
  String get chartNotReady;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @searchReviews.
  ///
  /// In en, this message translates to:
  /// **'Search reviews'**
  String get searchReviews;

  /// No description provided for @allReviews.
  ///
  /// In en, this message translates to:
  /// **'All Reviews'**
  String get allReviews;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @noReviewsFound.
  ///
  /// In en, this message translates to:
  /// **'No reviews match your search.'**
  String get noReviewsFound;

  /// No description provided for @feedSummary.
  ///
  /// In en, this message translates to:
  /// **'Feed Summary'**
  String get feedSummary;

  /// No description provided for @feedReview.
  ///
  /// In en, this message translates to:
  /// **'Feed Review'**
  String get feedReview;

  /// No description provided for @reviewStatus.
  ///
  /// In en, this message translates to:
  /// **'{status, select, approved{Approved} pending{Pending} rejected{Rejected} other{Unknown}}'**
  String reviewStatus(String status);

  /// No description provided for @downloadStarted.
  ///
  /// In en, this message translates to:
  /// **'Download started...'**
  String get downloadStarted;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get filterByDate;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @filtered.
  ///
  /// In en, this message translates to:
  /// **'Filtered'**
  String filtered(Object start, Object end);

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get currentBalance;

  /// No description provided for @availableForWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Available for withdrawal'**
  String get availableForWithdrawal;

  /// No description provided for @payoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Payout history'**
  String get payoutHistory;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @onProcess.
  ///
  /// In en, this message translates to:
  /// **'On process'**
  String get onProcess;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @transactionIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get transactionIdLabel;

  /// No description provided for @country_uae.
  ///
  /// In en, this message translates to:
  /// **'United Arab Emirates'**
  String get country_uae;

  String get hiThere;

  String get download;

  String get downloadCompleted;

  String get clearFilter;

  String get noTransactionsForDateRange ;

  String get noTransactionsAvailable;

  String get filterEnabledProducts;

  String get filterDisabledProducts;

  String get filterLowStock;

  String get filterOutOfStock;

  String get filterDeniedProduct;

  String get filterAll;

  String get confirmLogout;

  String get logoutSuccessful;

  String get logoutFailed;




}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
          'an issue with the localizations generation tool. Please file an issue '
          'on GitHub with a reproducible sample app and the gen-l10n configuration '
          'that was used.'
  );
}