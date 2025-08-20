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

class StoreAppLicenseInner {
  final bool isActive;
  final bool isTrial;
  final String skuStoreId;
  final String trialUniqueId;
  final int trialTimeRemaining;

  const StoreAppLicenseInner(
    this.isActive,
    this.isTrial,
    this.skuStoreId,
    this.trialUniqueId,
    this.trialTimeRemaining,
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

  const StoreProductInner(
    this.storeId,
    this.description,
    this.title,
    this.inAppOfferToken,
    this.productKind,
    this.price,
  );
}

class AssociatedStoreProductsInner {
  final List<StoreProductInner> products;

  const AssociatedStoreProductsInner(this.products);
}

@HostApi()
abstract class WindowsStoreApi {
  @async
  StoreAppLicenseInner getAppLicenseAsync();

  /// Gets Microsoft Store listing info for the products that can be purchased from within the current app.
  /// productKind: The kind of product to retrieve.
  @async
  AssociatedStoreProductsInner getAssociatedStoreProductsAsync(StoreProductKind productKind);
}
