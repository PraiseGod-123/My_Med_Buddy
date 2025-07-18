// lib/models/health_tip_model.dart
import 'package:flutter/material.dart';
import 'dart:convert';

class HealthTipModel {
  final String id;
  final String title;
  final String content;
  final String shortDescription;
  final HealthTipCategory category;
  final HealthTipType type;
  final int priority;
  final List<String> tags;
  final String author;
  final String source;
  final DateTime publishedAt;
  final DateTime? updatedAt;
  final bool isFavorite;
  final bool isRead;
  final int readCount;
  final double rating;
  final String imageUrl;
  final String videoUrl;
  final List<String> references;
  final Map<String, dynamic> metadata;
  final Duration estimatedReadTime;
  final List<String> relatedTips;

  HealthTipModel({
    required this.id,
    required this.title,
    required this.content,
    required this.shortDescription,
    this.category = HealthTipCategory.general,
    this.type = HealthTipType.article,
    this.priority = 0,
    this.tags = const [],
    this.author = '',
    this.source = '',
    DateTime? publishedAt,
    this.updatedAt,
    this.isFavorite = false,
    this.isRead = false,
    this.readCount = 0,
    this.rating = 0.0,
    this.imageUrl = '',
    this.videoUrl = '',
    this.references = const [],
    this.metadata = const {},
    this.estimatedReadTime = const Duration(minutes: 3),
    this.relatedTips = const [],
  }) : publishedAt = publishedAt ?? DateTime.now();

