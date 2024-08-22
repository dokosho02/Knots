import 'package:flutter/material.dart';
import 'package:frb_code/src/rust/api/simple.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  BookScreenState createState() => BookScreenState();
}

class BookScreenState extends State<BookScreen> {
  String _fileName = "please select an EPUB file";
  final Logger _logger = Logger();
  String _htmlContent = '';

  Future<void> pickAndProcessFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub'],
        withReadStream: true, // 使用读取流而不是加载整个文件到内存
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _fileName = "No file selected");
        return;
      }
      final file = result.files.first;
      final fileExt = file.extension!;
      if (file.readStream == null) {
        setState(() => _fileName = "Error: Unable to read file");
        return;
      }
      _logger.i('selected file: ${file.name}\nsize: ${file.size} bytes');
      
      // 使用流处理文件
      final response = await processFileStream(fileExt, file.readStream!);
      
      if (response.isNotEmpty) {
        setState(() {
          _htmlContent = response.join('<hr/>'); // 使用分隔符将各个章节内容连接起来
        });
      } else {
        setState(() => _fileName = "Error processing EPUB");
      }
    } catch (e) {
      _logger.e('Error processing file: $e');
      setState(() => _fileName = "Error processing file: $e");
    }
  }

  Future<List<String>> processFileStream(String fileExt, Stream<List<int>> readStream) async {
    var processor = await createProcessor(fileType: fileExt);
    try {
      await for (final chunk in readStream) {
        processor = await processChunk(processor: processor, chunk: chunk);
      }
      return await finalizeProcessing(processor: processor);
    } catch (e) {
      _logger.e('Error processing EPUB: $e');
      return ["Error processing EPUB: $e"];
    }
  }

@override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                _htmlContent,
                )
            ),
          ],
        ),
    );
  }
}
