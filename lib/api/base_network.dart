import 'dart:convert';
import 'package:http/http.dart' as http;

class BaseNetwork {
  static const String baseUrl = 'https://api.jikan.moe/v4';

  static Future<List<dynamic>> getSearch(String param, String category, String orderBy, String sort) async {

    final String fullUrl = baseUrl + '/anime?$param=$category&order_by=$orderBy&sort=$sort';
    final response = await http.get(Uri.parse(fullUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final films = data['data'] as List<dynamic>;
      return films;
    } else {
      throw Exception('Failed to fetch anime data.');
    }
  }

  static Future<List<dynamic>> getTop() async {
    final String fullUrl = baseUrl + '/top/anime';
    final response = await http.get(Uri.parse(fullUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final films = data['data'] as List<dynamic>;
      return films;
    } else {
      throw Exception('Failed to fetch top anime data.');
    }
  }
}