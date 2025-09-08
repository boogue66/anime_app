import 'package:anime_app/models/server_model.dart';

class Episode {
  final int episode;
  final String title;
  final List<ServerElement> servers;

  Episode({
    required this.episode,
    required this.title,
    required this.servers,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        episode: (json['episode'] as num).toInt(),
        title: json['title'] as String? ?? '',
        servers: json['servers'] == null
            ? []
            : (json['servers'] as List<dynamic>)
                .map((s) => ServerElement.fromJson(s))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
        'episode': episode,
        'title': title,
        'servers': servers.map((s) => s.toJson()).toList(),
      };
}