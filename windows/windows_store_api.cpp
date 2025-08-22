#include "windows_store_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

#include <iostream>
#include <ppltasks.h>
#include <winrt/Windows.Services.Store.h>
#include <winrt/Windows.Foundation.Collections.h>

#include "pigeon/messages.g.h"
#include "windows_store_api.h"
#include "windows_store_helper.h"

using namespace winrt;
using namespace Windows::Services;
using namespace Windows::Foundation;
using namespace Concurrency;
using namespace Windows::Services::Store;

namespace windows_store
{

  void WindowsStoreApiInstance::GetAppLicenseAsync(std::function<void(ErrorOr<StoreAppLicenseInner> reply)> result)
  {
    concurrency::create_task([result]
                             {
      try
      {
        Store::StoreContext storeContext = Store::StoreContext::GetDefault();

        // Get application license
        auto licenseAsync = storeContext.GetAppLicenseAsync();
        auto license = licenseAsync.get();

        // Gets valid license info for durables add-on that is associated with the current app
        // Invalid license are not included, licenses for consumable add-ons are not included.
        winrt::Windows::Foundation::Collections::IMapView<winrt::hstring, winrt::Windows::Services::Store::StoreLicense> addOnLicences = license.AddOnLicenses();
        flutter::EncodableList addonLicenseList;
        for (const auto &[key, storeLicence] : addOnLicences)
        {
          AddOnLicenseInner addonLicense = AddOnLicenseInner(
              winrt::to_string(storeLicence.InAppOfferToken()),
              winrt::to_string(storeLicence.SkuStoreId()),
              dateTimeToISO8601(storeLicence.ExpirationDate())
              );
          addonLicenseList.push_back(flutter::CustomEncodableValue(std::move(addonLicense)));
        }
#if GENERATE_LICENSE_TEST_DATA
          std::cout << "Generating test data for add-on licenses..." << std::endl;
          {
            // Generate a date time for tomorrow
            auto tomorrow = winrt::clock::now() + std::chrono::hours(24);
            AddOnLicenseInner addonLicense = AddOnLicenseInner(
                winrt::to_string(L"InAppOfferToken1"),
                winrt::to_string(L"SkuStoreId1"),
                dateTimeToISO8601(tomorrow)
                );
            addonLicenseList.push_back(flutter::CustomEncodableValue(std::move(addonLicense)));
          }
          {
            // Generate a date time for tomorrow
            auto tomorrow = winrt::clock::now() + std::chrono::hours(24);
            AddOnLicenseInner addonLicense = AddOnLicenseInner(
                winrt::to_string(L"InAppOfferToken2"),
                winrt::to_string(L"SkuStoreId2"),
                dateTimeToISO8601(tomorrow)
                );
            addonLicenseList.push_back(flutter::CustomEncodableValue(std::move(addonLicense)));
          }
#endif

        auto licenseInfo = StoreAppLicenseInner(
            license.IsActive(),
            license.IsTrial(),
            winrt::to_string(license.SkuStoreId()),
            winrt::to_string(license.TrialUniqueId()),
            license.TrialTimeRemaining().count() /*A time period expressed in 100-nanosecond units*/ / 10000000l,
            dateTimeToISO8601(license.ExpirationDate()),
            addonLicenseList);

        result(licenseInfo);
        }
        catch (winrt::hresult_error const &ex)
        {
          winrt::hresult hr = ex.code();
          winrt::hstring message = ex.message();
          result(FlutterError(std::to_string(hr.value), winrt::to_string(message), ""));
        } });
  }

