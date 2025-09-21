

class VendorProfileModel {
  final int? customerId;
  final String? companyName;
  final String? bio;
  final String? country;
  final String? phone;
  final String? vatNumber;
  final String? paymentDetails;
  final String? lowStockQty;
  final String? twitter;
  final String? facebook;
  final String? instagram;
  final String? youtube;
  final String? vimeo;
  final String? pinterest;
  final String? moleskine;
  final String? tiktok;
  final String? returnPolicy;
  final String? shippingPolicy;
  final String? privacyPolicy;
  final String? metaKeywords;
  final String? metaDescription;
  final String? googleAnalyticsId;
  final String? profilePathReq;
  final String? collectionPathReq;
  final String? reviewPathReq;
  final String? locationPathReq;
  final String? privacyPath;
  final String? logoUrl;
  final String? bannerUrl;
  final String? logoBase64;
  final String? bannerBase64;
  final String? firstname;
  final String? lastname;
  final String? email;

  VendorProfileModel({
    this.customerId,
    this.companyName,
    this.bio,
    this.country,
    this.phone,
    this.vatNumber,
    this.paymentDetails,
    this.lowStockQty,
    this.twitter,
    this.facebook,
    this.instagram,
    this.youtube,
    this.vimeo,
    this.pinterest,
    this.moleskine,
    this.tiktok,
    this.returnPolicy,
    this.shippingPolicy,
    this.privacyPolicy,
    this.metaKeywords,
    this.metaDescription,
    this.googleAnalyticsId,
    this.profilePathReq,
    this.collectionPathReq,
    this.reviewPathReq,
    this.locationPathReq,
    this.privacyPath,
    this.logoUrl,
    this.bannerUrl,
    this.logoBase64,
    this.bannerBase64,
    this.firstname,
    this.lastname,
    this.email,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    final extensionAttributes = json['extension_attributes'] as Map<String, dynamic>?;

    return VendorProfileModel(

      customerId: (json['id'] as num?)?.toInt(),
      companyName: extensionAttributes?['company_name'],
      bio: extensionAttributes?['bio'],
      country: extensionAttributes?['country'],
      phone: extensionAttributes?['phone'],
      vatNumber: extensionAttributes?['vat_number'],
      paymentDetails: extensionAttributes?['payment_details'],
      lowStockQty: extensionAttributes?['low_stock_qty'],
      twitter: extensionAttributes?['twitter'],
      facebook: extensionAttributes?['facebook'],
      instagram: extensionAttributes?['instagram'],
      youtube: extensionAttributes?['youtube'],
      vimeo: extensionAttributes?['vimeo'],
      pinterest: extensionAttributes?['pinterest'],
      moleskine: extensionAttributes?['moleskine'],
      tiktok: extensionAttributes?['tiktok'],
      returnPolicy: extensionAttributes?['return_policy'],
      shippingPolicy: extensionAttributes?['shipping_policy'],
      privacyPolicy: extensionAttributes?['privacy_policy'],
      metaKeywords: extensionAttributes?['meta_keywords'],
      metaDescription: extensionAttributes?['meta_description'],
      googleAnalyticsId: extensionAttributes?['google_analytics_id'],
      profilePathReq: extensionAttributes?['profile_path_req'],
      collectionPathReq: extensionAttributes?['collection_path_req'],
      reviewPathReq: extensionAttributes?['review_path_req'],
      locationPathReq: extensionAttributes?['location_path_req'],
      privacyPath: extensionAttributes?['privacy_path'],
      logoUrl: extensionAttributes?['logo_url'],
      bannerUrl: extensionAttributes?['banner_url'],
      logoBase64: extensionAttributes?['logo_base64'],
      bannerBase64: extensionAttributes?['banner_base64'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
    );
  }
}