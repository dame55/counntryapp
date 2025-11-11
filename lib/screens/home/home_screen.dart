import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/country.dart';
import '../../services/country_repository.dart';
import 'detail_screen.dart';
import '../../cubits/countries_cubit.dart';
import '../../cubits/favorites_cubit.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CountriesCubit _cubit;
  late FavoritesCubit _favCubit;
  final _searchController = TextEditingController();
  final repo = CountryRepository();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _cubit = CountriesCubit(repo)..loadCountries();
    _favCubit = FavoritesCubit()..load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    _favCubit.close();
    super.dispose();
  }

  void _openDetail(CountrySummary c) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => DetailScreen(cca2: c.cca2, name: c.name)));
  }

  Future<List<CountrySummary>> _fetchFavoritesList(Set<String> ids) async {
    final all = await repo.fetchAllSummaries();
    return all.where((c) => ids.contains(c.cca2)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: SafeArea(
          child: _currentIndex == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Countries',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => _cubit.search(v),
                          decoration: const InputDecoration(
                            hintText: 'Search for a country',
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 18.0),
                    child: Text(
                      'Favorites',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Home list
            BlocBuilder<CountriesCubit, CountriesState>(
              builder: (context, state) {
                if (state is CountriesLoading || state is CountriesInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CountriesError) {
                  return Center(child: Text('Error: ${state.error}'));
                } else if (state is CountriesEmpty) {
                  return Center(child: Text(state.message));
                } else if (state is CountriesLoaded) {
                  final list = state.countries;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: list.length,
                    itemBuilder: (context, idx) {
                      final c = list[idx];

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            c.flagUrl,
                            width: 60,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Population: ${c.population}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            _favCubit.toggle(c.cca2);
                            setState(() {}); // trigger rebuild for animation
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                                child: child,
                              );
                            },
                            child: Icon(
                              (_favCubit.state is FavoritesLoaded &&
                                      (_favCubit.state as FavoritesLoaded).favorites.contains(c.cca2))
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              key: ValueKey<bool>(
                                (_favCubit.state is FavoritesLoaded &&
                                    (_favCubit.state as FavoritesLoaded)
                                        .favorites
                                        .contains(c.cca2)),
                              ),
                              color: (_favCubit.state is FavoritesLoaded &&
                                      (_favCubit.state as FavoritesLoaded).favorites.contains(c.cca2))
                                  ? Colors.redAccent
                                  : Colors.black54,
                              size: 26,
                            ),
                          ),
                        ),
                        onTap: () => _openDetail(c),
                      );
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),

            // Favorites list
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favState) {
                if (favState is FavoritesInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (favState is FavoritesLoaded) {
                  final ids = favState.favorites;
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
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                country.flagUrl,
                                width: 60,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              country.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text('Population: ${country.population}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
        ],
        onTap: (i) {
          setState(() {
            _currentIndex = i;
          });
        },
      ),
    );
  }
}
