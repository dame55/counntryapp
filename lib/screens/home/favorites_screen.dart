import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/favorites_cubit.dart';
import '../../models/country.dart';
import '../../services/country_repository.dart';
import '../../widgets/country_tile.dart';


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
        appBar: AppBar(title: const Text('Favorites')),
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
                    itemCount: list.length,
                    itemBuilder: (c, i) {
                      final country = list[i];
                      return CountryTile(
                        country: country,
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () => _favCubit.toggle(country.cca2),
                        ),
                        onTap: () => Navigator.pushNamed(context, '/detail', arguments: {'cca2': country.cca2, 'name': country.name}),
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
