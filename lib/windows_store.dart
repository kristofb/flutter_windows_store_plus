import "src/messages.g.dart" as inner;

/// Represents a valid license for a durable add-on.
class AddOnLicense {
    /// The product ID for the add-on.
  final String inAppOfferToken;

  /// The Store ID of the licensed add-on SKU from the Microsoft Store catalog.
  final String skuStoreId;

  /// The expiration date and time for the add-on license. (ISO 8601)
  final String expirationDate;

  DateTime get expirationDateTime => DateTime.parse(expirationDate);

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
    required this.addOnLicenses,
  });

  /// True if the license is valid and provides the current user an entitlement to use the app;
  /// otherwise, false.
  final bool isActive;

  /// True if the license is a trial license; otherwise, false.
  final bool isTrial;

  /// The Store ID of a the licensed app SKU from the Microsoft Store catalog.
  final String skuStoreId;

  /// A unique ID that identifies the combination of the current user and the usage-limited
  /// trial that is associated with this app license.
  final String trialUniqueId;

  /// The remaining time for the usage-limited trial that is associated with this app license.
  final Duration trialTimeRemaining;

  /// Valid license info for durables add-on that is associated with the current app
  final List<AddOnLicense> addOnLicenses;

  factory StoreAppLicense._fromInner(inner.StoreAppLicenseInner data) {
    return StoreAppLicense._(
      isActive: data.isActive,
      isTrial: data.isTrial,
      skuStoreId: data.skuStoreId,
      trialUniqueId: data.trialUniqueId,
      trialTimeRemaining: Duration(milliseconds: data.trialTimeRemaining),
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
typedef StoreProductKind = inner.StoreProductKind;

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
  });

  /// Gets the Store ID for this product. For an add-on, this property corresponds to the Store ID that is available on the overview page for the add-on.
  String storeId;

  /// Gets the product description from the Microsoft Store listing.
  String description;

  /// Gets the product title from the Microsoft Store listing.
  String title;

  /// Gets the product ID for this product, if the current StoreProduct represents an add-on.
  String inAppOfferToken;

  /// Gets the type of the product.
  StoreProductKind productKind;

  /// Gets the price for the default SKU and availability for the product.
  StorePrice price;

  factory StoreProduct._fromInner(inner.StoreProductInner data) {
    return StoreProduct._(
      storeId: data.storeId,
      description: data.description,
      title: data.title,
      inAppOfferToken: data.inAppOfferToken,
      productKind: data.productKind,
      price: StorePrice._fromInner(data.price),
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
