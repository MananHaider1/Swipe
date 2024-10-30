class FAQ {
  String id;
  String question;
  String answer;

  FAQ({required this.id, required this.question, required this.answer});

  factory FAQ.fromMap(Map<String, dynamic> data, String id) {
    return FAQ(
      id: id,
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
    };
  }
}
