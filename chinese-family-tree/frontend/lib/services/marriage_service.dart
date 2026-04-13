import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/marriage.dart';

class MarriageService {
  final String baseUrl;
  final http.Client _client;

  MarriageService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  /// Get all marriages
  Future<List<Marriage>> getMarriages() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/marriages'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final marriages = (data['data'] as List)
          .map((m) => Marriage.fromJson(m as Map<String, dynamic>))
          .toList();
      return marriages;
    } else {
      throw Exception('Failed to get marriages: ${response.statusCode}');
    }
  }

  /// Get marriage by ID
  Future<Marriage> getMarriage(int id) async {
    final response = await _client.get(Uri.parse('$baseUrl/api/marriages/$id'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Marriage.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to get marriage: ${response.statusCode}');
    }
  }

  /// Create a new marriage
  Future<Marriage> createMarriage(Marriage marriage) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/marriages'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(marriage.toJson()),
    );
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Marriage.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create marriage: ${response.body}');
    }
  }

  /// Update a marriage
  Future<Marriage> updateMarriage(int id, Marriage marriage) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/marriages/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(marriage.toJson()),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Marriage.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update marriage: ${response.body}');
    }
  }

  /// Delete a marriage
  Future<void> deleteMarriage(int id) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/marriages/$id'),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete marriage: ${response.statusCode}');
    }
  }

  /// Get marriages for a person
  Future<List<Marriage>> getMarriagesByPerson(int personId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/marriages/person/$personId'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final marriages = (data['data'] as List)
          .map((m) => Marriage.fromJson(m as Map<String, dynamic>))
          .toList();
      return marriages;
    } else {
      throw Exception('Failed to get marriages for person: ${response.statusCode}');
    }
  }
}