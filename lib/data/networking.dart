import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';

const String serverAddress = '${kDebugMode ? 'localhost' : ''}:80';

final Dio dio = Dio()..interceptors.add(CookieManager(CookieJar()));

Future<ServerResponse<T>> post<T>(
  final String path, {
  final Map<String, dynamic>? body,
}) async {
  final Response<T> response = await dio.post<T>(
    fullPath(path),
    data: body,
  );

  return ServerResponse(
    statusCode: response.statusCode,
    body: response.data,
  );
}

Future<ServerResponse<T>> get<T>(
  final String path, {
  final Map<String, dynamic>? queryParameters,
}) async {
  final Response<T> response = await dio.get<T>(
    fullPath(path),
    queryParameters: queryParameters,
  );

  return ServerResponse(
    statusCode: response.statusCode,
    body: response.data,
  );
}

String fullPath(final String path) => (kDebugMode
        ? Uri.http(serverAddress, path)
        : Uri.https(serverAddress, path))
    .toString();

class ServerResponse<T> {
  final T? body;
  final int? statusCode;

  const ServerResponse({
    required this.statusCode,
    this.body,
  });
}
