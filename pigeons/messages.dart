// ignore: depend_on_referenced_packages
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartOptions: DartOptions(),
  cppOptions: CppOptions(namespace: 'windows_store'),
  cppHeaderOut: 'windows/pigeon/messages.g.h',
  cppSourceOut: 'windows/pigeon/messages.g.cpp',
  dartPackageName: 'windows_store',
))

/// Gets valid license info for durables add-on that is associated with the current app
/// Invalid license are not included, licenses for consumable add-ons are not included.
class AddOnLicenseInner {
  /// The product ID for the add-on.
  final String inAppOfferToken;

  /// The Store ID of the licensed add-on SKU from the Microsoft Store catalog.
  final String skuStoreId;

  /// Gets the expiration date and time for the add-on license. (ISO 8601)
  /// For durable lifetime add-ons, StoreLicense.ExpirationDate typically returns a value like 9999-12-31T00:00:00Z.
  /// This is not documented in Microsoft Learn, but has been confirmed through testing and community discussions (e.g., Stack Overflow, GitHub issues, MSDN forums).
  final String expirationDate;

  AddOnLicenseInner(this.inAppOfferToken, this.skuStoreId, this.expirationDate);
}

/// Provides license info for the current app, including licenses for products that are offered by the app.
/// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storeapplicense?view=winrt-26100
class StoreAppLicenseInner {
  /// Indicates whether the license is valid and provides the current user an entitlement to use the app.
  final bool isActive;

  /// Indicates whether the license is a trial license.
  final bool isTrial;

  /// Store ID of the licensed app SKU from the Microsoft Store catalog
  final String skuStoreId;

  /// Unique ID that identifies the combination of the current user and the usage-limited trial that is associated with this app license
  /// (see trialTimeRemaining)
  final String trialUniqueId;

  /// The remaining time for the usage-limited trial that is associated with this app license.
  /// This property is intended to be used by developers who have configured their app as a
  /// usage-limited trial in Partner Center.
  /// Usage-limited trials are currently available only to some developer accounts in Xbox managed partner programs.
  /// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storeapplicense.trialtimeremaining?view=winrt-26100
  final int trialTimeRemaining;

  /// Expiration date and time for the app license (ISO 8601)
  final String expirationDate;

  /// Valid license info for durables add-on that is associated with the current app
  final List<AddOnLicenseInner> addOnLicenses;

  const StoreAppLicenseInner(
    this.isActive,
    this.isTrial,
    this.skuStoreId,
    this.trialUniqueId,
    this.trialTimeRemaining,
    this.addOnLicenses,
    this.expirationDate,
  );
}

/// Represents the kind of product available in the Microsoft Store.
/// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storeproduct.productkind?view=winrt-26100#windows-services-store-storeproduct-productkind
enum StoreProductKind {
  application,
  game,
  consumable,
  unmanagedConsumable,

  /// An add-on that persists for the lifetime that you specify in Partner Center.
  /// By default, durable add-ons never expire, in which case they can only be purchased once.
  /// If you specify a particular duration for the add-on, the user can repurchase the add-on after it expires.
  /// Note: A StoreProduct that represents a subscription add-on has the type Durable.
  durable;
}

/// Contains pricing info for a product listing in the Microsoft Store.
/// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storeprice?view=winrt-26100
class StorePriceInner {
  /// Gets the ISO 4217 currency code for the market of the current user.
  final String currencyCode;

  /// Gets a value that indicates whether the product is on sale.
  final bool isOnSale;

  /// Gets the end date for the sale period for the product, if the product is on sale. (ISO 8601)
  final String saleEndDate;

  /// Gets the base price for the product with the appropriate formatting for the market of the current user.
  final String formattedBasePrice;

  /// Gets the purchase price for the product with the appropriate formatting for the market of the current user.
  final String formattedPrice;

  /// Gets the recurring price for the product with the appropriate formatting for the market of the current user, if recurring billing is enabled for this product.
  final String formattedRecurrencePrice;

