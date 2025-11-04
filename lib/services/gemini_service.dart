import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Replace with your actual Gemini API key
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  Future<Map<String, dynamic>> analyzeHealthDescription(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''Analyze this health description and extract the following information in JSON format:
{
  "symptoms": ["list of symptoms mentioned"],
  "mood": "overall mood if mentioned (e.g., happy, tired, anxious, stressed)",
  "sleep_hours": "number of hours if mentioned",
  "severity": "mild, moderate, or severe based on description",
  "notes": "any additional important details"
}

Health description: "$text"

Only return valid JSON. If information is not mentioned, use null for that field.'''
            }]
          }],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 512,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Extract JSON from the response
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(generatedText);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
        
        return _fallbackAnalysis(text);
      } else {
        print('Gemini API error: ${response.statusCode}');
        return _fallbackAnalysis(text);
      }
    } catch (e) {
      print('Error analyzing health description: $e');
      return _fallbackAnalysis(text);
    }
  }

  // Fallback simple keyword-based analysis if API fails
  Map<String, dynamic> _fallbackAnalysis(String text) {
    final lowerText = text.toLowerCase();
    final symptoms = <String>[];
    String? mood;
    double? sleepHours;

    // Common symptom keywords
    final symptomMap = {
      'headache': 'Headache',
      'head ache': 'Headache',
      'migraine': 'Headache',
      'tired': 'Fatigue',
      'fatigue': 'Fatigue',
      'exhausted': 'Fatigue',
      'nausea': 'Nausea',
      'nauseous': 'Nausea',
      'fever': 'Fever',
      'temperature': 'Fever',
      'cough': 'Cough',
      'coughing': 'Cough',
      'throat': 'Sore Throat',
      'sore throat': 'Sore Throat',
      'ache': 'Body Ache',
      'pain': 'Body Ache',
      'dizzy': 'Dizziness',
      'dizziness': 'Dizziness',
      'stomach': 'Stomach Pain',
      'anxious': 'Anxiety',
      'anxiety': 'Anxiety',
      'worried': 'Anxiety',
      'congestion': 'Congestion',
      'congested': 'Congestion',
      'stuffy': 'Congestion',
      'back pain': 'Back Pain',
      'joint': 'Joint Pain',
      'chest': 'Chest Pain',
      'insomnia': 'Insomnia',
      'sleep': 'Insomnia',
    };

    symptomMap.forEach((keyword, symptom) {
      if (lowerText.contains(keyword) && !symptoms.contains(symptom)) {
        symptoms.add(symptom);
      }
    });

    // Mood keywords
    final moodMap = {
      'happy': 'Happy',
      'good': 'Good',
      'great': 'Great',
      'sad': 'Sad',
      'depressed': 'Depressed',
      'anxious': 'Anxious',
      'stressed': 'Stressed',
      'tired': 'Tired',
      'energetic': 'Energetic',
      'calm': 'Calm',
      'angry': 'Angry',
      'frustrated': 'Frustrated',
    };

    moodMap.forEach((keyword, moodValue) {
      if (lowerText.contains(keyword)) {
        mood = moodValue;
      }
    });

    // Sleep hours extraction
    final sleepRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(?:hours?|hrs?)(?:\s+of)?\s+sleep');
    final sleepMatch = sleepRegex.firstMatch(lowerText);
    if (sleepMatch != null) {
      sleepHours = double.tryParse(sleepMatch.group(1)!);
    }

    return {
      'symptoms': symptoms,
      'mood': mood,
      'sleep_hours': sleepHours,
      'severity': symptoms.length > 3 ? 'moderate' : 'mild',
      'notes': text,
    };
  }

  Future<String> getHealthAdvice(List<String> symptoms, String mood) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '''As a health assistant, provide brief, supportive advice for someone experiencing:
Symptoms: ${symptoms.join(", ")}
Mood: $mood

Provide:
1. Brief reassurance
2. 2-3 simple self-care suggestions
3. When to consider seeing a doctor

Keep response under 100 words and supportive in tone.'''
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 256,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
      
      return _getFallbackAdvice(symptoms);
    } catch (e) {
      return _getFallbackAdvice(symptoms);
    }
  }

  String _getFallbackAdvice(List<String> symptoms) {
    if (symptoms.isEmpty) {
      return "It's great that you're tracking your health! Continue monitoring your symptoms and maintaining healthy habits.";
    }
    
    return "Thank you for logging your symptoms. Make sure to rest, stay hydrated, and monitor your condition. If symptoms persist or worsen, please consult a healthcare professional.";
  }
}