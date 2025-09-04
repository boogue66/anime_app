// ignore_for_file: constant_identifier_names

enum ServerEnum { MARU, MEGA, NETU, STAPE, SW, YOUR_UPLOAD }

class ServerElement {
  final ServerEnum server;
  final String url;

  ServerElement({required this.server, required this.url});

  factory ServerElement.fromJson(Map<String, dynamic> json) => ServerElement(
    server: ServerEnum.values.firstWhere(
      (e) => e.name.toUpperCase() == (json['server'] as String).toUpperCase(),
      orElse: () => ServerEnum.MARU, // fallback
    ),
    url: json['url'],
  );

  Map<String, dynamic> toJson() => {'server': server.name, 'url': url};
}
