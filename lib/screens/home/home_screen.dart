import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/country.dart';
import '../../services/country_repository.dart';
import 'detail_screen.dart';
import '../../cubits/countries_cubit.dart';
import '../../cubits/favorites_cubit.dart';

import '../../widgets/country_tile.dart';
import '../../widgets/skeleton_country_tile.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CountriesCubit _cubit;
  late FavoritesCubit _favCubit;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final repo = CountryRepository();
    _cubit = CountriesCubit(repo);
    _cubit.loadCountries();
    _favCubit = FavoritesCubit();
    _favCubit.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    _favCubit.close();
    super.dispose();
  }

  void _openDetail(CountrySummary c) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => DetailScreen(cca2: c.cca2, name: c.name),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Explorer'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => _cubit.search(v),
              decoration: InputDecoration(
                hintText: 'Search for a country',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _cubit),
          BlocProvider.value(value: _favCubit),
        ],
        child: BlocBuilder<CountriesCubit, CountriesState>(
          builder: (context, state) {
            if (state is CountriesLoading || state is CountriesInitial) {
              return ListView.builder(
                itemCount: 8,
                itemBuilder: (_, __) => const SkeletonCountryTile(),
              );
            } else if (state is CountriesError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: ${state.error}'),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: () => _cubit.loadCountries(), child: const Text('Retry')),
                  ],
                ),
              );
            } else if (state is CountriesEmpty) {
              return Center(child: Text(state.message));
            } else if (state is CountriesLoaded) {
              final list = state.countries;
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, idx) {
                  final c = list[idx];
                  final isFav = (_favCubit.state is FavoritesLoaded) && (_favCubit.state as FavoritesLoaded).favorites.contains(c.cca2);
                  return CountryTile(
                    country: c,
                    onTap: () => _openDetail(c),
                    trailing: IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                      onPressed: () => _favCubit.toggle(c.cca2),
                    ),
                  );
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, '/favorites');
        },
      ),
    );
  }
}
