#ifndef FLUTTER_PLUGIN_WINDOWS_STORE_API_H_
#define FLUTTER_PLUGIN_WINDOWS_STORE_API_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace windows_store
{
    class WindowsStoreApiInstance : public WindowsStoreApi
    {
    public:
        WindowsStoreApiInstance() {}
        virtual ~WindowsStoreApiInstance() {}

        void GetAppLicenseAsync(std::function<void(ErrorOr<StoreAppLicenseInner> reply)> result);

        void GetAssociatedStoreProductsAsync(
            const StoreProductKind &product_kind,
            std::function<void(ErrorOr<StoreProductCollectionInner> reply)> result);

        void GetUserCollectionAsync(
            const StoreProductKind &product_kind,
            std::function<void(ErrorOr<StoreProductCollectionInner> reply)> result);

    private:
        void GetStoreProductsAsync(
            const StoreProductKind &product_kind, const bool is_user_collection,
            std::function<void(ErrorOr<StoreProductCollectionInner> reply)> result);
    };

} // namespace windows_store

#endif // FLUTTER_PLUGIN_WINDOWS_STORE_API_H_
