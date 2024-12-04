import 'dart:convert';
import 'package:public_bicycle/vm/token_access.dart';
import 'package:http/http.dart' as http;

class Myapi extends TokenAccess {
  Future<http.Response> makeAuthenticatedRequest(String url, {String method = 'GET', Map<String, dynamic>? body}) async {
    String? accessToken = await getAccessToken();

    try {
      // 요청 생성
      var request = await http.Request(method, Uri.parse(url))
        ..headers.addAll({
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        });
      request.body = body != null ? jsonEncode(body) : '';
      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      // AccessToken 만료 시 RefreshToken 사용
      if (res.statusCode == 401) {
        final tokenRefreshed = await refreshAccessToken();
        if (tokenRefreshed) {
          // 토큰 갱신 후 다시 요청
          accessToken = await getAccessToken();
          return await makeAuthenticatedRequest(url, method: method, body: body);
        } else {
          throw Exception("Failed to refresh access token");
        }
      }

      return res;
    } catch (e) {
      print("Request failed: $e");
      rethrow;
    }
  }
}
