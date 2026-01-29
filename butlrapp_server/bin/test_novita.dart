
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'sk_ibfw8oxL29xDBrz-qlHvEtbZAULOsu4qKz9sW1jCFL4';
  final baseUrl = 'https://api.novita.ai/v3/openai';
  final model = 'meta-llama/llama-3.1-8b-instruct';

  print('Testing Novita AI connection...');
  print('API Key (first 10 chars): ${apiKey.substring(0, 10)}...');

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'user', 'content': 'Hello, are you working? Respond with "Yes" if you are.'}
        ],
        'temperature': 0.7,
      }),
    ).timeout(Duration(seconds: 15));

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('AI Response: ${data['choices'][0]['message']['content']}');
      print('TEST PASSED');
    } else {
      print('TEST FAILED');
    }
  } catch (e) {
    print('Error during API test: $e');
    print('TEST FAILED');
  }
}
