import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';

const String serverAddress = '${kDebugMode ? 'localhost' : ''}:80';

final Dio dio = Dio()..interceptors.add(CookieManager(CookieJar()));

Future<ServerResponse<T>> post<T>(
  String path, {
  Map<String, dynamic>? body,
}) async {
  Response<T> response = await dio.post<T>(
    (kDebugMode
            ? Uri.http(serverAddress, path)
            : Uri.https(serverAddress, path))
        .toString(),
    data: body,
  );

  return ServerResponse(
    statusCode: response.statusCode,
    body: response.data,
  );
}

class ServerResponse<T> {
  final T? body;
  final int? statusCode;

  const ServerResponse({
    required this.statusCode,
    this.body,
  });
}
