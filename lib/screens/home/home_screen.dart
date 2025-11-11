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

  @override
  void initState() {
    super.initState();
    final repo = CountryRepository();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: SafeArea(
          child: Column(
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
                  final isFav = (_favCubit.state is FavoritesLoaded) &&
                      (_favCubit.state as FavoritesLoaded)
                          .favorites
                          .contains(c.cca2);

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
                    trailing: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border_outlined,
                        color: isFav ? Colors.redAccent : Colors.black54,
                      ),
                      onPressed: () => _favCubit.toggle(c.cca2),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
          if (i == 1) Navigator.pushNamed(context, '/favorites');
        },
      ),
    );
  }
}
