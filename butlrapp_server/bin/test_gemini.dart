import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  final apiKey = 'AIzaSyAAhLNPJVqFU0mmeJ4hvNIMCnAgInhTxUI';
  final modelName = 'gemini-2.0-flash';
  
  print('Testing model: $modelName');
  final client = GenerativeModel(model: modelName, apiKey: apiKey);
  try {
    final response = await client.generateContent([Content.text('hi')]);
    print('✅ Success with $modelName: ${response.text}');
  } catch (e) {
    print('❌ Error with $modelName: $e');
  }
}
