import 'package:flutter/material.dart';

/// Widget gambar yang bisa di-zoom fullscreen saat di-tap.
/// Menggantikan pola InteractiveViewer + ClipRRect + Image.asset inline.
class ZoomableImage extends StatelessWidget {
  final String imagePath;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final List<BoxShadow>? boxShadow;
  final BoxFit fit;

  const ZoomableImage({
    Key? key,
    required this.imagePath,
    this.borderRadius,
    this.margin,
    this.boxShadow,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);
    return GestureDetector(
      onTap: () => _openFullscreen(context),
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: boxShadow,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: radius,
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: fit,
              ),
            ),
            // Ikon hint zoom di pojok kanan bawah
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.zoom_in_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullscreenImageViewer(imagePath: imagePath),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _FullscreenImageViewer extends StatelessWidget {
  final String imagePath;

  const _FullscreenImageViewer({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Gambar zoomable di tengah
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 8.0,
              boundaryMargin: const EdgeInsets.all(40),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Tombol close kanan atas
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Hint teks bawah
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Cubit untuk zoom · Geser untuk pan',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
