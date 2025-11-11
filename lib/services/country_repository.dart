
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:countryapp/models/country.dart';

import '../core/api_client.dart';
import '../details/country_detail_screen.dart';


class CountryRepository {
  final client = ApiClient().dio;

  // Minimal fields for list (as required)
  Future<List<CountrySummary>> fetchAllSummaries() async {
    // include capital so UI can show it in the favorites list
    final res = await client.get('all?fields=name,flags,population,cca2,capital');
    final data = res.data as List;
    return data.map((e) => CountrySummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Search by name (minimal fields)
  Future<List<CountrySummary>> searchByName(String name) async {
    final res = await client.get('name/$name?fields=name,flags,population,cca2,capital');
    final data = res.data as List;
    return data.map((e) => CountrySummary.fromJson(e as Map<String, dynamic>)).toList();
  }
Future<CountryDetails> fetchDetailsByCca2(String code) async {
  final response = await http.get(Uri.parse(
      'https://restcountries.com/v3.1/alpha/$code?fields=name,flags,population,capital,region,subregion,area,timezones'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data is List && data.isNotEmpty) {
      return CountryDetails.fromJson(data.first);
    } else if (data is Map<String, dynamic>) {
      // Safety for rare cases
      return CountryDetails.fromJson(data);
    } else {
      throw Exception('Unexpected API response format');
    }
  } else {
    throw Exception('Failed to load country details');
  }
}
}
