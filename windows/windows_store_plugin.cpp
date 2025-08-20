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

using namespace winrt;
using namespace Windows::Services;
using namespace Windows::Foundation;
using namespace Concurrency;

namespace windows_store
{

  // static
  void WindowsStorePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    static auto plugin = std::make_unique<WindowsStoreApiInstance>();
    WindowsStoreApi::SetUp(registrar->messenger(),
                           plugin.get());
  }

} // namespace windows_store
