import 'package:anime_app/models/server_model.dart';

class Episode {
  final int episode;
  final List<ServerElement> servers;
  final DateTime? updatedAt;

  Episode({
    required this.episode,
    required this.servers,
    this.updatedAt,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
        episode: (json['episode'] as num).toInt(),
        servers: json['servers'] == null
            ? []
            : (json['servers'] as List<dynamic>)
                .map((s) => ServerElement.fromJson(s))
                .toList(),
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'episode': episode,
        'servers': servers.map((s) => s.toJson()).toList(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}