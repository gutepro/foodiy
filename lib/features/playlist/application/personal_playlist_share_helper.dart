import 'package:foodiy/features/playlist/application/personal_playlist_service.dart';
import 'package:foodiy/features/playlist/domain/personal_playlist_models.dart';

class PersonalPlaylistShareHelper {
  static String formatPlaylist(
    PersonalPlaylist playlist,
    PersonalPlaylistService service,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('Cookbook: ${playlist.name}');
    buffer.writeln('');

    final entries = service.getEntries(playlist.id);
    if (entries.isEmpty) {
      buffer.writeln('No recipes in this cookbook yet.');
      return buffer.toString();
    }

    for (final e in entries) {
      buffer.writeln('- ${e.title} (${e.time}, ${e.difficulty})');
    }

    return buffer.toString();
  }
}