  const StorePriceInner(
    this.currencyCode,
    this.isOnSale,
    this.saleEndDate,
    this.formattedBasePrice,
    this.formattedPrice,
    this.formattedRecurrencePrice,
  );
}

/// Defines values that represent the units of a trial period or billing period for a subscription
enum StoreSubscriptionBillingPeriodUnit { minute, hour, day, week, month, year }

/// Provides subscription info for a product SKU that represents a subscription with recurring billing.
/// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storesubscriptioninfo?view=winrt-26100
class StoreSubscriptionInfoInner {
  /// Duration of the billing period for a subscription, in the units specified by the BillingPeriodUnit property.
  final int billingPeriod;

  /// Units of the billing period for a subscription.
  final StoreSubscriptionBillingPeriodUnit billingPeriodUnit;

  /// Value that indicates whether the subscription contains a trial period.
  final bool hasTrialPeriod;

  /// Duration of the trial period for the subscription, in the units specified by the TrialPeriodUnit property. To determine whether the subscription has a trial period, use the HasTrialPeriod property.
  final int trialPeriod;

  /// Units of the trial period for the subscription
  final StoreSubscriptionBillingPeriodUnit trialPeriodUnit;

  const StoreSubscriptionInfoInner(
    this.billingPeriod,
    this.billingPeriodUnit,
    this.hasTrialPeriod,
    this.trialPeriod,
    this.trialPeriodUnit,
  );
}

/// Provides additional data for a product SKU that the user has an entitlement to use.
/// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storecollectiondata?view=winrt-26100
class StoreCollectionDataInner {
  /// Promotion campaign ID that is associated with the product SKU.
  final String campaignId;

  /// Developer offer ID that is associated with the product SKU.
  final String developerOfferId;

  /// Complete collection data for the product SKU in JSON format.
  final String extendedJsonData;

  /// Value that indicates whether the product SKU is a trial version.
  final bool isTrial;

  /// Date on which the product SKU was acquired.
  final String acquiredDate;

  /// Start date of the trial for the product SKU, if the SKU is a trial version or a durable add-on that expires after a set duration.
  final String startDate;

  /// The end date of the trial for the product SKU, if the SKU is a trial version or a durable add-on that expires after a set duration.
  final String endDate;

  /// Remaining trial time for the usage-limited trial that is associated with this product SKU. (in seconds)
  final int trialTimeRemaining;

  const StoreCollectionDataInner(
    this.campaignId,
    this.developerOfferId,
    this.extendedJsonData,
    this.isTrial,
    this.acquiredDate,
    this.startDate,
    this.endDate,
    this.trialTimeRemaining,
  );
}

/// Provides info for a stock keeping unit (SKU) of a product in the Microsoft Store
/// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storesku?view=winrt-26100
class StoreProductSkuInner {
  /// Store ID of this product SKU
  final String storeId;

  /// Indicates whether this product SKU is a trial SKU
  final bool isTrial;

  /// Indicates whether this product SKU is a subscription SKU
  final bool isSubscription;

  /// Product SKU description from the Microsoft Store listing.
  final String description;

  /// Product SKU title from the Microsoft Store listing.
  final String title;

  /// Subscription information for this product SKU, if this product SKU is a subscription with recurring billing.
  /// To determine whether this product SKU is a subscription, use the IsSubscription property.
  final StoreSubscriptionInfoInner? subscriptionInfo;

  /// Price of the default availability for this product SKU.
  final StorePriceInner price;

  /// The custom developer data string (also called a tag) that contains custom information about
  /// the add-on that this product SKU represents.
  /// This string corresponds to the value of the Custom developer data field in the properties page for the add-on in Partner Center.
  final String customDeveloperData;

  /// Complete data for the current product SKU from the Store in JSON format.
  final String extendedJsonData;

  /// Value that indicates whether the current user has an entitlement to use the current product SKU.
  final bool isInUserCollection;

