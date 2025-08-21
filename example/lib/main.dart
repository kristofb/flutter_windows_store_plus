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
    Widget addonLicencesWidget = ListView.builder(
      itemCount: license?.addOnLicenses.length ?? 0,
      itemBuilder: (context, index) {
        final addOnLicense = license!.addOnLicenses[index];
        return ListTile(
          title: Text('Add-on ${addOnLicense.inAppOfferToken} SKU: ${addOnLicense.skuStoreId}'),
          subtitle: Text('Valid until: ${addOnLicense.expirationDateTime}'),
        );
      },
    );

    Widget addonsWidget = ListView.builder(
      itemCount: addons?.products.length ?? 0,
      itemBuilder: (context, index) {
        final product = addons!.products[index];
        return ListTile(
          title: Text(product.title),
          subtitle: Text(product.description),
        );
      },
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Microsoft Store products & licenses demo', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Row(
          children: [
            Column(
              children: [
                const Text("Current application license info", style: TextStyle(fontWeight: FontWeight.bold)),
                Text('isActive = ${license?.isActive}'),
                Text('isTrial = ${license?.isTrial}'),
                Text('skuStoreId = ${license?.skuStoreId}'),
                Text('trialUniqueId = ${license?.trialUniqueId}'),
                Text('trialTimeRemaining = ${license?.trialTimeRemaining}'),
                Text('addons = ${addons?.products.length}'),
                const Text("Current add-ons license info", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: addonLicencesWidget),
              ],
            ),
            const VerticalDivider(),
            Column(
              children: [
                const Text("Application Add-ons info", style: TextStyle(fontWeight: FontWeight.bold)),
               // Expanded(child: addonsWidget),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
