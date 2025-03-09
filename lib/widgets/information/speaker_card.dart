import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/speaker.dart';

class SpeakerCard extends StatelessWidget {
  final Speaker speaker;
  final VoidCallback onTap;

  const SpeakerCard({
    super.key,
    required this.speaker,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = (screenWidth - 20).clamp(300, 400);

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: cardWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: FastCachedImage(
                    url: speaker.coverUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, url) => Image.memory(
                      Uri.parse(speaker.coverLqip).data!.contentAsBytes(),
                      fit: BoxFit.contain,
                      width: cardWidth,
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 40,
                  child: Text(
                    speaker.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      shadows: const <Shadow>[
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
