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

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text('isActive = ${license?.isActive}'),
            Text('isTrial = ${license?.isTrial}'),
            Text('skuStoreId = ${license?.skuStoreId}'),
            Text('trialUniqueId = ${license?.trialUniqueId}'),
            Text('trialTimeRemaining = ${license?.trialTimeRemaining}'),
            Text('addons = ${addons?.products.length}'),
            Expanded(child: addonLicencesWidget),
          ],
        ),
      ),
    );
  }
}
