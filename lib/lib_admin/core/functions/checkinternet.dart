import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
checkInternet() async {
  try {
    final connectivityResults = await Connectivity()
        .checkConnectivity()
        .timeout(const Duration(seconds: 3));
    debugPrint('📡 Connectivity results: $connectivityResults');
    if (connectivityResults is List) {
      final results = connectivityResults as List;
      if (results.isEmpty) {
        debugPrint('🔴 No connectivity detected');
        return false;
      }
      final hasNone = results.any((r) => r.toString().contains('none'));
      if (hasNone && results.length == 1) {
        debugPrint('🔴 No connectivity detected');
        return false;
      }
      debugPrint('✅ Connectivity detected: $results');
      return true;
    }
    debugPrint('✅ Connectivity detected: $connectivityResults');
    return true;
  } on TimeoutException catch (e) {
    debugPrint('⚠️ Connectivity check timeout: $e - Proceeding anyway');
    return true;
  } catch (e) {
    debugPrint('⚠️ Connectivity check error: $e - Proceeding anyway');
    return true;
  }
}