  /// Additional data for the current product SKU, if the user has an entitlement to use the SKU.
  /// Valid only if isInUserCollection is true.
  final StoreCollectionDataInner collectionData;

  const StoreProductSkuInner(
    this.storeId,
    this.isTrial,
    this.isSubscription,
    this.description,
    this.title,
    this.subscriptionInfo,
    this.price,
    this.customDeveloperData,
    this.extendedJsonData,
    this.isInUserCollection,
    this.collectionData,
  );
}

/// Add-on associated to the application in the Microsoft Store
/// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storeproduct?view=winrt-26100
class StoreProductInner {
  /// Gets the Store ID for this product. For an add-on, this property corresponds to the Store ID that is available on the overview page for the add-on.
  final String storeId;

  /// Gets the product description from the Microsoft Store listing.
  final String description;

  /// Gets the product title from the Microsoft Store listing.
  final String title;

  /// Gets the product ID for this product, if the current StoreProduct represents an add-on.
  final String inAppOfferToken;

  /// Gets the type of the product.
  final StoreProductKind productKind;

  /// Gets the price for the default SKU and availability for the product.
  final StorePriceInner price;

  /// List of available SKUs for the product.
  final List<StoreProductSkuInner> skus;

  const StoreProductInner(
    this.storeId,
    this.description,
    this.title,
    this.inAppOfferToken,
    this.productKind,
    this.price,
    this.skus,
  );
}

/// Collection of Microsoft Store products (add-ons) returned by a query to Microsoft Store Partner Center.
/// The content signification will vary depending on the API called.
class StoreProductCollectionInner {
  /// List of Microsoft Store products (add-ons) associated with the application.
  final List<StoreProductInner> products;

  const StoreProductCollectionInner(this.products);
}

/// If you're building a storefront:
/// - Use getAppLicenseAsync to show the user's app license info and add-ons purchased
/// - Use getAssociatedStoreProductsAsync to show what’s available for purchase
/// - Use getUserCollectionAsync to show what the user already owns, even if it’s no longer purchasable
@HostApi()
abstract class WindowsStoreApi {
  @async
  StoreAppLicenseInner getAppLicenseAsync();

  /// Gets Microsoft Store listing info for the products that can be purchased from within the current app.
  /// productKind: The kind of product to retrieve.
  /// collectionData attribute of store product SKU CANNOT be used.
  /// Reflects the current store state with add-ons available.
  /// 
  /// This method returns StoreProduct objects for add-ons that are:
  /// - Currently associated with your app
  /// - Available for sale in the Microsoft Store
  /// - Filtered by product kind (e.g., "Durable", "Subscription")
  ///
  /// Key traits:
  /// - Focuses on catalog visibility
  /// - Only includes active, sellable products
  /// - Does not include user-specific data like ownership or acquisition
  /// 
  /// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storecontext.getassociatedstoreproductsasync?view=winrt-26100
  @async
  StoreProductCollectionInner getAssociatedStoreProductsAsync(StoreProductKind productKind);

  /// Gets Microsoft Store info for the add-ons of the current app for which the user has purchased.
  /// Returns a StoreProductQueryResult object that contains Microsoft Store info for the add-ons of the current app for which the user has purchased and relevant error info.
  /// productKind: The kind of product to retrieve.
  /// collectionData attribute of store product SKU can be used.
  /// 
  /// This method returns StoreProduct objects that the user has acquired, regardless of whether they’re still available for sale.
  ///
  /// Key traits:
  /// - Focuses on user entitlements
  /// - Includes products the user owns, even if they’re no longer listed or sold
  /// - Populates StoreSku.CollectionData with user-specific info (e.g., AcquiredDate, IsTrial, ExtendedJsonData)
  /// - May include outdated, deprecated, or hidden add-ons
  /// 
  /// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storecontext.getusercollectionasync?view=winrt-26100
  @async
  StoreProductCollectionInner getUserCollectionAsync(StoreProductKind productKind);

}
