import "src/messages.g.dart" as inner;

// Export the enums so they can be used by consumers. 
// All inner data are exposed to enable injection of test data.
export "src/messages.g.dart"
    show
        StoreProductKind,
        StoreSubscriptionBillingPeriodUnit,
        AssociatedStoreProductsInner,
        StoreAppLicenseInner,
        AddOnLicenseInner,
        StorePriceInner,
        StoreSubscriptionInfoInner,
        StoreProductInner,
        StoreProductSkuInner;
import "src/messages.g.dart" show StoreProductKind, StoreSubscriptionBillingPeriodUnit, StoreAppLicenseInner, AssociatedStoreProductsInner;

/// Represents a valid license for a durable add-on.
class AddOnLicense {
  /// The product ID for the add-on.
  final String inAppOfferToken;

  /// The Store ID of the licensed add-on SKU from the Microsoft Store catalog.
  final String skuStoreId;

  /// The expiration date and time for the add-on license. (ISO 8601)
  final String expirationDate;

  /// The expiration date and time for the add-on license
  DateTime get expirationDateTime => DateTime.parse(expirationDate);

  /// Checks if the add-on license is a lifetime license.
  bool get isLifetime => expirationDateTime.isAfter(DateTime.now().add(Duration(days: 5 * 365)));

  AddOnLicense._(this.inAppOfferToken, this.skuStoreId, this.expirationDate);

  factory AddOnLicense._fromInner(inner.AddOnLicenseInner data) {
    return AddOnLicense._(
      data.inAppOfferToken,
      data.skuStoreId,
      data.expirationDate,
    );
  }
}

class StoreAppLicense {
  StoreAppLicense._({
    required this.isActive,
    required this.isTrial,
    required this.skuStoreId,
    required this.trialUniqueId,
    required this.trialTimeRemaining,
    required this.expirationDate,
    required this.addOnLicenses,
  });

  /// True if the license is valid and provides the current user an entitlement to use the app;
  /// otherwise, false.
  final bool isActive;

  /// True if the license is a trial license; otherwise, false.
  final bool isTrial;

  /// The Store ID of a the licensed app SKU from the Microsoft Store catalog.
  /// Todo : query API GetStoreProductForCurrentAppAsync to get data about those SKUs.
  final String skuStoreId;

  /// A unique ID that identifies the combination of the current user and the usage-limited
  /// trial that is associated with this app license.
  /// (see trialTimeRemaining)
  final String trialUniqueId;

  /// The remaining time for the usage-limited trial that is associated with this app license.
  /// This property is intended to be used by developers who have configured their app as a
  /// usage-limited trial in Partner Center.
  /// Usage-limited trials are currently available only to some developer accounts in Xbox managed partner programs.
  /// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storeapplicense.trialtimeremaining?view=winrt-26100
  final Duration trialTimeRemaining;

  /// Expiration date and time for the app license (ISO 8601)
  final String expirationDate;

  /// Valid license info for durables add-on that is associated with the current app.
  /// Each entry in this dictionary:
  /// - Has a key: the Store ID of the add-on (usually the product ID).
  /// - Has a value: a StoreLicense object with details like:
  ///     - SkuStoreId: the full ID of the purchased SKU (e.g., 9NBLGGH69M0B/000N)
  ///     - IsActive: whether the license is currently valid
  ///     - ExpirationDate: when the subscription ends
  ///     - IsTrial: whether the user is in the trial period
  final List<AddOnLicense> addOnLicenses;

  /// Expiration date and time for the app license
  DateTime get expirationDateTime => DateTime.parse(expirationDate);

  /// Checks if the add-on license is a lifetime license.
  bool get isLifetime => expirationDateTime.isAfter(DateTime.now().add(Duration(days: 5 * 365)));

  factory StoreAppLicense._fromInner(inner.StoreAppLicenseInner data) {
    return StoreAppLicense._(
      isActive: data.isActive,
      isTrial: data.isTrial,
      skuStoreId: data.skuStoreId,
      trialUniqueId: data.trialUniqueId,
      trialTimeRemaining: Duration(seconds: data.trialTimeRemaining),
      expirationDate: data.expirationDate,
      addOnLicenses: data.addOnLicenses.map(AddOnLicense._fromInner).toList(),
    );
  }
}

