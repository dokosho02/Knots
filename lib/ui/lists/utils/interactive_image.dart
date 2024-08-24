import 'package:flutter/material.dart';

class InteractiveImage extends StatelessWidget {
  final String imageUrl;
  const InteractiveImage({super.key, required this.imageUrl});

  void showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FullScreenImageViewer(
          imageUrl: imageUrl,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showFullScreenImage(context),
      child: Image.network(imageUrl),
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  FullScreenImageViewerState createState() => FullScreenImageViewerState();
}

class FullScreenImageViewerState extends State<FullScreenImageViewer> {
  double rotation = 0.0;
  final TransformationController _transformationController = TransformationController();

  void rotateImage() {
    setState(() {
      rotation += 90;
      if (rotation >= 360) {
        rotation -= 360;
      }
      _transformationController.value = Matrix4.identity()
        ..rotateZ(rotation * 3.1415927 / 180);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.rotate_right),
            onPressed: rotateImage,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          constrained: false,
          transformationController: _transformationController,
          minScale: 0.1,
          maxScale: 5.0,
          boundaryMargin: const EdgeInsets.all(double.infinity), // 允许无限制的平移
          // boundaryMargin: const EdgeInsets.all(42.0 ), // 允许无限制的平移

          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
