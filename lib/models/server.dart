class Server {
  final int id;
  final String name;
  final String country;
  final String countryFlag;
  final bool isActive;
  final int activeConnections;

  Server({
    required this.id,
    required this.name,
    required this.country,
    required this.countryFlag,
    required this.isActive,
    required this.activeConnections,
  });

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      id: json['id'] as int,
      name: json['name'] as String,
      country: json['country'] as String,
      countryFlag: json['country_flag'] as String,
      isActive: json['is_active'] as bool,
      activeConnections: json['active_connections'] as int,
    );
  }
}
