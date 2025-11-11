class CountryDetails {
  final String name;
  final String flagUrl;
  final int population;
  final List<dynamic> capital;
  final String region;
  final String subregion;
  final double area;
  final List<dynamic> timezones;
  final String cca2;

  CountryDetails({
    required this.name,
    required this.flagUrl,
    required this.population,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.area,
    required this.timezones,
    required this.cca2,
  });

  factory CountryDetails.fromJson(Map<String, dynamic> json) {
    return CountryDetails(
      name: (json['name']?['common'] ?? '') as String,
      flagUrl: (json['flags']?['png'] ?? '') as String,
      population: (json['population'] ?? 0) as int,
      capital: (json['capital'] ?? []) as List<dynamic>,
      region: (json['region'] ?? '') as String,
      subregion: (json['subregion'] ?? '') as String,
      area: ((json['area'] ?? 0) as num).toDouble(),
      timezones: (json['timezones'] ?? []) as List<dynamic>,
      cca2: (json['cca2'] ?? '') as String,
    );
  }
}
