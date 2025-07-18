// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://api.fda.gov/drug';
  static const String _healthTipsUrl =
      'https://health-tips-api.herokuapp.com/api';
  static const Duration _timeout = Duration(seconds: 30);

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP client with custom configuration
  late final http.Client _client;

  void initialize() {
    _client = http.Client();
  }

  void dispose() {
    _client.close();
  }

  // Generic GET request
  Future<Map<String, dynamic>> _get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...?headers,
            },
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('HTTP error occurred');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> _post(
    String url,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...?headers,
            },
            body: jsonEncode(data),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('HTTP error occurred');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> _put(
    String url,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...?headers,
            },
            body: jsonEncode(data),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('HTTP error occurred');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> _delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              ...?headers,
            },
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('HTTP error occurred');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // Handle HTTP responses
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        // Handle plain text responses
        return {'data': response.body, 'message': 'Success'};
      }
    } else {
      String errorMessage;
      try {
        final errorData = jsonDecode(response.body);
        errorMessage =
            errorData['message'] ?? errorData['error'] ?? 'Unknown error';
      } catch (e) {
        errorMessage = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
      }

      throw ApiException(errorMessage, statusCode: statusCode);
    }
  }

  // Search for drug information
  Future<List<DrugInfo>> searchDrugInfo(String drugName) async {
    if (drugName.isEmpty) {
      throw ApiException('Drug name cannot be empty');
    }

    try {
      final encodedName = Uri.encodeComponent(drugName);
      final url =
          '$_baseUrl/label.json?search=openfda.brand_name:"$encodedName"&limit=10';

      final response = await _get(url);

      if (response['results'] != null) {
        final List<dynamic> results = response['results'];
        return results.map((data) => DrugInfo.fromJson(data)).toList();
      }

      return [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to search drug information: ${e.toString()}');
    }
  }

  // Get drug interactions
  Future<List<DrugInteraction>> getDrugInteractions(String drugName) async {
    if (drugName.isEmpty) {
      throw ApiException('Drug name cannot be empty');
    }

    try {
      final encodedName = Uri.encodeComponent(drugName);
      final url =
          '$_baseUrl/event.json?search=patient.drug.medicinalproduct:"$encodedName"&limit=5';

      final response = await _get(url);

      if (response['results'] != null) {
        final List<dynamic> results = response['results'];
        return results.map((data) => DrugInteraction.fromJson(data)).toList();
      }

      return [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get drug interactions: ${e.toString()}');
    }
  }

  // Get health tips
  Future<List<HealthTipModel>> getHealthTips({
    String? category,
    int limit = 10,
  }) async {
    try {
      String url = '$_healthTipsUrl/tips?limit=$limit';
      if (category != null && category.isNotEmpty) {
        url += '&category=${Uri.encodeComponent(category)}';
      }

      final response = await _get(url);

      if (response['data'] != null) {
        final List<dynamic> tips = response['data'];
        return tips.map((data) => HealthTipModel.fromJson(data)).toList();
      }

      // Fallback to mock data if API is not available
      return _getMockHealthTips(category: category, limit: limit);
    } catch (e) {
      // Return mock data if API fails
      return _getMockHealthTips(category: category, limit: limit);
    }
  }

  // Get daily health tip
  Future<HealthTipModel> getDailyHealthTip() async {
    try {
      final url = '$_healthTipsUrl/tips/daily';
      final response = await _get(url);

      if (response['data'] != null) {
        return HealthTipModel.fromJson(response['data']);
      }

      // Fallback to mock data
      return _getMockHealthTips(limit: 1).first;
    } catch (e) {
      // Return mock data if API fails
      return _getMockHealthTips(limit: 1).first;
    }
  }

  // Search medications by name
  Future<List<MedicationInfo>> searchMedications(String query) async {
    if (query.isEmpty) {
      throw ApiException('Search query cannot be empty');
    }

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url =
          '$_baseUrl/label.json?search=openfda.brand_name:"$encodedQuery"+openfda.generic_name:"$encodedQuery"&limit=20';

      final response = await _get(url);

      if (response['results'] != null) {
        final List<dynamic> results = response['results'];
        return results.map((data) => MedicationInfo.fromJson(data)).toList();
      }

      return [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to search medications: ${e.toString()}');
    }
  }

  // Get medication details
  Future<MedicationDetails> getMedicationDetails(String medicationId) async {
    if (medicationId.isEmpty) {
      throw ApiException('Medication ID cannot be empty');
    }

    try {
      final encodedId = Uri.encodeComponent(medicationId);
      final url = '$_baseUrl/label.json?search=set_id:"$encodedId"';

      final response = await _get(url);

      if (response['results'] != null && response['results'].isNotEmpty) {
        return MedicationDetails.fromJson(response['results'][0]);
      }

      throw ApiException('Medication not found');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get medication details: ${e.toString()}');
    }
  }

  // Check drug recalls
  Future<List<DrugRecall>> checkDrugRecalls(String drugName) async {
    if (drugName.isEmpty) {
      throw ApiException('Drug name cannot be empty');
    }

    try {
      final encodedName = Uri.encodeComponent(drugName);
      final url =
          '$_baseUrl/enforcement.json?search=product_description:"$encodedName"&limit=10';

      final response = await _get(url);

      if (response['results'] != null) {
        final List<dynamic> results = response['results'];
        return results.map((data) => DrugRecall.fromJson(data)).toList();
      }

      return [];
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to check drug recalls: ${e.toString()}');
    }
  }

  // Verify medication dosage
  Future<DosageInfo> verifyDosage(String medicationName, String dosage) async {
    if (medicationName.isEmpty || dosage.isEmpty) {
      throw ApiException('Medication name and dosage cannot be empty');
    }

    try {
      final encodedName = Uri.encodeComponent(medicationName);
      final url =
          '$_baseUrl/label.json?search=openfda.brand_name:"$encodedName"&limit=1';

      final response = await _get(url);

      if (response['results'] != null && response['results'].isNotEmpty) {
        return DosageInfo.fromJson(response['results'][0], dosage);
      }

      throw ApiException('Medication not found for dosage verification');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to verify dosage: ${e.toString()}');
    }
  }

  // Get health news
  Future<List<HealthNewsModel>> getHealthNews({int limit = 10}) async {
    try {
      // Mock implementation - replace with actual health news API
      return _getMockHealthNews(limit: limit);
    } catch (e) {
      throw ApiException('Failed to get health news: ${e.toString()}');
    }
  }

  // Mock data methods for fallback
  List<HealthTipModel> _getMockHealthTips({String? category, int limit = 10}) {
    final allTips = [
      HealthTipModel(
        id: '1',
        title: 'Stay Hydrated',
        content:
            'Drink at least 8 glasses of water daily to maintain proper hydration and support your body\'s functions.',
        category: 'general',
        imageUrl: null,
        createdAt: DateTime.now(),
      ),
      HealthTipModel(
        id: '2',
        title: 'Take Medications on Time',
        content:
            'Set reminders to take your medications at the same time every day for maximum effectiveness.',
        category: 'medication',
        imageUrl: null,
        createdAt: DateTime.now(),
      ),
      HealthTipModel(
        id: '3',
        title: 'Regular Exercise',
        content:
            'Aim for at least 30 minutes of moderate exercise most days of the week to improve your overall health.',
        category: 'exercise',
        imageUrl: null,
        createdAt: DateTime.now(),
      ),
      HealthTipModel(
        id: '4',
        title: 'Healthy Sleep Schedule',
        content:
            'Maintain a consistent sleep schedule by going to bed and waking up at the same time every day.',
        category: 'sleep',
        imageUrl: null,
        createdAt: DateTime.now(),
      ),
      HealthTipModel(
        id: '5',
        title: 'Balanced Diet',
        content:
            'Eat a variety of fruits, vegetables, whole grains, and lean proteins for optimal nutrition.',
        category: 'nutrition',
        imageUrl: null,
        createdAt: DateTime.now(),
      ),
    ];

    var filtered = allTips;
    if (category != null && category.isNotEmpty) {
      filtered = allTips.where((tip) => tip.category == category).toList();
    }

    return filtered.take(limit).toList();
  }

  List<HealthNewsModel> _getMockHealthNews({int limit = 10}) {
    final news = [
      HealthNewsModel(
        id: '1',
        title: 'New Study Shows Benefits of Regular Exercise',
        summary:
            'Recent research demonstrates the positive impact of consistent physical activity on mental health.',
        url: 'https://example.com/news/1',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        source: 'Health Journal',
      ),
      HealthNewsModel(
        id: '2',
        title: 'Importance of Medication Adherence',
        summary:
            'Healthcare professionals emphasize the critical role of taking medications as prescribed.',
        url: 'https://example.com/news/2',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        source: 'Medical News',
      ),
    ];

    return news.take(limit).toList();
  }

  // Network connectivity check
  Future<bool> checkConnectivity() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// Custom exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}

// Data models for API responses
class DrugInfo {
  final String id;
  final String name;
  final String? genericName;
  final String? manufacturer;
  final List<String> activeIngredients;
  final String? description;
  final List<String> warnings;

  DrugInfo({
    required this.id,
    required this.name,
    this.genericName,
    this.manufacturer,
    required this.activeIngredients,
    this.description,
    required this.warnings,
  });

  factory DrugInfo.fromJson(Map<String, dynamic> json) {
    return DrugInfo(
      id: json['id'] ?? '',
      name: json['openfda']?['brand_name']?.first ?? '',
      genericName: json['openfda']?['generic_name']?.first,
      manufacturer: json['openfda']?['manufacturer_name']?.first,
      activeIngredients: List<String>.from(json['active_ingredient'] ?? []),
      description: json['description']?.first,
      warnings: List<String>.from(json['warnings'] ?? []),
    );
  }
}

class DrugInteraction {
  final String drugName;
  final String interactionType;
  final String description;
  final String severity;

  DrugInteraction({
    required this.drugName,
    required this.interactionType,
    required this.description,
    required this.severity,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) {
    return DrugInteraction(
      drugName: json['patient']?['drug']?.first?['medicinalproduct'] ?? '',
      interactionType: json['reaction']?.first?['reactionmeddrapt'] ?? '',
      description: json['narrativeincludeclinical'] ?? '',
      severity: json['serious'] == '1' ? 'Serious' : 'Mild',
    );
  }
}

class MedicationInfo {
  final String id;
  final String name;
  final String? genericName;
  final String? manufacturer;
  final String? dosageForm;
  final String? strength;

  MedicationInfo({
    required this.id,
    required this.name,
    this.genericName,
    this.manufacturer,
    this.dosageForm,
    this.strength,
  });

  factory MedicationInfo.fromJson(Map<String, dynamic> json) {
    return MedicationInfo(
      id: json['set_id'] ?? '',
      name: json['openfda']?['brand_name']?.first ?? '',
      genericName: json['openfda']?['generic_name']?.first,
      manufacturer: json['openfda']?['manufacturer_name']?.first,
      dosageForm: json['dosage_form']?.first,
      strength: json['openfda']?['strength']?.first,
    );
  }
}

class MedicationDetails {
  final String id;
  final String name;
  final String? genericName;
  final String? manufacturer;
  final String? dosageForm;
  final String? strength;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final String? dosageInstructions;

  MedicationDetails({
    required this.id,
    required this.name,
    this.genericName,
    this.manufacturer,
    this.dosageForm,
    this.strength,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    this.dosageInstructions,
  });

  factory MedicationDetails.fromJson(Map<String, dynamic> json) {
    return MedicationDetails(
      id: json['set_id'] ?? '',
      name: json['openfda']?['brand_name']?.first ?? '',
      genericName: json['openfda']?['generic_name']?.first,
      manufacturer: json['openfda']?['manufacturer_name']?.first,
      dosageForm: json['dosage_form']?.first,
      strength: json['openfda']?['strength']?.first,
      indications: List<String>.from(json['indications_and_usage'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      sideEffects: List<String>.from(json['adverse_reactions'] ?? []),
      dosageInstructions: json['dosage_and_administration']?.first,
    );
  }
}

class DrugRecall {
  final String id;
  final String productDescription;
  final String reason;
  final String classification;
  final DateTime recallDate;
  final String status;

  DrugRecall({
    required this.id,
    required this.productDescription,
    required this.reason,
    required this.classification,
    required this.recallDate,
    required this.status,
  });

  factory DrugRecall.fromJson(Map<String, dynamic> json) {
    return DrugRecall(
      id: json['recall_number'] ?? '',
      productDescription: json['product_description'] ?? '',
      reason: json['reason_for_recall'] ?? '',
      classification: json['classification'] ?? '',
      recallDate:
          DateTime.tryParse(json['recall_initiation_date'] ?? '') ??
          DateTime.now(),
      status: json['status'] ?? '',
    );
  }
}

class DosageInfo {
  final String medicationName;
  final String providedDosage;
  final String recommendedDosage;
  final bool isValid;
  final String? warning;

  DosageInfo({
    required this.medicationName,
    required this.providedDosage,
    required this.recommendedDosage,
    required this.isValid,
    this.warning,
  });

  factory DosageInfo.fromJson(Map<String, dynamic> json, String dosage) {
    final recommendedDosage = json['dosage_and_administration']?.first ?? '';
    return DosageInfo(
      medicationName: json['openfda']?['brand_name']?.first ?? '',
      providedDosage: dosage,
      recommendedDosage: recommendedDosage,
      isValid: true, // This would require more complex validation logic
      warning: null,
    );
  }
}

class HealthNewsModel {
  final String id;
  final String title;
  final String summary;
  final String url;
  final DateTime publishedAt;
  final String source;

  HealthNewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.url,
    required this.publishedAt,
    required this.source,
  });

  factory HealthNewsModel.fromJson(Map<String, dynamic> json) {
    return HealthNewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      url: json['url'] ?? '',
      publishedAt:
          DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
      source: json['source'] ?? '',
    );
  }
}

class HealthTipModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final DateTime createdAt;

  HealthTipModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    required this.createdAt,
  });

  factory HealthTipModel.fromJson(Map<String, dynamic> json) {
    return HealthTipModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'general',
      imageUrl: json['image_url'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
