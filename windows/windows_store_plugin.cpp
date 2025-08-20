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

using namespace winrt;
using namespace Windows::Services;
using namespace Windows::Foundation;
using namespace Concurrency;

namespace windows_store
{

  class WindowsStoreApiInstance : public WindowsStoreApi
  {
  public:
    WindowsStoreApiInstance() {}
    virtual ~WindowsStoreApiInstance() {}

    void GetAppLicenseAsync(std::function<void(ErrorOr<StoreAppLicenseInner> reply)> result)
    {
      concurrency::create_task([result]
                               {
		  try {
        Store::StoreContext storeContext = Store::StoreContext::GetDefault();
        auto licenseAsync = storeContext.GetAppLicenseAsync();
        auto license = licenseAsync.get();

        std::string skuStoreId = winrt::to_string(license.SkuStoreId());
        std::string trialUniqueId = winrt::to_string(license.TrialUniqueId());

        result(StoreAppLicenseInner(license.IsActive(), license.IsTrial(), skuStoreId, trialUniqueId, license.TrialTimeRemaining().count() / 10000));
		  }  catch (winrt::hresult_error const& ex)
        {
            winrt::hresult hr = ex.code();
            winrt::hstring message = ex.message();
            result(FlutterError(std::to_string(hr.value), winrt::to_string(message), ""));
        } });
    }

    void GetAssociatedStoreProductsAsync(
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
                                   // If there is an error, we return it
                                   result(FlutterError(std::to_string(hr.value), 
									   hr.value == ERROR_NO_SUCH_USER ?
                                       winrt::to_string(L"Error while getting associated store products, no user connected")
                                           :
                                       winrt::to_string(L"Error while getting associated store products"), ""));
                                   return;
								 }

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

                                  StoreProductInner productInner = StoreProductInner(storeId, description, title, inAppOfferToken, productKind, priceInner);

                                   //productList.push_back(flutter::EncodableValue(productInner));
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

    /// @brief  Get the name of the product kind as a string as required by winrt API
    /// @param product_kind The product kind
    /// @return The name of the product kind
    static winrt::hstring getProductKindName(const StoreProductKind &product_kind)
    {
      switch (product_kind)
      {
      case StoreProductKind::kApplication:
        return L"Application";
      case StoreProductKind::kGame:
        return L"Game";
      case StoreProductKind::kConsumable:
        return L"Consumable";
      case StoreProductKind::kUnmanagedConsumable:
        return L"UnmanagedConsumable";
      case StoreProductKind::kDurable:
        return L"Durable";
      default:
        return L"Durable";
      }
    }

    /// @brief  Get the StoreProductKind from a string
    /// @param product_kind_str The product kind as a string
    /// @return The StoreProductKind
    static StoreProductKind getProductKind(const winrt::hstring &product_kind_str)
    {
      if (product_kind_str == L"Application")
        return StoreProductKind::kApplication;
      else if (product_kind_str == L"Game")
        return StoreProductKind::kGame;
      else if (product_kind_str == L"Consumable")
        return StoreProductKind::kConsumable;
      else if (product_kind_str == L"UnmanagedConsumable")
        return StoreProductKind::kUnmanagedConsumable;
      else if (product_kind_str == L"Durable")
        return StoreProductKind::kDurable;
      else
        return StoreProductKind::kDurable; // Default case
    }

    static std::string dateTimeToISO8601(const winrt::Windows::Foundation::DateTime &dateTime)
    {
      // Convert winrt::Windows::Foundation::DateTime to SYSTEMTIME
      auto time = dateTime.time_since_epoch();
      auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(time);
      auto seconds = std::chrono::duration_cast<std::chrono::seconds>(duration);
      //auto milliseconds = duration.count() % 1000;

      // Create SYSTEMTIME
      SYSTEMTIME st;
      FILETIME ft;
      ft.dwLowDateTime = static_cast<DWORD>(seconds.count() * 10000000 + 116444736000000000);
      ft.dwHighDateTime = static_cast<DWORD>(seconds.count() >> 32);
      FileTimeToSystemTime(&ft, &st);

      // Format to ISO 8601
      char buffer[32];
      sprintf_s(buffer, "%04d-%02d-%02dT%02d:%02d:%02dZ",
                st.wYear, st.wMonth, st.wDay,
                st.wHour, st.wMinute, st.wSecond);

      return std::string(buffer);
    }
  };

  // static
  void WindowsStorePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    static auto plugin = std::make_unique<WindowsStoreApiInstance>();
    WindowsStoreApi::SetUp(registrar->messenger(),
                           plugin.get());
  }

} // namespace windows_store
