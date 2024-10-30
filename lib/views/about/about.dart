import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AboutUsViewer extends ConsumerWidget {
  const AboutUsViewer({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Expanded(
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('about_us')
            .doc('latest')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No About Us found'));
          }

          List<dynamic> content = snapshot.data!['content'];

          return ListView.builder(
            itemCount: content.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> item = content[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  item['content'],
                  style: TextStyle(
                    fontSize: item['type'] == 'heading'
                        ? 20
                        : item['type'] == 'subheading'
                            ? 18
                            : 16,
                    fontWeight: item['type'] == 'heading'
                        ? FontWeight.bold
                        : item['type'] == 'subheading'
                            ? FontWeight.w600
                            : FontWeight.normal,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
