import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/country.dart';
import '../services/country_repository.dart';


part 'countries_state.dart';

class CountriesCubit extends Cubit<CountriesState> {
  final CountryRepository repo;
  Timer? _debounce;
  List<CountrySummary> _all = [];

  CountriesCubit(this.repo) : super(CountriesInitial());

  Future<void> loadCountries() async {
    try {
      emit(CountriesLoading());
      _all = await repo.fetchAllSummaries();
      emit(CountriesLoaded(List.from(_all)));
    } catch (e) {
      emit(CountriesError(e.toString()));
    }
  }

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        emit(CountriesLoaded(List.from(_all)));
        return;
      }
      final q = query.toLowerCase();
      final filtered = _all.where((c) => c.name.toLowerCase().contains(q)).toList();
      if (filtered.isEmpty) {
        emit(CountriesEmpty('No countries found.'));
      } else {
        emit(CountriesLoaded(filtered));
      }
    });
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
