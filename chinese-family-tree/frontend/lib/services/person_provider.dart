import 'package:flutter/foundation.dart';
import '../models/person.dart';
import '../models/marriage.dart';
import 'api_service.dart';

class PersonProvider with ChangeNotifier {
  final ApiService _apiService;
  
  List<Person> _persons = [];
  List<Marriage> _marriages = [];
  Person? _selectedPerson;
  bool _isLoading = false;
  String? _error;

  PersonProvider(this._apiService);

  // Getters
  List<Person> get persons => _persons;
  Person? get selectedPerson => _selectedPerson;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all persons from API
  Future<void> loadPersons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _persons = await _apiService.getPersons();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a single person by ID
  Future<Person?> getPerson(int id) async {
    try {
      final person = await _apiService.getPerson(id);
      return person;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Create a new person
  Future<bool> createPerson(Person person) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await _apiService.createPerson(person);
      _persons.add(created);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing person
  Future<bool> updatePerson(Person person) async {
    if (person.id == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _apiService.updatePerson(person.id!, person);
      final index = _persons.indexWhere((p) => p.id == person.id);
      if (index != -1) {
        _persons[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a person
  Future<bool> deletePerson(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deletePerson(id);
      _persons.removeWhere((p) => p.id == id);
      if (_selectedPerson?.id == id) {
        _selectedPerson = null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Search persons
  Future<List<Person>> searchPersons(String query) async {
    if (query.isEmpty) return _persons;
    
    try {
      return await _apiService.searchPersons(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Get persons by generation name
  Future<List<Person>> getByGenerationName(String generationName) async {
    try {
      return await _apiService.getByGenerationName(generationName);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Get persons by family name
  Future<List<Person>> getByFamilyName(String familyName) async {
    try {
      return await _apiService.getByFamilyName(familyName);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Set selected person
  void setSelectedPerson(Person? person) {
    _selectedPerson = person;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Filter persons by family name locally
  List<Person> filterByFamilyName(String familyName) {
    return _persons.where((p) => p.familyName == familyName).toList();
  }

  /// Filter persons by generation name locally
  List<Person> filterByGeneration(String? generationName) {
    if (generationName == null || generationName.isEmpty) {
      return _persons;
    }
    return _persons.where((p) => p.generationName == generationName).toList();
  }

  /// Get all unique family names
  List<String> getFamilyNames() {
    final names = _persons.map((p) => p.familyName).toSet().toList();
    names.sort();
    return names;
  }

  /// Get all unique generation names
  List<String> getGenerationNames() {
    final names = _persons
        .map((p) => p.generationName)
        .where((n) => n != null && n.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    names.sort();
    return names;
  }

  // ========== Marriage Methods ==========

  /// Load all marriages from API
  Future<void> loadMarriages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _marriages = await _apiService.getMarriages();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get all marriages
  List<Marriage> get marriages => _marriages;

  /// Create a new marriage
  Future<bool> createMarriage(Marriage marriage) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await _apiService.createMarriage(marriage);
      _marriages.add(created);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a marriage
  Future<bool> deleteMarriage(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.deleteMarriage(id);
      _marriages.removeWhere((m) => m.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get marriages for a person
  List<Marriage> getMarriagesForPerson(int personId) {
    return _marriages.where((m) => m.husbandId == personId || m.wifeId == personId).toList();
  }

  /// Get spouse IDs for a person
  List<int> getSpouseIds(int personId) {
    final marriages = getMarriagesForPerson(personId);
    return marriages.map((m) => m.husbandId == personId ? m.wifeId : m.husbandId).toList();
  }

  /// Get spouse details for a person
  List<Person> getSpousesForPerson(int personId) {
    final spouseIds = getSpouseIds(personId);
    return _persons.where((p) => spouseIds.contains(p.id)).toList();
  }
}
