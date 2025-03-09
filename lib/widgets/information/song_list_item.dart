import 'package:flutter/material.dart';
import 'package:momentum24_app/models/song.dart';

class SongListItem extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongListItem({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(song.title),
      subtitle: Text(song.originalTitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      style: ListTileStyle.list,
      tileColor: Colors.white10,
      onTap: onTap,
    );
  }
}
