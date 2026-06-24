import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api/v1',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  try {
    final response = await dio.get('/properties');
    print('Status: ${response.statusCode}');
    if (response.data != null && response.data['data'] != null) {
      final data = response.data['data'] as List;
      print('Got ${data.length} properties');
    } else {
      print('No data array');
    }
  } catch (e) {
    print('Dio error: $e');
  }
}
