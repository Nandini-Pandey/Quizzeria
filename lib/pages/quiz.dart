import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizScreen extends StatefulWidget {
  final String category;

  const QuizScreen({Key? key, required this.category}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions(widget.category);
  }

  // Fetch questions from the trivia API based on the selected category
  Future<void> fetchQuestions(String category) async {
    // Convert category name to its category ID according to the trivia API
    String categoryID = categoryToId(category);

    // Construct the API URL
    String url =
        'https://opentdb.com/api.php?amount=10&category=$categoryID&type=multiple';

    // Make the API request
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        questions = List<Map<String, dynamic>>.from(data['results']);
      });
    } else {
      // Handle error if API request fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load questions')),
      );
    }
  }

  // Map category names to category IDs
  String categoryToId(String category) {
    switch (category) {
      case 'Art & Literature':
        return '25'; // Art & Literature category ID
      case 'Science & Nature':
        return '17'; // Science & Nature category ID
      case 'History & Holidays':
        return '23'; // History & Holidays category ID
      case 'Sports & Leisure':
        return '21'; // Sports & Leisure category ID
      case 'Music':
        return '12'; // Music category ID
      case 'Geography':
        return '22'; // Geography category ID
      default:
        return '9'; // General Knowledge category ID as a fallback
    }
  }

  // Check the selected answer and move to the next question
  void checkAnswer(String selectedAnswer) {
    if (selectedAnswer == questions[currentQuestionIndex]['correct_answer']) {
      setState(() {
        score++;
      });
    }
    setState(() {
      currentQuestionIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(widget.category),
        elevation: 0,
      ),
      body: questions.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show a loader while fetching questions
          : currentQuestionIndex < questions.length
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questions[currentQuestionIndex]['question'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...List<String>.from(
              questions[currentQuestionIndex]['incorrect_answers']
                ..add(questions[currentQuestionIndex]
                ['correct_answer'])
                ..shuffle(), // Shuffle answers for randomness
            ).map<Widget>((answer) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
                  onPressed: () => checkAnswer(answer),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.purpleAccent,
                    elevation: 5,
                  ),
                  child: Text(
                    answer,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      )
          : Center(
        child: Text(
          'Your Score: $score/${questions.length}',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
