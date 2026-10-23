// Shows a product picture.
// The WHOLE picture is shown (BoxFit.contain), so tall pictures like a
// soda can are not cut. A soft grey background fills the empty space.
// If there is no picture (or it fails to load), it shows a soft colored
// placeholder, so the app still looks good without images.
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    required this.name,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.fit = BoxFit.contain,
    this.backgroundColor = const Color(0xFFF6F6F6),
  });

  final String? imageUrl;
  final String name;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxFit fit; // contain = show everything, cover = fill and crop
  final Color backgroundColor;

  static const _pastels = [
    Color(0xFFFFE8D6),
    Color(0xFFE3F2E1),
    Color(0xFFE6EEFB),
    Color(0xFFFBE6EF),
    Color(0xFFFFF3C9),
  ];

  Widget _placeholder() {
    // Same product name -> always the same color
    var sum = 0;
    for (final unit in name.codeUnits) {
      sum += unit;
    }
    final iconSize = ((height ?? 80) * 0.35).clamp(24.0, 72.0).toDouble();

    return Container(
      color: _pastels[sum % _pastels.length],
      alignment: Alignment.center,
      child: Icon(Icons.fastfood_rounded, size: iconSize, color: Colors.black26),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final hasImage = url != null && url.isNotEmpty;

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: hasImage
            ? Container(
          color: backgroundColor,
          child: Image.network(
            url,
            fit: fit,
            errorBuilder: (context, error, stack) => _placeholder(),
          ),
        )
            : _placeholder(),
      ),
    );
  }
}