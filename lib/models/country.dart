
class CountrySummary {
  final String name;
  final String flagUrl;
  final int population;
  final String cca2;

  CountrySummary({
    required this.name,
    required this.flagUrl,
    required this.population,
    required this.cca2,
  });

  factory CountrySummary.fromJson(Map<String, dynamic> json) {
    return CountrySummary(
      name: (json['name']?['common'] ?? '') as String,
      flagUrl: (json['flags']?['png'] ?? '') as String,
      population: (json['population'] ?? 0) as int,
      cca2: (json['cca2'] ?? '') as String,
    );
  }

  String formattedPopulation() {
    // e.g., 47.1M
    if (population >= 1000000) {
      final v = (population / 1000000);
      return '${v.toStringAsFixed(1)}M';
    }
    if (population >= 1000) {
      final v = (population / 1000);
      return '${v.toStringAsFixed(1)}K';
    }
    return population.toString();
  }
}
