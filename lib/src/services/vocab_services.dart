import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<dynamic>> getRandomVocab() async {
  const url = 'https://random-words-api-kappa.vercel.app/word';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      return [
        {"word": "Not available", "definition": "Not available"}
      ];
    }
  } catch (e) {
    print('Error: $e');
    return [
      {"word": "Not available", "definition": "Not available"}
    ];
  }
}