/// Contains pricing info for a product listing in the Microsoft Store.
/// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storeprice?view=winrt-26100
class StorePrice {
  StorePrice._({
    required this.currencyCode,
    required this.isOnSale,
    required this.saleEndDate,
    required this.formattedBasePrice,
    required this.formattedPrice,
    required this.formattedRecurrencePrice,
  });

  /// ISO 4217 currency code for the market of the current user.
  final String currencyCode;

  /// Indicates whether the product is on sale.
  final bool isOnSale;

  /// End date for the sale period for the product, if the product is on sale. (ISO 8601)
  final String saleEndDate;

  /// Base price for the product with the appropriate formatting for the market of the current user.
  final String formattedBasePrice;

  /// Purchase price for the product with the appropriate formatting for the market of the current user.
  final String formattedPrice;

  /// Recurring price for the product with the appropriate formatting for the market of the current user, if recurring billing is enabled for this product.
  final String formattedRecurrencePrice;

  /// The expiration date and time for the add-on license
  DateTime get saleEndDateTime => DateTime.parse(saleEndDate);

  factory StorePrice._fromInner(inner.StorePriceInner data) {
    return StorePrice._(
      currencyCode: data.currencyCode,
      isOnSale: data.isOnSale,
      saleEndDate: data.saleEndDate,
      formattedBasePrice: data.formattedBasePrice,
      formattedPrice: data.formattedPrice,
      formattedRecurrencePrice: data.formattedRecurrencePrice,
    );
  }
}

/// Represents the kind of product add-on available in the Microsoft Store.
extension StoreProductKindExtension on StoreProductKind {
  String get name {
    switch (this) {
      case StoreProductKind.application:
        return 'Application';
      case StoreProductKind.game:
        return 'Game';
      case StoreProductKind.unmanagedConsumable:
        return 'Unmanaged Consumable';
      case StoreProductKind.durable:
        return 'Durable';
      case StoreProductKind.consumable:
        return 'Consumable';
    }
  }
}

/// Defines values that represent the units of a trial period or billing period for a subscription
extension StoreSubscriptionBillingPeriodUnitExtension on StoreSubscriptionBillingPeriodUnit {
  String get name {
    switch (this) {
      case StoreSubscriptionBillingPeriodUnit.minute:
        return 'Minute(s)';
      case StoreSubscriptionBillingPeriodUnit.hour:
        return 'Hour(s)';
      case StoreSubscriptionBillingPeriodUnit.day:
        return 'Day(s)';
      case StoreSubscriptionBillingPeriodUnit.week:
        return 'Week(s)';
      case StoreSubscriptionBillingPeriodUnit.month:
        return 'Month(s)';
      case StoreSubscriptionBillingPeriodUnit.year:
        return 'Year(s)';
    }
  }
}

/// Provides subscription info for a product SKU that represents a subscription with recurring billing.
/// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storesubscriptioninfo?view=winrt-26100
class StoreSubscriptionInfo {
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

  /// Subscription period, specified in ISO 8601 format. For example,
  /// P1W equates to one week, P1M equates to one month,
  /// P3M equates to three months, P6M equates to six months,
  /// and P1Y equates to one year.
  String get billingPeriodISO => 'P${billingPeriod}${billingPeriodUnit.name[0]}';

  /// Trial period, specified in ISO 8601 format.
  String get trialPeriodISO => 'P${trialPeriod}${trialPeriodUnit.name[0]}';

  const StoreSubscriptionInfo._(
    this.billingPeriod,
    this.billingPeriodUnit,
    this.hasTrialPeriod,
    this.trialPeriod,
    this.trialPeriodUnit,
  );

  factory StoreSubscriptionInfo._fromInner(inner.StoreSubscriptionInfoInner data) {
    return StoreSubscriptionInfo._(
      data.billingPeriod,
      data.billingPeriodUnit,
      data.hasTrialPeriod,
      data.trialPeriod,
      data.trialPeriodUnit,
    );
  }
}

/// Provides info for a stock keeping unit (SKU) of a product in the Microsoft Store
/// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storesku?view=winrt-26100
class StoreProductSku {
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
  final StoreSubscriptionInfo? subscriptionInfo;

