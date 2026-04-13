import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/person.dart';
import '../models/marriage.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({this.baseUrl = '', http.Client? client})
      : _client = client ?? http.Client();

  // ========== Persons ==========

  /// Get all persons
  Future<List<Person>> getPersons() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/persons'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final persons = (data['data'] as List)
          .map((p) => Person.fromJson(p as Map<String, dynamic>))
          .toList();
      return persons;
    } else {
      throw ApiException('Failed to get persons: ${response.statusCode}');
    }
  }

  /// Get person by ID
  Future<Person> getPerson(int id) async {
    final response = await _client.get(Uri.parse('$baseUrl/api/persons/$id'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Person.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw ApiException('Failed to get person: ${response.statusCode}');
    }
  }

  /// Create a new person
  Future<Person> createPerson(Person person) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/persons'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(person.toJson()),
    );
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Person.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw ApiException('Failed to create person: ${response.body}');
    }
  }

  /// Update a person
  Future<Person> updatePerson(int id, Person person) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/api/persons/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(person.toJson()),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Person.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw ApiException('Failed to update person: ${response.body}');
    }
  }

  /// Delete a person
  Future<void> deletePerson(int id) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/persons/$id'),
    );
    
    if (response.statusCode != 200) {
      throw ApiException('Failed to delete person: ${response.statusCode}');
    }
  }

  /// Search persons
  Future<List<Person>> searchPersons(String query) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/persons/search?q=$query'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final persons = (data['data'] as List)
          .map((p) => Person.fromJson(p as Map<String, dynamic>))
          .toList();
      return persons;
    } else {
      throw ApiException('Failed to search persons: ${response.statusCode}');
    }
  }

  /// Get persons by generation name
  Future<List<Person>> getByGenerationName(String generationName) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/persons/generation/$generationName'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final persons = (data['data'] as List)
          .map((p) => Person.fromJson(p as Map<String, dynamic>))
          .toList();
      return persons;
    } else {
      throw ApiException('Failed to get persons by generation: ${response.statusCode}');
    }
  }

  /// Get persons by family name
  Future<List<Person>> getByFamilyName(String familyName) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/persons/family/$familyName'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final persons = (data['data'] as List)
          .map((p) => Person.fromJson(p as Map<String, dynamic>))
          .toList();
      return persons;
    } else {
      throw ApiException('Failed to get persons by family name: ${response.statusCode}');
    }
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ========== Marriages ==========  

  /// Get all marriages
  Future<List<Marriage>> getMarriages() async {
    final response = await _client.get(Uri.parse('\$baseUrl/api/marriages'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final marriages = (data['data'] as List)
          .map((m) => Marriage.fromJson(m as Map<String, dynamic>))
          .toList();
      return marriages;
    } else {
      throw ApiException('Failed to get marriages: \${response.statusCode}');
    }
  }

  /// Get marriage by ID
  Future<Marriage> getMarriage(int id) async {
    final response = await _client.get(Uri.parse('\$baseUrl/api/marriages/\$id'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Marriage.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw ApiException('Failed to get marriage: \${response.statusCode}');
    }
  }

  /// Create a new marriage
  Future<Marriage> createMarriage(Marriage marriage) async {
    final response = await _client.post(
      Uri.parse('\$baseUrl/api/marriages'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(marriage.toJson()),
    );
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Marriage.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw ApiException('Failed to create marriage: \${response.body}');
    }
  }

  /// Update a marriage
  Future<Marriage> updateMarriage(int id, Marriage marriage) async {
    final response = await _client.put(
      Uri.parse('\$baseUrl/api/marriages/\$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(marriage.toJson()),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Marriage.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw ApiException('Failed to update marriage: \${response.body}');
    }
  }

  /// Delete a marriage
  Future<void> deleteMarriage(int id) async {
    final response = await _client.delete(
      Uri.parse('\$baseUrl/api/marriages/\$id'),
    );
    
    if (response.statusCode != 200) {
      throw ApiException('Failed to delete marriage: \${response.statusCode}');
    }
  }

  /// Get marriages for a person
  Future<List<Marriage>> getMarriagesByPerson(int personId) async {
    final response = await _client.get(
      Uri.parse('\$baseUrl/api/marriages/person/\$personId'),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final marriages = (data['data'] as List)
          .map((m) => Marriage.fromJson(m as Map<String, dynamic>))
          .toList();
      return marriages;
    } else {
      throw ApiException('Failed to get marriages for person: \${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: \$message';
}
