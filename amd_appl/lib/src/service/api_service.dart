import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _IP = '127.0.0.1'; 
  static const String _baseUrl = 'http://${_IP}/api'; 

  /// Generic GET service
  Future<List<dynamic>> getService(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$endpoint'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('GET request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during GET request: $e');
    }
  }

  /// Fetch specific machine data
  Future<List<dynamic>> fetchMachines() async {
    return await getService('/machines/');
  }

  /// Fetch logs for a specific machine
  Future<List<dynamic>> fetchLogs(int machineId) async {
    return await getService('/machines/$machineId/logs/');
  }
}
