import 'package:dio/dio.dart';
// import 'dart:convert';
import 'dart:io';
import 'cookie_utils.dart';


class EHCookieManager {
  final EHCookieInjector cookieInjector = EHCookieInjector();

  Future<void> replaceCookies(List<Cookie> cookies) async {
    
  }


  EHCookieInjector getCookieInjector(){
    return cookieInjector;
  }

}

class EHCookieInjector extends Interceptor {
  final List<Cookie> immutableCookies = [Cookie('nw', '1'), Cookie('datatags', '1')];


  Future<void> initCookies() async {
    String? string = await localConfigService.read(
      configKey: ConfigEnum.ehCookie,
    );
    if (string != null) {
      List list = jsonDecode(string);
      cookies.addAll(
        list.cast<String>().map(Cookie.fromSetCookieValue).toList(),
      );
    }
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