  HealthTipModel copyWith({
    String? id,
    String? title,
    String? content,
    String? shortDescription,
    HealthTipCategory? category,
    HealthTipType? type,
    int? priority,
    List<String>? tags,
    String? author,
    String? source,
    DateTime? publishedAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? isRead,
    int? readCount,
    double? rating,
    String? imageUrl,
    String? videoUrl,
    List<String>? references,
    Map<String, dynamic>? metadata,
    Duration? estimatedReadTime,
    List<String>? relatedTips,
  }) {
    return HealthTipModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      shortDescription: shortDescription ?? this.shortDescription,
      category: category ?? this.category,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      source: source ?? this.source,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isRead: isRead ?? this.isRead,
      readCount: readCount ?? this.readCount,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      references: references ?? this.references,
      metadata: metadata ?? this.metadata,
      estimatedReadTime: estimatedReadTime ?? this.estimatedReadTime,
      relatedTips: relatedTips ?? this.relatedTips,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'shortDescription': shortDescription,
      'category': category.toString(),
      'type': type.toString(),
      'priority': priority,
      'tags': tags,
      'author': author,
      'source': source,
      'publishedAt': publishedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isFavorite': isFavorite,
      'isRead': isRead,
      'readCount': readCount,
      'rating': rating,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'references': references,
      'metadata': metadata,
      'estimatedReadTime': estimatedReadTime.inMinutes,
      'relatedTips': relatedTips,
    };
  }

  factory HealthTipModel.fromJson(Map<String, dynamic> json) {
    return HealthTipModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      category: HealthTipCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => HealthTipCategory.general,
      ),
      type: HealthTipType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => HealthTipType.article,
      ),
      priority: json['priority'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      author: json['author'] ?? '',
      source: json['source'] ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isFavorite: json['isFavorite'] ?? false,
      isRead: json['isRead'] ?? false,
      readCount: json['readCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      references: List<String>.from(json['references'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      estimatedReadTime: Duration(minutes: json['estimatedReadTime'] ?? 3),
      relatedTips: List<String>.from(json['relatedTips'] ?? []),
    );
  }

  // Factory constructor for API responses
  factory HealthTipModel.fromApiResponse(Map<String, dynamic> json) {
    // Handle different API response formats
    return HealthTipModel(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? json['headline'] ?? json['name'] ?? '',
      content: json['content'] ?? json['description'] ?? json['body'] ?? '',
      shortDescription:
          json['shortDescription'] ??
          json['summary'] ??
          json['excerpt'] ??
          _truncateContent(json['content'] ?? ''),
      category: _parseCategory(json['category'] ?? json['type'] ?? ''),
      type: _parseType(json['format'] ?? json['contentType'] ?? ''),
      priority: json['priority'] ?? 0,
      tags: _parseTags(json['tags'] ?? json['keywords'] ?? []),
      author: json['author'] ?? json['creator'] ?? json['source'] ?? '',
      source: json['source'] ?? json['provider'] ?? 'Health API',
      publishedAt: _parseDate(
        json['publishedAt'] ?? json['datePublished'] ?? json['created'],
      ),
      updatedAt: _parseDate(
        json['updatedAt'] ?? json['dateModified'] ?? json['updated'],
      ),
      imageUrl: json['imageUrl'] ?? json['image'] ?? json['thumbnail'] ?? '',
      videoUrl: json['videoUrl'] ?? json['video'] ?? '',
      references: _parseReferences(json['references'] ?? json['sources'] ?? []),
      rating: (json['rating'] ?? json['score'] ?? 0.0).toDouble(),
    );
  }

  // Helper methods for parsing API responses
  static String _truncateContent(String content, {int maxLength = 150}) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  static HealthTipCategory _parseCategory(String categoryString) {
    switch (categoryString.toLowerCase()) {
      case 'nutrition':
      case 'diet':
      case 'food':
        return HealthTipCategory.nutrition;
      case 'exercise':
      case 'fitness':
      case 'workout':
        return HealthTipCategory.exercise;
      case 'mental':
      case 'mental health':
      case 'psychology':
        return HealthTipCategory.mentalHealth;
      case 'medication':
      case 'medicine':
      case 'drugs':
        return HealthTipCategory.medication;
      case 'prevention':
      case 'preventive':
        return HealthTipCategory.prevention;
      case 'wellness':
      case 'lifestyle':
        return HealthTipCategory.wellness;
      case 'sleep':
      case 'rest':
        return HealthTipCategory.sleep;
      case 'hydration':
      case 'water':
        return HealthTipCategory.hydration;
      default:
        return HealthTipCategory.general;
    }
  }

  static HealthTipType _parseType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'video':
        return HealthTipType.video;
      case 'infographic':
      case 'image':
        return HealthTipType.infographic;
      case 'quick tip':
      case 'tip':
        return HealthTipType.quickTip;
      case 'checklist':
        return HealthTipType.checklist;
      case 'quiz':
        return HealthTipType.quiz;
      default:
        return HealthTipType.article;
    }
  }

  static List<String> _parseTags(dynamic tags) {
    if (tags is List) {
      return tags.map((tag) => tag.toString()).toList();
    } else if (tags is String) {
      return tags.split(',').map((tag) => tag.trim()).toList();
    }
    return [];
  }

  static List<String> _parseReferences(dynamic references) {
    if (references is List) {
      return references.map((ref) => ref.toString()).toList();
    }
    return [];
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // Helper getters
  bool get hasImage => imageUrl.isNotEmpty;
  bool get hasVideo => videoUrl.isNotEmpty;
  bool get hasReferences => references.isNotEmpty;
  bool get isRecent => DateTime.now().difference(publishedAt).inDays <= 7;
  bool get isPopular => rating >= 4.0 || readCount > 100;

  String get estimatedReadTimeText {
    final minutes = estimatedReadTime.inMinutes;
    if (minutes < 1) return 'Less than 1 min';
    if (minutes == 1) return '1 min';
    return '$minutes mins';
  }

  String get formattedPublishedDate {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = difference.inDays ~/ 365;
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  @override
  String toString() {
    return 'HealthTipModel(id: $id, title: $title, category: $category, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthTipModel &&
        other.id == id &&
        other.title == title &&
        other.content == content;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ content.hashCode;
  }
}

// Enums for categorization
enum HealthTipCategory {
  general,
  nutrition,
  exercise,
  mentalHealth,
  medication,
  prevention,
  wellness,
  sleep,
  hydration,
  firstAid,
  chronic,
  senior,
  pediatric,
  women,
  men,
}

enum HealthTipType {
  article,
  video,
  infographic,
  quickTip,
  checklist,
  quiz,
  interactive,
  news,
  research,
  personal,
}

// Extensions for better enum handling
extension HealthTipCategoryExtension on HealthTipCategory {
  String get displayName {
    switch (this) {
      case HealthTipCategory.general:
        return 'General Health';
      case HealthTipCategory.nutrition:
        return 'Nutrition';
      case HealthTipCategory.exercise:
        return 'Exercise & Fitness';
      case HealthTipCategory.mentalHealth:
        return 'Mental Health';
      case HealthTipCategory.medication:
        return 'Medication';
      case HealthTipCategory.prevention:
        return 'Prevention';
      case HealthTipCategory.wellness:
        return 'Wellness';
      case HealthTipCategory.sleep:
        return 'Sleep';
      case HealthTipCategory.hydration:
        return 'Hydration';
      case HealthTipCategory.firstAid:
        return 'First Aid';
      case HealthTipCategory.chronic:
        return 'Chronic Conditions';
      case HealthTipCategory.senior:
        return 'Senior Health';
      case HealthTipCategory.pediatric:
        return 'Pediatric Health';
      case HealthTipCategory.women:
        return 'Women\'s Health';
      case HealthTipCategory.men:
        return 'Men\'s Health';
    }
  }

  IconData get icon {
    switch (this) {
      case HealthTipCategory.general:
        return Icons.health_and_safety;
      case HealthTipCategory.nutrition:
        return Icons.restaurant;
      case HealthTipCategory.exercise:
        return Icons.fitness_center;
      case HealthTipCategory.mentalHealth:
        return Icons.psychology;
      case HealthTipCategory.medication:
        return Icons.medication;
      case HealthTipCategory.prevention:
        return Icons.shield;
      case HealthTipCategory.wellness:
        return Icons.spa;
      case HealthTipCategory.sleep:
        return Icons.bedtime;
      case HealthTipCategory.hydration:
        return Icons.water_drop;
      case HealthTipCategory.firstAid:
        return Icons.medical_services;
      case HealthTipCategory.chronic:
        return Icons.monitor_heart;
      case HealthTipCategory.senior:
        return Icons.elderly;
      case HealthTipCategory.pediatric:
        return Icons.child_care;
      case HealthTipCategory.women:
        return Icons.woman;
      case HealthTipCategory.men:
        return Icons.man;
    }
  }

  Color get color {
    switch (this) {
      case HealthTipCategory.general:
        return Colors.blue;
      case HealthTipCategory.nutrition:
        return Colors.green;
      case HealthTipCategory.exercise:
        return Colors.orange;
      case HealthTipCategory.mentalHealth:
        return Colors.purple;
      case HealthTipCategory.medication:
        return Colors.red;
      case HealthTipCategory.prevention:
        return Colors.teal;
      case HealthTipCategory.wellness:
        return Colors.pink;
      case HealthTipCategory.sleep:
        return Colors.indigo;
      case HealthTipCategory.hydration:
        return Colors.cyan;
      case HealthTipCategory.firstAid:
        return Colors.red;
      case HealthTipCategory.chronic:
        return Colors.amber;
      case HealthTipCategory.senior:
        return Colors.brown;
      case HealthTipCategory.pediatric:
        return Colors.lightGreen;
      case HealthTipCategory.women:
        return Colors.pinkAccent;
      case HealthTipCategory.men:
        return Colors.blueAccent;
    }
  }
}

extension HealthTipTypeExtension on HealthTipType {
  String get displayName {
    switch (this) {
      case HealthTipType.article:
        return 'Article';
      case HealthTipType.video:
        return 'Video';
      case HealthTipType.infographic:
        return 'Infographic';
      case HealthTipType.quickTip:
        return 'Quick Tip';
      case HealthTipType.checklist:
        return 'Checklist';
      case HealthTipType.quiz:
        return 'Quiz';
      case HealthTipType.interactive:
        return 'Interactive';
      case HealthTipType.news:
        return 'News';
      case HealthTipType.research:
        return 'Research';
      case HealthTipType.personal:
        return 'Personal';
    }
  }

  IconData get icon {
    switch (this) {
      case HealthTipType.article:
        return Icons.article;
      case HealthTipType.video:
        return Icons.play_circle;
      case HealthTipType.infographic:
        return Icons.image;
      case HealthTipType.quickTip:
        return Icons.lightbulb;
      case HealthTipType.checklist:
        return Icons.checklist;
      case HealthTipType.quiz:
        return Icons.quiz;
      case HealthTipType.interactive:
        return Icons.touch_app;
      case HealthTipType.news:
        return Icons.newspaper;
      case HealthTipType.research:
        return Icons.science;
      case HealthTipType.personal:
        return Icons.person;
    }
  }
}

// API Response models
class HealthTipResponse {
  final List<HealthTipModel> tips;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final String? nextPageUrl;
  final String? previousPageUrl;

  HealthTipResponse({
    required this.tips,
    required this.totalCount,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
    this.nextPageUrl,
    this.previousPageUrl,
  });

  factory HealthTipResponse.fromJson(Map<String, dynamic> json) {
    return HealthTipResponse(
      tips:
          (json['data'] as List?)
              ?.map((tip) => HealthTipModel.fromApiResponse(tip))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      nextPageUrl: json['nextPageUrl'],
      previousPageUrl: json['previousPageUrl'],
    );
  }
}

// Utility class for health tip operations
class HealthTipUtils {
  static List<HealthTipModel> sortByPriority(List<HealthTipModel> tips) {
    final sorted = List<HealthTipModel>.from(tips);
    sorted.sort((a, b) => b.priority.compareTo(a.priority));
    return sorted;
  }

  static List<HealthTipModel> sortByDate(List<HealthTipModel> tips) {
    final sorted = List<HealthTipModel>.from(tips);
    sorted.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return sorted;
  }

  static List<HealthTipModel> sortByRating(List<HealthTipModel> tips) {
    final sorted = List<HealthTipModel>.from(tips);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted;
  }

  static List<HealthTipModel> filterByCategory(
    List<HealthTipModel> tips,
    HealthTipCategory category,
  ) {
    return tips.where((tip) => tip.category == category).toList();
  }

  static List<HealthTipModel> filterByType(
    List<HealthTipModel> tips,
    HealthTipType type,
  ) {
    return tips.where((tip) => tip.type == type).toList();
  }

  static List<HealthTipModel> filterByTags(
    List<HealthTipModel> tips,
    List<String> tags,
  ) {
    return tips.where((tip) {
      return tags.any((tag) => tip.tags.contains(tag));
    }).toList();
  }

  static List<HealthTipModel> searchTips(
    List<HealthTipModel> tips,
    String query,
  ) {
    final lowercaseQuery = query.toLowerCase();
    return tips.where((tip) {
      return tip.title.toLowerCase().contains(lowercaseQuery) ||
          tip.content.toLowerCase().contains(lowercaseQuery) ||
          tip.shortDescription.toLowerCase().contains(lowercaseQuery) ||
          tip.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  static List<HealthTipModel> getFavorites(List<HealthTipModel> tips) {
    return tips.where((tip) => tip.isFavorite).toList();
  }

  static List<HealthTipModel> getUnread(List<HealthTipModel> tips) {
    return tips.where((tip) => !tip.isRead).toList();
  }

  static List<HealthTipModel> getRecentTips(
    List<HealthTipModel> tips, {
    int days = 7,
  }) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return tips.where((tip) => tip.publishedAt.isAfter(cutoffDate)).toList();
  }

  static Map<HealthTipCategory, List<HealthTipModel>> groupByCategory(
    List<HealthTipModel> tips,
  ) {
    final Map<HealthTipCategory, List<HealthTipModel>> grouped = {};

    for (final tip in tips) {
      if (!grouped.containsKey(tip.category)) {
        grouped[tip.category] = [];
      }
      grouped[tip.category]!.add(tip);
    }

    return grouped;
  }

  static List<HealthTipModel> getRecommendedTips(
    List<HealthTipModel> tips,
    List<String> userInterests,
    List<HealthTipCategory> preferredCategories,
  ) {
    return tips.where((tip) {
      // Check if tip matches user interests
      final matchesInterests =
          userInterests.isEmpty ||
          tip.tags.any((tag) => userInterests.contains(tag));

      // Check if tip matches preferred categories
      final matchesCategories =
          preferredCategories.isEmpty ||
          preferredCategories.contains(tip.category);

      return matchesInterests && matchesCategories;
    }).toList();
  }

  // Generate sample health tips for testing
  static List<HealthTipModel> generateSampleTips() {
    return [
      HealthTipModel(
        id: '1',
        title: 'Stay Hydrated for Better Health',
        content:
            'Drinking adequate water is essential for maintaining good health. Aim for at least 8 glasses of water per day to keep your body functioning optimally.',
        shortDescription:
            'Learn about the importance of proper hydration for your daily health.',
        category: HealthTipCategory.hydration,
        type: HealthTipType.quickTip,
        priority: 5,
        tags: ['hydration', 'water', 'health', 'daily'],
        author: 'Health Team',
        source: 'MyMedBuddy',
        rating: 4.5,
        estimatedReadTime: const Duration(minutes: 2),
      ),
      HealthTipModel(
        id: '2',
        title: 'The Importance of Regular Exercise',
        content:
            'Regular physical activity is crucial for maintaining good health. Even 30 minutes of moderate exercise daily can significantly improve your cardiovascular health, mood, and overall well-being.',
        shortDescription:
            'Discover how regular exercise can transform your health and well-being.',
        category: HealthTipCategory.exercise,
        type: HealthTipType.article,
        priority: 4,
        tags: ['exercise', 'fitness', 'cardio', 'health'],
        author: 'Fitness Expert',
        source: 'MyMedBuddy',
        rating: 4.8,
        estimatedReadTime: const Duration(minutes: 5),
      ),
      HealthTipModel(
        id: '3',
        title: 'Mental Health Self-Care Tips',
        content:
            'Taking care of your mental health is just as important as physical health. Practice mindfulness, maintain social connections, and don\'t hesitate to seek professional help when needed.',
        shortDescription:
            'Essential tips for maintaining and improving your mental health.',
        category: HealthTipCategory.mentalHealth,
        type: HealthTipType.article,
        priority: 5,
        tags: ['mental health', 'self-care', 'mindfulness', 'wellness'],
        author: 'Mental Health Specialist',
        source: 'MyMedBuddy',
        rating: 4.9,
        estimatedReadTime: const Duration(minutes: 4),
      ),
      HealthTipModel(
        id: '4',
        title: 'Medication Safety Guidelines',
        content:
            'Always take medications as prescribed by your healthcare provider. Store them properly, check expiration dates, and never share prescription medications with others.',
        shortDescription:
            'Important guidelines for safe medication use and storage.',
        category: HealthTipCategory.medication,
        type: HealthTipType.checklist,
        priority: 5,
        tags: ['medication', 'safety', 'prescription', 'health'],
        author: 'Pharmacist',
        source: 'MyMedBuddy',
        rating: 4.7,
        estimatedReadTime: const Duration(minutes: 3),
      ),
      HealthTipModel(
        id: '5',
        title: 'Getting Quality Sleep',
        content:
            'Good sleep is essential for physical and mental health. Aim for 7-9 hours of quality sleep each night. Create a relaxing bedtime routine and maintain a consistent sleep schedule.',
        shortDescription:
            'Tips for improving your sleep quality and establishing healthy sleep habits.',
        category: HealthTipCategory.sleep,
        type: HealthTipType.article,
        priority: 4,
        tags: ['sleep', 'rest', 'health', 'routine'],
        author: 'Sleep Specialist',
        source: 'MyMedBuddy',
        rating: 4.6,
        estimatedReadTime: const Duration(minutes: 4),
      ),
    ];
  }
}
