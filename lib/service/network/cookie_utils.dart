import 'dart:io';

class CookieUtils{
  static String safeCookieString(List<Cookie> cookies) {
    return cookies
        .map((c) => '${c.name}=${Uri.encodeComponent(c.value)}')
        .join('; ');
  }

}