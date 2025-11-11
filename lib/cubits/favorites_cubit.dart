import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  static const _key = 'fav_cca2_list';
  FavoritesCubit() : super(FavoritesInitial());

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    emit(FavoritesLoaded(Set<String>.from(list)));
  }

  Future<void> toggle(String cca2) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    final set = Set<String>.from(current);
    if (set.contains(cca2)) {
      set.remove(cca2);
    } else {
      set.add(cca2);
    }
    await prefs.setStringList(_key, set.toList());
    emit(FavoritesLoaded(set));
  }

  bool isFavorite(FavoritesState state, String cca2) {
    if (state is FavoritesLoaded) return state.favorites.contains(cca2);
    return false;
  }
}
