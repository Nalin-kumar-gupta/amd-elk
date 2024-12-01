import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _IP = '144.126.254.135'; 
  static const String _baseUrl = 'http://${_IP}:8000/api'; 

  /// Generic GET service
  Future<Map<String, dynamic>> getService(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl$endpoint'));
      if (response.statusCode == 200) {
        return json.decode(response.body); // Decoding the JSON response into a map
      } else {
        throw Exception('GET request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during GET request: $e');
    }
  }

  /// Fetch specific machine data
  Future<List<String>> fetchMachines() async {
    try {
      final response = await getService('/machines/');
      
      // Ensure the response contains the "data" field which is a list of strings
      if (response.containsKey('data') && response['data'] is List) {
        return List<String>.from(response['data']); // Return the list of machines (strings)
      } else {
        throw Exception('Invalid response format: Missing or incorrect "data" field');
      }
    } catch (e) {
      throw Exception('Error fetching machines: $e');
    }
  }

  /// Fetch logs for a specific machine
  Future<List<dynamic>> fetchLogs(String machineId) async {
    try {
      // Append machineId to the endpoint
      final response = await getService('/logs/');

      // Validate and process the response
      if (response.containsKey('data') && response['data'] is List) {
        return response['data']; // Return the logs as a list
      } else {
        throw Exception('Invalid response format: Missing or incorrect "data" field');
      }
    } catch (e) {
      throw Exception('Error fetching logs: $e');
    }
  }

}
