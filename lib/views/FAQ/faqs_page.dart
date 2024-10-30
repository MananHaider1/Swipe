import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/models/faqs_model.dart';

class FAQsPage extends ConsumerStatefulWidget {
  const FAQsPage({super.key});
  @override
  FAQsPageState createState() => FAQsPageState();
}

class FAQsPageState extends ConsumerState<FAQsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('faqs').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<FAQ> faqs = snapshot.data!.docs
              .map((doc) =>
                  FAQ.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return ListView.builder(
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              return FAQCard(
                faq: faqs[index],
              );
            },
          );
        },
      ),
    );
  }
}

class FAQCard extends StatelessWidget {
  final FAQ faq;

  const FAQCard({
    super.key,
    required this.faq,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(faq.answer),
          ),
        ],
      ),
    );
  }
}
