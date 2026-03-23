import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _schemeBaseOverride =
      String.fromEnvironment('SCHEME_API_BASE_URL', defaultValue: '');
  static const String _paralegalBaseOverride =
      String.fromEnvironment('PARALEGAL_API_BASE_URL', defaultValue: '');
  static const String _overrideHost = String.fromEnvironment('API_HOST', defaultValue: '');

  static String _cleanBase(String value) {
    return value.trim().replaceAll(RegExp(r'/+$'), '');
  }

  static String get _host {
    if (_overrideHost.isNotEmpty) {
      return _overrideHost;
    }
    if (kIsWeb) {
      return 'localhost';
    }
    if (Platform.isAndroid) {
      return '10.0.2.2';
    }
    return 'localhost';
  }

  static String get schemesApiBase {
    if (_schemeBaseOverride.isNotEmpty) {
      return _cleanBase(_schemeBaseOverride);
    }
    return 'http://$_host:5000/api/schemes';
  }

  static String get paralegalApiBase {
    if (_paralegalBaseOverride.isNotEmpty) {
      return _cleanBase(_paralegalBaseOverride);
    }
    return 'http://$_host:5001/api';
  }
}
