import 'dart:async';

import 'package:dio/dio.dart';
// import 'dart:convert';
import 'dart:io';
import 'cookie_utils.dart';

class EHCookieManager {
  late final List<Cookie> dynamicCookies;
  late final _EHCookieInjector _cookieInjector;
  Timer? _saveTimer;

  EHCookieManager() {
    // dynamicCookies will be loaded here
    dynamicCookies = [Cookie('x', 'x'), Cookie('datatags', '1')];

    _cookieInjector = _EHCookieInjector(dynamicCookies, _updateCookies);
  }

  Interceptor get cookieInjector => _cookieInjector;

  // OK but not the best choice
  // Interceptor getCookieInjector() {
  //   return cookieInjector;
  // }

  Future<void> replaceCookies(List<Cookie> newCookies) async {
    dynamicCookies.removeWhere(
      (cookie) => newCookies.any((c) => c.name == cookie.name),
    );
    dynamicCookies.addAll(newCookies);
  }

  Future<void> removeCookies(List<String> cookieNames) async {
    dynamicCookies.removeWhere(
      (cookie) => cookieNames.any((name) => cookie.name == name),
    );
  }

  void _updateCookies(List<Cookie> newCookies) {
    // merge
    for (var c in newCookies) {
      dynamicCookies.removeWhere((old) => old.name == c.name);
      dynamicCookies.add(c);
    }

    // delay 2s then storing the cookies
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 2), () {
      // store cookies
    });
  }

}

class _EHCookieInjector extends Interceptor {
  final void Function(List<Cookie>) onCookiesReceived;
  final List<Cookie> immutableCookies = [
    Cookie('nw', '1'),
    Cookie('datatags', '1'),
  ];

  final List<Cookie> dynamicCookies;

  _EHCookieInjector(
    // this.immutableCookies,
    this.dynamicCookies,
    this.onCookiesReceived,
  );

  List<Cookie> get cookies => [...immutableCookies, ...dynamicCookies];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {

      // ip filter, but we dont need it
      // if (networkSetting.allHostAndIPs.contains(options.uri.host)) {
      //   options.headers[HttpHeaders.cookieHeader] =
      //       CookieUtils.safeCookieString(cookies);
      // }
      options.headers[HttpHeaders.cookieHeader] = CookieUtils.safeCookieString(cookies);
      handler.next(options);
    } on Exception catch (e, stackTrace) {
      var err = DioException(
        requestOptions: options,
        error: e,
        stackTrace: stackTrace,
      );
      handler.reject(err, true);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final setCookies = response.headers['set-cookie'];
    if (setCookies != null) {
      final parsed = setCookies.map(Cookie.fromSetCookieValue).toList();
      onCookiesReceived(parsed);
    }
    handler.next(response);
  }
}
