#ifndef FLUTTER_PLUGIN_WINDOWS_STORE_HELPER_H_
#define FLUTTER_PLUGIN_WINDOWS_STORE_HELPER_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>
#include <winrt/base.h>

namespace windows_store
{
    
  /// @brief  Get the name of the product kind as a string as required by winrt API
  /// @param product_kind The product kind
  /// @return The name of the product kind
  winrt::hstring getProductKindName(const StoreProductKind &product_kind);

  /// @brief  Get the StoreProductKind from a string
  /// @param product_kind_str The product kind as a string
  /// @return The StoreProductKind
  StoreProductKind getProductKind(const winrt::hstring &product_kind_str);

  std::string dateTimeToISO8601(const winrt::Windows::Foundation::DateTime &dateTime);
  
} // namespace windows_store

#endif // FLUTTER_PLUGIN_WINDOWS_STORE_HELPER_H_
