import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class HttpService {
  static late Dio _dio;
  static late CookieJar _cookieJar;
  static bool _initialized = false;

  static void initialize() {
    if (!_initialized) {
      _cookieJar = CookieJar();
      _dio = Dio();
      _dio.interceptors.add(CookieManager(_cookieJar));
      _dio.options.baseUrl = 'http://localhost/elecom_system/api';
      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 10);
      _initialized = true;
    }
  }

  static Dio get dio {
    if (!_initialized) {
      initialize();
    }
    return _dio;
  }

  static Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    return await dio.post(
      path,
      data: data,
      options: Options(
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
    );
  }

  static Future<Response> get(String path) async {
    return await dio.get(
      path,
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  static Future<void> clearCookies() async {
    if (_initialized) {
      await _cookieJar.deleteAll();
    }
  }
}
