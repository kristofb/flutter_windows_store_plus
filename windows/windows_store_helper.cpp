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

namespace windows_store
{

  /// @brief  Get the name of the product kind as a string as required by winrt API
  /// @param product_kind The product kind
  /// @return The name of the product kind
  winrt::hstring getProductKindName(const StoreProductKind &product_kind)
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
  StoreProductKind getProductKind(const winrt::hstring &product_kind_str)
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

  std::string dateTimeToISO8601(const winrt::Windows::Foundation::DateTime& dateTime)
  {
      // Use winrt's built-in conversion
      FILETIME ft = winrt::clock::to_file_time(dateTime);

      SYSTEMTIME st;
      FileTimeToSystemTime(&ft, &st);

      // Format to ISO 8601
      char buffer[32];
      sprintf_s(buffer, "%04d-%02d-%02dT%02d:%02d:%02dZ",
          st.wYear, st.wMonth, st.wDay,
          st.wHour, st.wMinute, st.wSecond);

      return std::string(buffer);
  }

  StoreSubscriptionBillingPeriodUnit getSubscriptionBillingPeriodUnit(const winrt::Windows::Services::Store::StoreDurationUnit &unit)
  {
    switch (unit)
    {
    case winrt::Windows::Services::Store::StoreDurationUnit::Minute:
      return StoreSubscriptionBillingPeriodUnit::kMinute;
    case winrt::Windows::Services::Store::StoreDurationUnit::Hour:
      return StoreSubscriptionBillingPeriodUnit::kHour;
    case winrt::Windows::Services::Store::StoreDurationUnit::Day:
      return StoreSubscriptionBillingPeriodUnit::kDay;
    case winrt::Windows::Services::Store::StoreDurationUnit::Week:
      return StoreSubscriptionBillingPeriodUnit::kWeek;
    case winrt::Windows::Services::Store::StoreDurationUnit::Month:
      return StoreSubscriptionBillingPeriodUnit::kMonth;
    case winrt::Windows::Services::Store::StoreDurationUnit::Year:
      return StoreSubscriptionBillingPeriodUnit::kYear;
    default:
        std::cerr << "Unknown StoreDurationUnit: " << (int32_t)unit << std::endl;
        return StoreSubscriptionBillingPeriodUnit::kMonth;

    }
  }


} // namespace windows_store
