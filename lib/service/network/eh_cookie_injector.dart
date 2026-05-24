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

    _cookieInjector = _EHCookieInjector(dynamicCookies);
  }

  Interceptor get cookieInjector => _cookieInjector;


  // Interceptor getCookieInjector() {
  //   return cookieInjector;
  // }

}


class _EHCookieInjector extends Interceptor {
  final List<Cookie> immutableCookies = [Cookie('nw', '1'), Cookie('datatags', '1')];

  final List<Cookie> dynamicCookies;

  _EHCookieInjector(this.dynamicCookies);

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
        options.headers[HttpHeaders.cookieHeader] = CookieUtils.safeCookieString(
          cookies,
        );
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
    try {
      _saveEHCookies(response);
      handler.next(response);
    } on Exception catch (e, s) {
      final err = DioException(
        requestOptions: response.requestOptions,
        error: e,
        stackTrace: s,
      );
      return handler.reject(err, true);
    }
  }

}
