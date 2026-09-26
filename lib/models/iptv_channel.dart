class IptvChannel {
  final String name;
  final String logo;
  final String group;
  final String url;
  final String? tvgId;

  IptvChannel({
    required this.name,
    required this.logo,
    required this.group,
    required this.url,
    this.tvgId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'logo': logo,
    'group': group,
    'url': url,
    'tvgId': tvgId,
  };

  factory IptvChannel.fromJson(Map<String, dynamic> json) => IptvChannel(
    name: json['name'] ?? 'Channel',
    logo: json['logo'] ?? '',
    group: json['group'] ?? 'General',
    url: json['url'] ?? '',
    tvgId: json['tvgId'],
  );
}