  void WindowsStoreApiInstance::GetAssociatedStoreProductsAsync(
      const StoreProductKind &product_kind,
      std::function<void(ErrorOr<AssociatedStoreProductsInner> reply)> result)
  {
    concurrency::create_task([product_kind, result]
                             {
        try{
          Store::StoreContext storeContext = Store::StoreContext::GetDefault();
          winrt::hstring productKindStr = getProductKindName(product_kind);
          // Create an array containing the only element we want to query.
          auto productKinds = winrt::single_threaded_vector<winrt::hstring>();
          productKinds.Append(productKindStr);
          auto productsAsync = storeContext.GetAssociatedStoreProductsAsync(productKinds);
          auto productsResult = productsAsync.get();

          // Check if there has been an error during the call
          winrt::hresult hr = productsResult.ExtendedError();
          if (hr.value != S_OK)
          {
#if GENERATE_LICENSE_TEST_DATA
            std::cout << "Generating test data for associated add-ons..." << std::endl;
            auto usd = winrt::to_string(L"USD");
            auto tomorrow = winrt::clock::now() + std::chrono::hours(24);
            flutter::EncodableList productList;
            {
              StorePriceInner priceInner = StorePriceInner(
                  usd,
                  true /* on sale */,
                  dateTimeToISO8601(tomorrow), /* sale end date */
                  winrt::to_string(L"14.00"),
                  winrt::to_string(L"14.00"),
                  winrt::to_string(L"14.00"));
                  
              flutter::EncodableList productSkuList;
              auto skuPrice = StorePriceInner(
                  usd,
                  true /* on sale */,
                  dateTimeToISO8601(tomorrow), /* sale end date */
                  winrt::to_string(L"14.00"),
                  winrt::to_string(L"14.00"),
                  winrt::to_string(L"14.00"));
              auto subscriptionInfo = new StoreSubscriptionInfoInner(
                1,
                StoreSubscriptionBillingPeriodUnit::kYear,
                true /* trial */,
                7,
                StoreSubscriptionBillingPeriodUnit::kDay
              );
              StoreProductSkuInner skuInner = StoreProductSkuInner(
                winrt::to_string(L"SkuStoreId1"),
                false /*is trial*/,
                true /*is subscription*/,
                winrt::to_string(L"SKU Description"),
                winrt::to_string(L"SKU Title"),
                subscriptionInfo,
                skuPrice
              );
              productSkuList.push_back(flutter::CustomEncodableValue(std::move(skuInner)));

              StoreProductInner productInner = StoreProductInner(
                winrt::to_string(L"SkuStoreId1"),
                winrt::to_string(L"This is my product 1 description"),
                winrt::to_string(L"Product 1"),
                winrt::to_string(L"InAppOfferToken1"),
                windows_store::StoreProductKind::kDurable,
                priceInner,
                productSkuList
              );

              productList.push_back(flutter::CustomEncodableValue(std::move(productInner)));
            }
            {
              StorePriceInner priceInner = StorePriceInner(
                  usd,
                  true /* on sale */,
                  dateTimeToISO8601(tomorrow), /* sale end date */
                  winrt::to_string(L"110.00"),
                  winrt::to_string(L"110.00"),
                  winrt::to_string(L"110.00"));

              flutter::EncodableList productSkuList;
              auto skuPrice = StorePriceInner(
                  usd,
                  true /* on sale */,
                  dateTimeToISO8601(tomorrow), /* sale end date */
                  winrt::to_string(L"110.00"),
                  winrt::to_string(L"110.00"),
                  winrt::to_string(L"110.00"));
              StoreProductSkuInner skuInner = StoreProductSkuInner(
                winrt::to_string(L"SkuStoreId2"),
                false /*is trial*/,
                false /*is subscription*/,
                winrt::to_string(L"SKU Description"),
                winrt::to_string(L"SKU Title"),
                nullptr,
                skuPrice
              );
              productSkuList.push_back(flutter::CustomEncodableValue(std::move(skuInner)));

              StoreProductInner productInner = StoreProductInner(
                winrt::to_string(L"SkuStoreId2"),
                winrt::to_string(L"This is my product 2 description"),
                winrt::to_string(L"Product 2"),
                winrt::to_string(L"InAppOfferToken2"),
                windows_store::StoreProductKind::kDurable,
                priceInner,
                productSkuList
              );

              productList.push_back(flutter::CustomEncodableValue(std::move(productInner)));
            }
            result(AssociatedStoreProductsInner{ productList });
#else       
            // If there is an error, we return it
            result(FlutterError(std::to_string(hr.value), hr.value == ERROR_NO_SUCH_USER ?
                winrt::to_string(L"Error while getting associated store products, no user connected")
              : winrt::to_string(L"Error while getting associated store products"), ""));
#endif
            return;
          }
		  
          std::cout << "Successfully retrieved associated store products." << std::endl;

          // Iterate the map to get info about all products
          auto productsMap = productsResult.Products();
          flutter::EncodableList productList;
          for (const auto& [key, product] : productsMap)
          {
            // Convert each product to StoreProductInner
            // Note: StoreProductInner constructor expects std::string, so we convert winrt::hstring to std::string
            std::string storeId = winrt::to_string(product.StoreId());
            std::string description = winrt::to_string(product.Description());
            std::string title = winrt::to_string(product.Title());
            std::string inAppOfferToken = winrt::to_string(product.InAppOfferToken());
            StoreProductKind productKind = getProductKind(product.ProductKind());

            DateTime saleEndDate = product.Price().SaleEndDate();
            // convert to ISO 8601 string
            std::string saleEndDateStr = dateTimeToISO8601(saleEndDate);

            StorePriceInner priceInner = StorePriceInner(
                winrt::to_string(product.Price().CurrencyCode()),
                product.Price().IsOnSale(),
                saleEndDateStr,
                winrt::to_string(product.Price().FormattedBasePrice()),
                winrt::to_string(product.Price().FormattedPrice()),
                winrt::to_string(product.Price().FormattedRecurrencePrice()));

            // Study the SKUs of the product
            flutter::EncodableList productSkuList;
            for (StoreSku const& sku : product.Skus())
            {
              auto skuPrice = StorePriceInner(
                  winrt::to_string(sku.Price().CurrencyCode()),
                  sku.Price().IsOnSale(),
                  dateTimeToISO8601(sku.Price().SaleEndDate()),
                  winrt::to_string(sku.Price().FormattedBasePrice()),
                  winrt::to_string(sku.Price().FormattedPrice()),
                  winrt::to_string(sku.Price().FormattedRecurrencePrice())
              );

              auto subscriptionInfo = sku.SubscriptionInfo() ? new StoreSubscriptionInfoInner(
                    sku.SubscriptionInfo().BillingPeriod(),
                    getSubscriptionBillingPeriodUnit(sku.SubscriptionInfo().BillingPeriodUnit()),
                    sku.SubscriptionInfo().HasTrialPeriod(),
                    sku.SubscriptionInfo().TrialPeriod(),
                    getSubscriptionBillingPeriodUnit(sku.SubscriptionInfo().TrialPeriodUnit()))
                : nullptr;

              auto collectionData = StoreCollectionDataInner(
                  winrt::to_string(sku.CollectionData().CampaignId()),
                  winrt::to_string(sku.CollectionData().DeveloperOfferId()),
                  winrt::to_string(sku.CollectionData().ExtendedJsonData()),
                  sku.CollectionData().IsTrial(),
                  dateTimeToISO8601(sku.CollectionData().AcquiredDate()),
                  dateTimeToISO8601(sku.CollectionData().StartDate()),
                  dateTimeToISO8601(sku.CollectionData().EndDate()),
                  sku.CollectionData().TrialTimeRemaining().count() /*A time period expressed in 100-nanosecond units*/ / 10000000l
              );

              StoreProductSkuInner skuInner = StoreProductSkuInner(
                winrt::to_string(sku.StoreId()),
                sku.IsTrial(),
                sku.IsSubscription(),
                winrt::to_string(sku.Description()),
                winrt::to_string(sku.Title()),
                subscriptionInfo,
                skuPrice,
                winrt::to_string(sku.CustomDeveloperData()),
                winrt::to_string(sku.ExtendedJsonData()),
                sku.IsInUserCollection(),
                collectionData
              );
              productSkuList.push_back(flutter::CustomEncodableValue(std::move(skuInner)));
            }

            StoreProductInner productInner = StoreProductInner(
              storeId, 
              description, 
              title, 
              inAppOfferToken, 
              productKind, 
              priceInner,
              productSkuList
            );

            productList.push_back(flutter::CustomEncodableValue(std::move(productInner)));
          }

          result(AssociatedStoreProductsInner{ productList });
        }  catch (winrt::hresult_error const& ex)
        {
            winrt::hresult hr = ex.code();
            winrt::hstring message = ex.message();
            result(FlutterError(std::to_string(hr.value), winrt::to_string(message), ""));
        } });
  }

} // namespace windows_store
