class StremioAddon {
  final String id;
  final String name;
  final String description;
  final String manifestUrl;
  bool isEnabled;
  final bool isProtected;
  final String version;

  StremioAddon({
    required this.id,
    required this.name,
    required this.description,
    required this.manifestUrl,
    this.isEnabled = true,
    this.isProtected = false,
    this.version = '1.0.0',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'manifestUrl': manifestUrl,
    'isEnabled': isEnabled,
    'isProtected': isProtected,
    'version': version,
  };

  factory StremioAddon.fromJson(Map<String, dynamic> json) => StremioAddon(
    id: json['id'] ?? '',
    name: json['name'] ?? 'Addon',
    description: json['description'] ?? '',
    manifestUrl: json['manifestUrl'] ?? '',
    isEnabled: json['isEnabled'] ?? true,
    isProtected: json['isProtected'] ?? false,
    version: json['version'] ?? '1.0.0',
  );
}