  /// Price of the default availability for this product SKU.
  final StorePrice price;

  const StoreProductSku._({
    required this.storeId,
    required this.isTrial,
    required this.isSubscription,
    required this.description,
    required this.title,
    required this.subscriptionInfo,
    required this.price,
  });

  factory StoreProductSku._fromInner(inner.StoreProductSkuInner data) {
    return StoreProductSku._(
      storeId: data.storeId,
      isTrial: data.isTrial,
      isSubscription: data.isSubscription,
      description: data.description,
      title: data.title,
      subscriptionInfo: data.subscriptionInfo != null ? StoreSubscriptionInfo._fromInner(data.subscriptionInfo!) : null,
      price: StorePrice._fromInner(data.price),
    );
  }
}

/// Add-on associated to the application in the Microsoft Store
/// https://learn.microsoft.com/en-us/uwp/api/windows.services.store.storeproduct?view=winrt-26100
class StoreProduct {
  StoreProduct._({
    required this.storeId,
    required this.description,
    required this.title,
    required this.inAppOfferToken,
    required this.productKind,
    required this.price,
    required this.skus,
  });

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
  final StorePrice price;

  /// List of available SKUs for the product.
  final List<StoreProductSku> skus;

  factory StoreProduct._fromInner(inner.StoreProductInner data) {
    return StoreProduct._(
      storeId: data.storeId,
      description: data.description,
      title: data.title,
      inAppOfferToken: data.inAppOfferToken,
      productKind: data.productKind,
      price: StorePrice._fromInner(data.price),
      skus: data.skus.map(StoreProductSku._fromInner).toList(),
    );
  }
}

/// Represents a collection of add-ons associated with the application in the Microsoft Store.
class AssociatedStoreProducts {
  AssociatedStoreProducts._({
    required this.products,
  });

  final List<StoreProduct> products;

  factory AssociatedStoreProducts._fromInner(inner.AssociatedStoreProductsInner data) {
    return AssociatedStoreProducts._(
      products: data.products.map(StoreProduct._fromInner).toList(),
    );
  }
}

class WindowsStoreApi {
  final _api = inner.WindowsStoreApi();

  /// Get's the license information for from the Microsoft Store. Only works on Windows.
  Future<StoreAppLicense> getAppLicenseAsync() async {
    return StoreAppLicense._fromInner(await _api.getAppLicenseAsync());
  }

  /// Gets Microsoft Store listing info for the products that can be purchased from within the current app.
  /// productKind: The kind of product to retrieve.
  Future<AssociatedStoreProducts> getAssociatedStoreProductsAsync(StoreProductKind productKind) async {
    return AssociatedStoreProducts._fromInner(await _api.getAssociatedStoreProductsAsync(productKind));
  }
}

/// Windows Store API test class.
/// You can inject your data as needed for testing, to reflect your product situation in the Partner Center.
class WindowsStoreApiTest extends WindowsStoreApi {
  inner.StoreAppLicenseInner? _testStoreAppLicense;
  inner.AssociatedStoreProductsInner? _testAssociatedStoreProducts;

  /// Injects test data for the Store App License.
  void injectStoreAppLicense(StoreAppLicenseInner data) {
    _testStoreAppLicense = data;
  }

  /// Injects test data for the associated store products.
  void injectAssociatedStoreProducts(AssociatedStoreProductsInner data) {
    _testAssociatedStoreProducts = data;
  }

  /// Get's the license information for from the Microsoft Store. Only works on Windows.
  @override
  Future<StoreAppLicense> getAppLicenseAsync() async {
    if (_testStoreAppLicense == null) {
      throw Exception("Test data for StoreAppLicense is not injected");
    }
    return StoreAppLicense._fromInner(_testStoreAppLicense!);
  }

  /// Gets Microsoft Store listing info for the products that can be purchased from within the current app.
  /// productKind: The kind of product to retrieve.
  @override
  Future<AssociatedStoreProducts> getAssociatedStoreProductsAsync(StoreProductKind productKind) async {
    if (_testAssociatedStoreProducts == null) {
      throw Exception("Test data for AssociatedStoreProducts is not injected");
    }
    return AssociatedStoreProducts._fromInner(_testAssociatedStoreProducts!);
  }
}
