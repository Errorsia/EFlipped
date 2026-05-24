import 'package:dio/dio.dart';
// import 'dart:convert';
import 'dart:io';
import 'cookie_utils.dart';

class EHCookieManager {
  late final List<Cookie> dynamicCookies;
  late final _EHCookieInjector _cookieInjector;

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

  void _updateCookies(List<Cookie> newCookies) {
    for (var c in newCookies) {
      dynamicCookies.removeWhere((old) => old.name == c.name);
      dynamicCookies.add(c);
    }
    //  todo: store cookies
  }

  // Timer? _saveTimer;

  // void _updateCookies(List<Cookie> newCookies) {
  //   // merge
  //   for (var c in newCookies) {
  //     dynamicCookies.removeWhere((old) => old.name == c.name);
  //     dynamicCookies.add(c);
  //   }

  //   // delay in writing
  //   _saveTimer?.cancel();
  //   _saveTimer = Timer(Duration(seconds: 1), () {
  //     saveToDisk(dynamicCookies);
  //   });
  // }

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

  Future<void> initCookies() async {
    // String? string = await localConfigService.read(
    //   configKey: ConfigEnum.ehCookie,
    // );
    // if (string != null) {
    //   List list = jsonDecode(string);
    //   cookies.addAll(
    //     list.cast<String>().map(Cookie.fromSetCookieValue).toList(),
    //   );
    // }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      if (networkSetting.allHostAndIPs.contains(options.uri.host)) {
        options.headers[HttpHeaders.cookieHeader] =
            CookieUtils.safeCookieString(cookies);
      }
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
