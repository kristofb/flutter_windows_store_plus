import 'package:flutter/material.dart';
import 'dart:async';

import 'package:windows_store/windows_store.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _windowsStorePlugin = WindowsStoreApi();
  StoreAppLicense? license;
  AssociatedStoreProducts? addons;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final result = await _windowsStorePlugin.getAppLicenseAsync();
    AssociatedStoreProducts? addons;
    try {
      addons = await _windowsStorePlugin.getAssociatedStoreProductsAsync(StoreProductKind.durable);
    } catch (e) {
      print('Error fetching associated store products: $e');
    }
    setState(() {
      license = result;
      this.addons = addons;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Widget for application license info
    Widget appLicenseInfo = Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Application License Info", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Is Active: ${license?.isActive ?? 'Unknown'}'),
          Text('Is Trial: ${license?.isTrial ?? 'Unknown'}'),
          Text('SKU Store ID: ${license?.skuStoreId ?? 'Unknown'}'),
          Text('Trial Unique ID: ${license?.trialUniqueId ?? 'Unknown'}'),
          Text('Trial Time Remaining: ${license?.trialTimeRemaining ?? 'Unknown'}'),
          const SizedBox(height: 16),
        ],
      ),
    );

    // Widget for add-on licenses info
    Widget addonLicencesWidget = Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add-on Licenses", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Count: ${license?.addOnLicenses.length ?? 0}'),
          const SizedBox(height: 8),
          Expanded(
            child: license?.addOnLicenses.isNotEmpty == true
                ? ListView.builder(
                    itemCount: license!.addOnLicenses.length,
                    itemBuilder: (context, index) {
                      final addOnLicense = license!.addOnLicenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SKU: ${addOnLicense.skuStoreId}', 
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Offer Token: ${addOnLicense.inAppOfferToken}'),
                              Text('Valid until: ${addOnLicense.expirationDateTime}'),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No add-on licenses found')),
          ),
        ],
      ),
    );

    // Widget for add-ons product info
    Widget addonsWidget = Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add-on Products", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Count: ${addons?.products.length ?? 0}'),
          const SizedBox(height: 8),
          Expanded(
            child: addons?.products.isNotEmpty == true
                ? ListView.builder(
                    itemCount: addons!.products.length,
                    itemBuilder: (context, index) {
                      final product = addons!.products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.title, 
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (product.description.isNotEmpty)
                                Text('Description: ${product.description}'),
                              Text('Store ID: ${product.storeId}'),
                              Text('Product Kind: ${product.productKind}'),
                              Text('Price: ${product.price.formattedPrice}'),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No add-on products found')),
          ),
        ],
      ),
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Microsoft Store Products & Licenses Demo', 
            style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Account for divider width
            const dividerWidth = 1.0;
            double availableWidth = constraints.maxWidth - dividerWidth;
            
            // Calculate column widths based on available space
            double leftColumnWidth = availableWidth * 0.4;
            double rightColumnWidth = availableWidth * 0.6;
            
            // Ensure minimum widths but adjust if needed to fit screen
            if (leftColumnWidth < 300 && availableWidth > 700) {
              leftColumnWidth = 300;
              rightColumnWidth = availableWidth - 300;
            } else if (availableWidth <= 700) {
              // For smaller screens, use proportional sizing
              leftColumnWidth = availableWidth * 0.4;
              rightColumnWidth = availableWidth * 0.6;
            }
            
            return Row(
              children: [
                // Left column: License info
                SizedBox(
                  width: leftColumnWidth,
                  child: Column(
                    children: [
                      Expanded(flex: 1, child: appLicenseInfo),
                      Expanded(flex: 2, child: addonLicencesWidget),
                    ],
                  ),
                ),
                const VerticalDivider(width: dividerWidth),
                // Right column: Add-ons info
                SizedBox(
                  width: rightColumnWidth,
                  child: addonsWidget,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
