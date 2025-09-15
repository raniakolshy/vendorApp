import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';


abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();


  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  String get hello;

  String get welcome;

  String get logout;

  String get settings;

  String get language;

  String get oneStopShopDescription;

  String get login;

  String get create;

  String get back;

  String get usernameOrEmail;

  String get password;

  String get forgotPwd;

  String get continueWith;

  String get createAnAccount;

  String get signUp;

  String get createAccount;

  String get anAccount;

  String get welcomeBack;

  String get firstName;

  String get lastName;

  String get createSimple;

  String get createAnAccountLogin;

  String get email;

  String get phone;

  String get passworConfirmation;

  String get becomeASeller;

  String get yes;

  String get no;

  String get byClickingThe;

  String get publicOffer;

  String get newsletter;

  String get enableremoteshoppinghelp;

  String get alreadyHaveAnAccount;

  String get enterEmail;

  String get resetPwd;

  String get submit;

  String get verificationCode;

  String get sentTheVerificationCode;

  String get noCode;

  String get resend;

  String get general;

  String get editProfile;

  String get notification;

  String get favourites;

  String get myOrders;

  String get performances;

  String get legalAndPolicies;

  String get helpSupport;

  String get trailLanguage;

  String get personalInfo;

  String get paymentMethod;

  String get shippingAddress;

  String get streetAddress;

  String get lbl_company_banner;

  String get city;

  String get zipPostalCode;

  String get required;

  String get invalidCode;

  String get country;

  String get card;

  String get payPal;

  String get applePay;

  String get cardholderName;

  String get cardNumber;

  String get expiry;

  String get next;

  String get save;

  String get passwordChangedSuccessfully;

  String get changePassword;

  String get oldPassword;

  String get enteryourcurrentpassword;

  String get reenternewpassword;

  String get confirmPassword;

  String get changeNow;

  String get newPassword;

  String get enternewpassword;

  String get purchaseCompleted;

  String get orderPacked;

  String get minago;

  String get today;

  String get yesterday;

  String get discountApplied;

  String get newFeatureUpdate;

  String get searchFavorites;

  String get productDescription;

  String get currentPrice;

  String get originalPrice;

  String get discount;

  String get product0Name;

  String get product1Name;

  String get product2Name;

  String get product3Name;

  String get product4Name;

  String get product5Name;

  String get search;

  String get english;

  String get arabic;

  String get privacyPolicy;

  String get humanFriendly;

  String get legalMumboJumbo;

  String get privacyDescription;

  String get lastUpdated;

  String get helpAndSupport;

  String get searchTopics;

  String get helpTopic0;

  String get helpTopic1;

  String get helpTopic2;

  String get helpTopic3;

  String get helpTopic4;

  String get helpTopicContent;

  String get messages;

  String get sendHint;

  String get presetFasterDelivery;

  String get presetProductIssue;

  String get presetOther;

  String get thankYouTitle;

  String get thankYouSubtitle;

  String get thankYouDescription;

  String get orderDetails;

  String get done;

  String get orderSummary;

  String get orderNumber;

  String get orderDate;

  String get orderStatus;

  String get statusConfirmed;

  String get customerInfo;

  String get items;

  String get sneakers;

  String get orderTotal;

  String get subtotal;

  String get shipping;

  String get free;

  String get total;

  String get checkoutTitle;

  String get editDetails;

  String get placeOrder;

  String get myCart;

  String get cartEmpty;

  String get addCoupon;

  String get couponApplied;

  String get invalidCoupon;

  String get earnPointsFreeShipping;

  String get proceedToCheckout;

  String get productTitle;

  String get productBrand;

  String get description;

  String get descriptionContent;

  String get ingredients;

  String get ingredientsContent;

  String get howToUse;

  String get howToUseContent;

  String get inStock;

  String get freeDelivery;

  String get availableInStore;

  String get customerReviews;

  String get recommendedProducts;

  String get addToCart;

  String get all;

  String get electronics;

  String get computerSoftware;

  String get fashion;

  String get homeKitchen;

  String get healthBeauty;

  String get groceriesFood;

  String get childrenToys;

  String get carsAccessories;

  String get books;

  String get sportsFitness;

  String hiUser(Object user);

  String get promo;

  String get exploreProducts;

  String get fastDelivery;

  String get summerSale;

  String get selectedItems;

  String get newArrivalsBanner;

  String get freshestStyles;

  String get bestSeller;

  String get shopByCategory;

  String get newArrivals;

  String get productName;

  String get discountBanner;

  String get shopNowText;

  String get shopNow;

  String get home;

  String get cart;

  String get chat;

  String get howtocontactus;

  String get setting;

  String get buyNow;

  String get humanFriendlyPolicyText;

  String get legalMumboJumboPolicyText;

  String get adminNews;

  String get recentUpdates;

  String get refreshNews;

  String get noNews;

  String get newsRefreshed;

  String get newsDeleted;

  String get undo;

  String get issueFixed;

  String get issueFixedContent;

  String get newFeature;

  String get newFeatureContent;

  String get serverMaintenance;

  String get serverMaintenanceContent;

  String get deliveryIssues;

  String get deliveryIssuesContent;

  String get paymentUpdate;

  String get paymentUpdateContent;

  String get securityAlert;

  String get securityAlertContent;

  String get refreshed1;

  String get refreshed1Content;

  String get deliveryImproved;

  String get deliveryImprovedContent;

  String get paymentGatewayUpdated;

  String get paymentGatewayUpdatedContent;

  String get bugFixes;

  String get bugFixesContent;

  String get time2mAgo;

  String get time10mAgo;

  String get time1hAgo;

  String get time3hAgo;

  String get time5hAgo;

  String get time1dAgo;

  String get timeJustNow;

  String get askQuestionTitle;

  String get subject;

  String get subjectTooltip;

  String get inputHint;

  String get yourQuery;

  String get enterSubject;

  String get enterQuery;

  String get requestSent;

  String get send;

  String get askQuestion;

  String get errorSubject;

  String get errorQuery;

  String get successMessage;

  String get customerAnalytics;

  String get customers;

  String get allTime;

  String get last7days;

  String get last30days;

  String get lastYear;

  String get searchCustomer;

  String get loadMore;

  String get noCustomers;

  String get name;

  String get contact;

  String get address;

  String get appTitle;

  String helloUser(Object name);

  String get letsCheckYourStore;

  String get rangeAllTime;

  String get rangeLast30Days;

  String get rangeLast7Days;

  String get rangeThisYear;

  String get statRevenue;

  String get statOrder;

  String get statCustomer;

  String currencyAmount(Object currency, Object amount);

  String deltaSinceLastWeek(String delta);

  String get totalSalesTitle;

  String kpiTotalSales(String pct);

  String legendYearRange(String year);

  String get totalCustomers;

  String get averageOrderValue;

  String get aovLegend;

  String get topSellingProducts;

  String get topCategories;

  String get ratings;

  String get latestCommentsAndReviews;

  String get noProductFound;

  String get noCategoryFound;

  String priceWithCurrency(String currency, double price);

  String soldCount(Object count);

  String get helpful;

  String get oldCustomer;

  String get newCustomer;

  String get returningCustomer;

  String get welcomePrefix;

  String welcomeCount(String count);

  String get welcomeSuffix;

  String get monthsShort;

  String get weekShort;

  String get days30Anchor;

  String get yearsAllTime;

  String kpiAov(String pct);

  String get priceRating;

  String get valueRating;

  String get qualityRating;

  String get checkStore;

  String get last30Days;

  String get last7Days;

  String get thisYear;

  String get latestReviews;

  String get checkBoxMsg;

  String get invalidEmail;

  String get mailSent;

  String get menu;

  String get bell;

  String get notifications;

  String get inputYourText;

  String get bold;

  String get italic;

  String get underline;

  String get bulletedList;

  String get numberedList;

  String get dashboard;

  String get orders;

  String get product;

  String get addProduct;

  String get myProductList;

  String get draftProduct;

  String get transactions;

  String get revenue;

  String get review;

  String get installMainApp;

  String get profileSettings;

  String get printPdf;

  String get askSupport;

  String get productAdd;

  String get productList;

  String get productDrafts;

  String get analytics;

  String get payouts;

  String get customerDashboard;

  String get askAdmin;

  String get installMainApplication;

  String get askForSupport;

  String get printPDF;

  String get askforsupport;

  String get installmainapplication;

  String get letsCheckStore;

  String get lastWeek;

  String get totalSales;

  String percentTotalSales(Object percent);

  String get millionsSuffix;

  String legendRangeYear(Object year);

  String get catHeadphones;

  String get catWatches;

  String get catCameras;

  String get catAccessories;

  String itemsCount(Object count);

  String get latestCommentsReviews;

  String customersCount(Object count);

  String get withPersonalMessage;

  String percentAov(Object percent);

  String get weekMon;

  String get weekTue;

  String get weekWed;

  String get weekThu;

  String get weekFri;

  String get weekSat;

  String get weekSun;

  String get monthJan;

  String get monthFeb;

  String get monthMar;

  String get monthApr;

  String get monthMay;

  String get monthJun;

  String get monthJul;

  String get monthAug;

  String get monthSep;

  String get monthOct;

  String get monthNov;

  String get monthDec;

  String get r1;

  String get r2;

  String get ordersDetails;

  String get searchProduct;

  String get allOrders;

  String get delivered;

  String get processing;

  String get cancelled;

  String get noOrders;

  String get status;

  String get orderId;

  String get purchasedOn;

  String get baseTotal;

  String get purchasedTotal;

  String get customer;

  String get onHold;

  String get closed;

  String get pending;

  String get printPdfTitle;

  String get invoiceDetailsTitle;

  String get invoiceDetailsSubtitle;

  String get invoiceDetailsHint;

  String get saveInfoButton;

  String get saveInfoEmpty;

  String get saveInfoSuccess;

  String get invoiceDetailsFooter;

  String get nameAndDescriptionTitle;

  String get productTitleLabel;

  String get productTitleHelp;

  String get requiredField;

  String get categoryLabel;

  String get categoryHelp;

  String get categoryFood;

  String get categoryElectronics;

  String get categoryApparel;

  String get categoryBeauty;

  String get categoryHome;

  String get categoryOther;

  String get tagsLabel;

  String get tagsHelp;

  String get descriptionLabel;

  String get descriptionHelp;

  String get shortDescriptionLabel;

  String get shortDescriptionHelp;

  String get skuLabel;

  String get skuHelp;

  String get priceTitle;

  String get amountLabel;

  String get amountHelp;

  String get validNumber;

  String get specialPriceLabel;

  String get specialPriceHelp;

  String get specialPriceError;

  String get specialPriceLabel2;

  String get specialPriceHelp2;

  String get priceExample;

  String get minAmountLabel;

  String get minAmountHelp;

  String get maxAmountLabel;

  String get maxAmountHelp;

  String get taxesLabel;

  String get taxesHelp;

  String get stockAndAvailabilityTitle;

  String get stockLabel;

  String get stockHelp;

  String get stockExample;

  String get weightLabel;

  String get weightHelp;

  String get weightExample;

  String get allowedQuantityLabel;

  String get allowedQuantityHelp;

  String get allowedQuantityExample;

  String get nonNegativeNumber;

  String get stockAvailabilityLabel;

  String get stockAvailabilityHelp;

  String get stockInStock;

  String get stockOutOfStock;

  String get visibilityLabel;

  String get visibilityHelp;

  String get visibilityInvisible;

  String get visibilityVisible;

  String get metaInfosTitle;

  String get urlKeyLabel;

  String get urlKeyHelp;

  String get urlKeyExample;

  String get metaTitleLabel;

  String get metaTitleHelp;

  String get metaTitleExample;

  String get metaKeywordsLabel;

  String get metaKeywordsHelp;

  String get metaDescriptionLabel;

  String get metaDescriptionHelp;

  String get coverImagesLabel;

  String get coverImagesHelp;

  String get clickOrDropImage;

  String get saveDraftButton;

  String get publishNowButton;

  String get deleteButton;

  String get draftSaved;

  String get productPublished;

  String productDeleted(Object name);

  String get draftsTitle;

  String get searchDraft;

  String get allDrafts;

  String get drafts;

  String get pendingReview;

  String get noDraftsMatchSearch;

  String get deleteDraftQuestion;

  String deleteDraftConfirmation(Object name);

  String get cancelButton;

  String get quantityLabel;

  String get createdLabel;

  String get statusLabel;

  String get actionLabel;

  String get editButton;

  String get editProduct;

  String get productsTitle;

  String get allProducts;

  String get enabledProducts;

  String get disabledProducts;

  String get lowStock;

  String get outOfStock;

  String get deniedProduct;

  String get noProductsMatchSearch;

  String get deleteProduct;

  String deleteProductConfirmation(Object name);

  String get idLabel;

  String get quantityPerSourceLabel;

  String get salableQuantityLabel;

  String get quantitySoldLabel;

  String get quantityConfirmedLabel;

  String get quantityPendingLabel;

  String get priceLabel;

  String get statusActive;

  String get statusDisabled;

  String get statusLowStock;

  String get statusOutOfStock;

  String get statusDenied;

  String get visibilityCatalogSearch;

  String get visibilityCatalogOnly;

  String get visibilitySearchOnly;

  String get visibilityNotVisible;

  String get editProductScreen;

  String get customerAnalyticsTitle;

  String get customersLabel;

  String get incomeLabel;

  String get searchCustomerHint;

  String get loadMoreButton;

  String get noCustomersMatch;

  String get contactLabel;

  String get genderLabel;

  String get addressLabel;

  String get baseTotalLabel;

  String get ordersLabel;

  String get maleLabel;

  String get femaleLabel;

  String get inputYourTextHint;

  String get addTagHint;

  String get skuHint;

  String get enterValidNumber;

  String get specialPriceHint;

  String get stockAvailabilityTitle;

  String get stockHint;

  String get weightHint;

  String get maxQuantityHint;

  String get enterNonNegativeNumber;

  String get invisible;

  String get visible;

  String get metaInfoTitle;

  String get urlKeyHint;

  String get metaTitleHint;

  String get productImagesLabel;

  String get productImagesHelp;

  String get threeImagesWarning;

  String get deleteTooltip;

  String get sec_name_description;

  String get lbl_product_title;

  String get help_product_title;

  String get hint_input_text;

  String get v_required;

  String get lbl_category;

  String get help_category;

  String get lbl_tags;

  String get help_tags;

  String get hint_add_tag;

  String get lbl_description;

  String get help_description;

  String get lbl_short_description;

  String get help_short_description;

  String get lbl_sku;

  String get help_sku;

  String get hint_sku;

  String get sec_price;

  String get lbl_amount;

  String get help_amount;

  String get hint_amount_default;

  String get v_number;

  String get lbl_special_toggle;

  String get help_special_toggle;

  String get lbl_special_price;

  String get help_special_price;

  String get hint_price_example;

  String get lbl_min_qty;

  String get help_min_qty;

  String get lbl_max_qty;

  String get help_max_qty;

  String get lbl_taxes;

  String get help_taxes;

  String get sec_stock_availability;

  String get lbl_stock;

  String get help_stock;

  String get hint_stock;

  String get lbl_weight;

  String get help_weight;

  String get hint_weight;

  String get lbl_allowed_qty_per_customer;

  String get help_allowed_qty_per_customer;

  String get hint_allowed_qty;

  String get v_non_negative;

  String get lbl_stock_availability;

  String get help_stock_availability;

  String get lbl_visibility;

  String get help_visibility;

  String get sec_meta_infos;

  String get lbl_url_key;

  String get help_url_key;

  String get hint_url_key;

  String get lbl_meta_title;

  String get help_meta_title;

  String get hint_meta_title;

  String get lbl_meta_keywords;

  String get help_meta_keywords;

  String get lbl_meta_description;

  String get help_meta_description;

  String get lbl_product_images;

  String get help_product_images;

  String get btn_click_or_drop_image;

  String get warn_prefer_three_images;

  String get sec_linked_products;

  String get title_product_relationships;

  String get tab_related;

  String get tab_upsell;

  String get tab_crosssell;

  String get related_products;

  String get upsell_products;

  String get crosssell_products;

  String get filters;

  String get btn_reset;

  String get btn_apply;

  String get status_enabled;

  String get status_disabled;

  String get btn_filters;

  String get btn_filters_on;

  String get filters_showing_enabled_only;

  String get filters_showing_disabled_only;

  String get filters_custom;

  String get empty_no_linked_products;

  String get empty_no_linked_products_desc;

  String get btn_add_product;

  String get btn_browse_catalog;

  String get btn_save_draft;

  String get btn_publish_now;

  String get btn_edit;

  String get btn_delete;

  String get tt_delete;

  String get lbl_price;

  String id_with_value(String value);

  String inventory_with_value(String value);

  String price_with_currency(String value);

  String get err_add_three_images;

  String get err_special_lower_than_amount;

  String get toast_draft_saved;

  String get toast_product_published;

  String get toast_product_deleted;

  String get curr_symbol;

  String get cat_food;

  String get cat_electronics;

  String get cat_apparel;

  String get cat_beauty;

  String get cat_home;

  String get cat_home_appliances;

  String get cat_other;

  String get stock_in;

  String get stock_out;

  String get visibility_invisible;

  String get visibility_visible;

  String get hint_search_name_sku;

  String get inv_in_stock_label;

  String get inv_low_stock_label;

  String get inv_out_stock_label;

  String get demo_mouse_name;

  String get demo_tshirt_name;

  String get demo_espresso_name;

  String get profile_settings;

  String get sec_profile_information;

  String get lbl_company_logo;

  String get help_company_logo;

  String get help_company_banner;

  String get lbl_display_name;

  String get help_display_name;

  String get hint_company;

  String get lbl_location;

  String get help_location;

  String get lbl_phone_number;

  String get help_phone_number;

  String get hint_phone;

  String get lbl_bio;

  String get help_bio;

  String get lbl_low_stock_qty;

  String get help_low_stock_qty;

  String get lbl_tax_vat;

  String get help_tax_vat;

  String get lbl_payment_details;

  String get help_payment_details;

  String get lbl_social_ids;

  String get help_social_ids;

  String get sm_twitter;

  String get sm_facebook;

  String get sm_instagram;

  String get sm_youtube;

  String get sm_vimeo;

  String get sm_pinterest;

  String get sm_moleskine;

  String get sm_tiktok;

  String get sec_company_policy;

  String get lbl_return_policy;

  String get help_return_policy;

  String get lbl_shipping_policy;

  String get help_shipping_policy;

  String get lbl_privacy_policy;

  String get help_privacy_policy;

  String get sec_meta_information;

  String get help_meta_keywords_profile;

  String get help_meta_description_profile;

  String get lbl_google_analytics;

  String get help_google_analytics;

  String get lbl_profile_target;

  String get help_profile_target;

  String get lbl_profile_request;

  String get help_profile_request;

  String get lbl_collection_target;

  String get help_collection_target;

  String get lbl_collection_request;

  String get help_collection_request;

  String get lbl_review_target;

  String get help_review_target;

  String get lbl_review_request;

  String get help_review_request;

  String get lbl_location_target;

  String get help_location_target;

  String get lbl_location_request;

  String get help_location_request;

  String get lbl_privacy_request;

  String get help_privacy_request;

  String get btn_view_profile;

  String get btn_save;

  String get btn_replace_logo;

  String get lbl_image_selected;

  String get toast_profile_saved;

  String get country_tunisia;

  String get country_us;

  String get country_canada;

  String get country_uk;

  String get country_germany;

  String get country_france;

  String get country_japan;

  String get country_australia;

  String get country_brazil;

  String get country_india;

  String get country_china;

  String get sec_about_us;

  String get sec_our_products;

  String get btn_edit_profile;

  String social_tooltip(String network);

  String get cat_accessories;

  String get earning;

  String get balance;

  String get totalValueOfSales;

  String get productViews;

  String get lifetimeValue;

  String get customerCost;

  String get earningHistory;

  String get interval;

  String get totalAmount;

  String get totalEarning;

  String get discountAmount;

  String get adminCommission;

  String get loading;

  String positiveChangeThisWeek(Object change_percentage);

  String negativeChangeThisWeek(Object change_percentage);

  String get exportedTo;

  String get failedToExport;

  String get chartNotReady;

  String get reviews;

  String get searchReviews;

  String get allReviews;

  String get approved;

  String get rejected;

  String get noReviewsFound;

  String get feedSummary;

  String get feedReview;

  String reviewStatus(String status);

  String get downloadStarted;

  String get filterByDate;

  String get cancel;

  String get apply;

  String filtered(Object start, Object end);

  String get currentBalance;

  String get availableForWithdrawal;

  String get payoutHistory;

  String get id;

  String get transactionId;

  String get earnings;

  String get paid;

  String get onProcess;

  String get failed;

  String get transactionIdLabel;

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

  String get noDraftsAvailable;

  String get noReviewsAvailable ;




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