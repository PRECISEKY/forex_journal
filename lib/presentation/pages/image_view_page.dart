import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewPage extends StatefulWidget {
  final List<String> imageUrls; // Can be local paths or http URLs
  final int initialIndex;

  const ImageViewPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use dark background for better image viewing
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        foregroundColor: Colors.white, // Make icons/title white
         // Show image count like "1 of 3"
        title: Text('${_currentIndex + 1} of ${widget.imageUrls.length}'),
        elevation: 0,
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.imageUrls.length,
        pageController: _pageController,
        // Update current index when page changes
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // Build each page (image)
        builder: (context, index) {
          final pathOrUrl = widget.imageUrls[index];
          final isNetworkImage = pathOrUrl.startsWith('http');

          // Use appropriate image provider
          final imageProvider = isNetworkImage
              ? NetworkImage(pathOrUrl)
              : FileImage(File(pathOrUrl)) as ImageProvider; // Cast needed

          return PhotoViewGalleryPageOptions(
            imageProvider: imageProvider,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2.5,
            initialScale: PhotoViewComputedScale.contained,
            // Hero tag can cause issues, use carefully or omit
            // heroAttributes: PhotoViewHeroAttributes(tag: pathOrUrl),
          );
        },
        // Show loading indicator while images load
        loadingBuilder: (context, event) => const Center(
          child: SizedBox(
            width: 30.0,
            height: 30.0,
            child: CircularProgressIndicator(
               // Use progress event if needed: event == null ? 0 : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
               strokeWidth: 2,
               color: Colors.white,
            ),
          ),
        ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        scrollPhysics: const BouncingScrollPhysics(),
      ),
    );
  }
}