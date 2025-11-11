import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/favorites_cubit.dart';
import '../../models/country.dart';
import '../../services/country_repository.dart';
// note: custom layout used here for favorites list (no CountryTile)


class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late FavoritesCubit _favCubit;
  final repo = CountryRepository();

  @override
  void initState() {
    super.initState();
    _favCubit = FavoritesCubit();
    _favCubit.load();
  }

  @override
  void dispose() {
    _favCubit.close();
    super.dispose();
  }

  Future<List<CountrySummary>> _fetchFavoritesList(Set<String> ids) async {
    // Quick approach: fetch all summaries and filter. Alternatively, fetch by name if you have stored more.
    final all = await repo.fetchAllSummaries();
    return all.where((c) => ids.contains(c.cca2)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _favCubit,
      child: Scaffold(
        appBar: AppBar(title: Center(child: const Text('Favorites'))),
        body: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FavoritesLoaded) {
              final ids = state.favorites;
              if (ids.isEmpty) return const Center(child: Text('No favorites yet.'));
              return FutureBuilder<List<CountrySummary>>(
                future: _fetchFavoritesList(ids),
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = snap.data ?? [];
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: list.length,
                    itemBuilder: (c, i) {
                      final country = list[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                country.flagUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    country.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Capital: ${country.capital.isNotEmpty ? country.capital : '-'}',
                                    style: TextStyle(color: Colors.blueGrey[300], fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite_border, size: 28, color: Colors.black54),
                              onPressed: () => _favCubit.toggle(country.cca2),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
