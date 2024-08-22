import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frb_code/models/rss_provider.dart';

class AddFeedScreen extends StatefulWidget {
  const AddFeedScreen({super.key});

  @override
  AddFeedScreenState createState() => AddFeedScreenState();
}

class AddFeedScreenState extends State<AddFeedScreen> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final url = _controller.text.trim();
    if (url.isNotEmpty) {
      Provider.of<RssProvider>(context, listen: false).addFeed(url);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add RSS Feed'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'RSS Feed URL',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}