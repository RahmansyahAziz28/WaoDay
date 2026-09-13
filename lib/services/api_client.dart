import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/dummy_data.dart';
import 'auth_service.dart';

/// Centralized API HTTP client that handles:
/// - Injection of Authorization bearer token
/// - Default request timeout
/// - Global interception of 401 Unauthorized responses to trigger logout & notification
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final http.Client _client = http.Client();

  static const Duration defaultTimeout = Duration(seconds: 15);

  Future<String?> _resolveToken() async {
    return await AuthService.instance.getToken() ?? AppData.instance.token;
  }

  Map<String, String> _buildHeaders({
    String? token,
    bool isJson = true,
    Map<String, String>? extraHeaders,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  http.Response _processResponse(http.Response response) {
    if (response.statusCode == 401) {
      debugPrint('[ApiClient] 401 Unauthorized detected on ${response.request?.url}');
      AuthService.instance.handleSessionExpired();
    }
    return response;
  }

  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    String? token,
    Duration timeout = defaultTimeout,
  }) async {
    final activeToken = token ?? await _resolveToken();
    final combinedHeaders = _buildHeaders(
      token: activeToken,
      isJson: false,
      extraHeaders: headers,
    );

    final response = await _client.get(url, headers: combinedHeaders).timeout(timeout);
    return _processResponse(response);
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    String? token,
    Duration timeout = defaultTimeout,
  }) async {
    final activeToken = token ?? await _resolveToken();
    final combinedHeaders = _buildHeaders(
      token: activeToken,
      isJson: true,
      extraHeaders: headers,
    );

    final response = await _client
        .post(url, headers: combinedHeaders, body: body)
        .timeout(timeout);
    return _processResponse(response);
  }

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    String? token,
    Duration timeout = defaultTimeout,
  }) async {
    final activeToken = token ?? await _resolveToken();
    final combinedHeaders = _buildHeaders(
      token: activeToken,
      isJson: true,
      extraHeaders: headers,
    );

    final response = await _client
        .put(url, headers: combinedHeaders, body: body)
        .timeout(timeout);
    return _processResponse(response);
  }

  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    String? token,
    Duration timeout = defaultTimeout,
  }) async {
    final activeToken = token ?? await _resolveToken();
    final combinedHeaders = _buildHeaders(
      token: activeToken,
      isJson: true,
      extraHeaders: headers,
    );

    final response = await _client
        .delete(url, headers: combinedHeaders, body: body)
        .timeout(timeout);
    return _processResponse(response);
  }
}
