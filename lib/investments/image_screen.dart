import 'package:cached_network_image/cached_network_image.dart';
import 'package:dira_nedira/investments/investment.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

class ImageScreen extends StatelessWidget {
  final Investment investment;

  const ImageScreen({@required this.investment});
  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImageProvider(investment.imageURL);
    final theme = Theme.of(context);
    return GestureDetector(
      child: Scaffold(
        // backgroundColor: theme.primaryColor,
        body: Center(
          child: Hero(
            tag: investment.id,
            child: OctoImage(
              image: image,
              placeholderBuilder: OctoPlaceholder.frame(),
              errorBuilder: OctoError.icon(color: Colors.red),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
