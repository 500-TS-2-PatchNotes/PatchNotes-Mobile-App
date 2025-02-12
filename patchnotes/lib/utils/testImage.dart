import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<String> fetchRandomWoundImageUrl() async {
  const url = 'https://pixabay.com/api/?key=48579109-a201c59c99800927d9b9bdeb4&q=wound&image_type=photo&per_page=50';
  final response = await http.get(Uri.parse(url));
  
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final hits = jsonData['hits'] as List;
    if (hits.isNotEmpty) {
      // Pick one random image from the hits
      final randomIndex = Random().nextInt(hits.length);
      return hits[randomIndex]['webformatURL'] as String;
    } else {
      throw Exception('No images found');
    }
  } else {
    throw Exception('Failed to load images');
  }
}

class RandomWoundImageWidget extends StatelessWidget {
  const RandomWoundImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchRandomWoundImageUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No image available'));
        } else {
          return Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        }
      },
    );
  }
}
