import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import './single_song_screen.dart';
import '../../models/song.dart';
import '../../services/data_provider_service.dart';
import '../../widgets/information/song_list_item.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => SongsScreenState();
}

class SongsScreenState extends State<SongsScreen> {
  DataProviderService _dataProviderService =
      GetIt.instance.get<DataProviderService>();

  List<Song> songs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  void loadSongs() async {
    _dataProviderService = _dataProviderService.setNotifier((fetchedSongs) {
      setState(() {
        songs = fetchedSongs;
      });
    });
    final fetchedSongs = await _dataProviderService.getSongs();

    setState(() {
      songs = fetchedSongs;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.songs),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () {
                return _dataProviderService.getSongs(forceNewData: true);
              },
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (BuildContext context, int index) {
                  Song song = songs[index];
                  return SongListItem(
                    song: song,
                    onTap: () {
                      Navigator.of(context, rootNavigator: true)
                          .push(MaterialPageRoute(
                        builder: (context) {
                          return SingleSongScreen(
                              songs: songs, currentIndex: index);
                        },
                      ));
                    },
                  );
                },
              ),
            ),
    );
  }
}
