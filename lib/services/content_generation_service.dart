import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/learning_models.dart';

class ContentGenerationService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
  
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<List<LearningModule>> generateLearningModules({
    int count = 10,
    LearningCategory? category,
  }) async {
    if (_apiKey.isEmpty) {
      if (kDebugMode) {
        print('Gemini API key not found');
      }
      return _getFallbackModules();
    }

    try {
      final prompt = _buildPrompt(count, category);
      final response = await _makeGeminiRequest(prompt);
      
      if (response != null) {
        return _parseModulesFromResponse(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating content with Gemini: $e');
      }
    }
    
    return _getFallbackModules();
  }

  String _buildPrompt(int count, LearningCategory? category) {
    final categoryFilter = category != null 
        ? 'focused on ${_getCategoryDescription(category)}' 
        : 'covering various mental health topics';

    return '''
Generate exactly $count mental health learning modules $categoryFilter. 
Each module should be educational, evidence-based, and suitable for self-help.

Return ONLY a valid JSON array with this exact structure:
[
  {
    "title": "Module title (concise and descriptive)",
    "description": "2-3 sentence description of what users will learn",
    "category": "${category?.toString().split('.').last ?? 'general'}",
    "type": "article",
    "difficulty": "beginner|intermediate|advanced",
    "estimatedMinutes": 15-45,
    "tags": ["tag1", "tag2", "tag3"],
    "authorName": "MindCare Team",
    "content": [
      {
        "title": "Section 1 title",
        "content": "Detailed educational content (200-400 words)",
        "type": "article",
        "order": 1
      },
      {
        "title": "Section 2 title", 
        "content": "More detailed content with practical tips",
        "type": "article",
        "order": 2
      }
    ]
  }
]

Categories available: cbt, dbt, mindfulness, anxiety, depression, stress, selfCare, relationships, sleep, general
Content types: article, video, audio, exercise, worksheet, quiz
Difficulties: beginner, intermediate, advanced

Focus on practical, actionable content that helps with mental wellness.
''';
  }

  String _getCategoryDescription(LearningCategory category) {
    switch (category) {
      case LearningCategory.cbt:
        return 'Cognitive Behavioral Therapy techniques and exercises';
      case LearningCategory.dbt:
        return 'Dialectical Behavior Therapy skills and practices';
      case LearningCategory.mindfulness:
        return 'mindfulness meditation and awareness practices';
      case LearningCategory.anxiety:
        return 'anxiety management strategies and coping techniques';
      case LearningCategory.depression:
        return 'depression support and mood improvement strategies';
      case LearningCategory.stress:
        return 'stress management and relaxation techniques';
      case LearningCategory.selfCare:
        return 'self-care practices and wellness routines';
      case LearningCategory.relationships:
        return 'relationship skills and communication techniques';
      case LearningCategory.sleep:
        return 'sleep hygiene and better sleep practices';
      case LearningCategory.general:
        return 'general mental health and wellness topics';
    }
  }

  Future<String?> _makeGeminiRequest(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 4000,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text?.toString();
      } else {
        if (kDebugMode) {
          print('Gemini API error: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Network error calling Gemini: $e');
      }
    }
    return null;
  }

  List<LearningModule> _parseModulesFromResponse(String response) {
    try {
      // Clean the response to extract JSON
      String jsonText = response.trim();
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      jsonText = jsonText.trim();

      final List<dynamic> jsonData = jsonDecode(jsonText);
      final List<LearningModule> modules = [];

      for (final item in jsonData) {
        try {
          final module = _createModuleFromJson(item);
          modules.add(module);
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing individual module: $e');
          }
        }
      }

      return modules;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing Gemini response: $e');
        print('Response was: $response');
      }
      return _getFallbackModules();
    }
  }

  LearningModule _createModuleFromJson(Map<String, dynamic> json) {
    // Parse content array
    final List<LearningContent> content = [];
    if (json['content'] is List) {
      for (final contentItem in json['content']) {
        content.add(LearningContent(
          title: contentItem['title'] ?? 'Untitled',
          content: contentItem['content'] ?? '',
          type: ContentType.values.firstWhere(
            (e) => e.toString().split('.').last == contentItem['type'],
            orElse: () => ContentType.article,
          ),
          order: contentItem['order'] ?? content.length + 1,
        ));
      }
    }

    return LearningModule(
      title: json['title'] ?? 'Untitled Module',
      description: json['description'] ?? '',
      category: LearningCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => LearningCategory.general,
      ),
      type: ContentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ContentType.article,
      ),
      difficulty: Difficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
        orElse: () => Difficulty.beginner,
      ),
      estimatedMinutes: json['estimatedMinutes'] ?? 20,
      tags: List<String>.from(json['tags'] ?? []),
      rating: 4.0 + Random().nextDouble() * 1.0, // Random rating 4.0-5.0
      ratingCount: Random().nextInt(100) + 10, // Random rating count
      authorId: 'mindcare_team',
      authorName: json['authorName'] ?? 'MindCare Team',
      content: content,
    );
  }

  List<LearningModule> _getFallbackModules() {
    return [
      LearningModule(
        title: 'Introduction to Mindfulness',
        description: 'Learn the basics of mindfulness meditation and how to incorporate it into your daily life for better mental wellness.',
        category: LearningCategory.mindfulness,
        type: ContentType.article,
        difficulty: Difficulty.beginner,
        estimatedMinutes: 20,
        tags: ['mindfulness', 'meditation', 'stress-relief'],
        rating: 4.5,
        ratingCount: 42,
        authorId: 'mindcare_team',
        authorName: 'MindCare Team',
        content: [
          LearningContent(
            title: 'What is Mindfulness?',
            content: '''Mindfulness is the practice of being fully present and engaged in the current moment, without judgment. It involves paying attention to your thoughts, feelings, bodily sensations, and surrounding environment with openness and acceptance.

Research has shown that regular mindfulness practice can reduce stress, improve focus, enhance emotional regulation, and contribute to overall mental well-being. It's a skill that can be developed through consistent practice.''',
            type: ContentType.article,
            order: 1,
          ),
          LearningContent(
            title: 'Simple Mindfulness Exercise',
            content: '''Try this basic mindfulness exercise:

1. Find a comfortable position and close your eyes
2. Focus on your breathing - notice the sensation of air entering and leaving your nostrils
3. When your mind wanders (and it will), gently bring your attention back to your breath
4. Continue for 5-10 minutes

Start with just a few minutes daily and gradually increase the duration as you become more comfortable with the practice.''',
            type: ContentType.exercise,
            order: 2,
          ),
        ],
      ),
      LearningModule(
        title: 'Understanding Anxiety',
        description: 'Explore what anxiety is, its common symptoms, and evidence-based strategies for managing anxious thoughts and feelings.',
        category: LearningCategory.anxiety,
        type: ContentType.article,
        difficulty: Difficulty.beginner,
        estimatedMinutes: 25,
        tags: ['anxiety', 'coping-strategies', 'mental-health'],
        rating: 4.3,
        ratingCount: 67,
        authorId: 'mindcare_team',
        authorName: 'MindCare Team',
        content: [
          LearningContent(
            title: 'What is Anxiety?',
            content: '''Anxiety is a natural response to stress or perceived threats. While some anxiety is normal and can be helpful, persistent or excessive anxiety can interfere with daily life.

Common symptoms include racing thoughts, rapid heartbeat, sweating, restlessness, and avoiding certain situations. Understanding that anxiety is a common experience can help reduce the stigma and shame often associated with it.''',
            type: ContentType.article,
            order: 1,
          ),
          LearningContent(
            title: 'Grounding Techniques',
            content: '''When anxiety strikes, grounding techniques can help you return to the present moment:

5-4-3-2-1 Technique:
- 5 things you can see
- 4 things you can touch
- 3 things you can hear
- 2 things you can smell
- 1 thing you can taste

This technique helps shift your focus from anxious thoughts to your immediate environment, providing relief from overwhelming feelings.''',
            type: ContentType.exercise,
            order: 2,
          ),
        ],
      ),
      LearningModule(
        title: 'Better Sleep Habits',
        description: 'Discover practical strategies to improve your sleep quality and establish healthy sleep routines for better mental health.',
        category: LearningCategory.sleep,
        type: ContentType.article,
        difficulty: Difficulty.beginner,
        estimatedMinutes: 30,
        tags: ['sleep', 'sleep-hygiene', 'wellness'],
        rating: 4.7,
        ratingCount: 89,
        authorId: 'mindcare_team',
        authorName: 'MindCare Team',
        content: [
          LearningContent(
            title: 'The Importance of Sleep',
            content: '''Quality sleep is fundamental to mental health. Poor sleep can worsen symptoms of anxiety, depression, and stress, while good sleep supports emotional regulation, cognitive function, and overall well-being.

Adults typically need 7-9 hours of sleep per night. However, it's not just about quantity - sleep quality matters just as much as duration.''',
            type: ContentType.article,
            order: 1,
          ),
          LearningContent(
            title: 'Sleep Hygiene Tips',
            content: '''Create better sleep habits with these evidence-based strategies:

• Maintain a consistent sleep schedule, even on weekends
• Create a relaxing bedtime routine (reading, gentle stretching, meditation)
• Keep your bedroom cool, dark, and quiet
• Avoid screens 1 hour before bedtime
• Limit caffeine after 2 PM
• Get natural sunlight exposure during the day
• Avoid large meals and alcohol close to bedtime

Pick 2-3 strategies to start with rather than trying to implement all changes at once.''',
            type: ContentType.worksheet,
            order: 2,
          ),
        ],
      ),
    ];
  }
}