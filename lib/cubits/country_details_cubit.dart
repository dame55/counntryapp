import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/country_repository.dart';

import 'country_details_state.dart';

class CountryDetailsCubit extends Cubit<CountryDetailsState> {
  final CountryRepository repo;
  CountryDetailsCubit(this.repo) : super(DetailsInitial());

  Future<void> loadDetails(String cca2) async {
    try {
      emit(DetailsLoading());
      final details = await repo.fetchDetailsByCca2(cca2);
      emit(DetailsLoaded(details));
    } catch (e) {
      emit(DetailsError(e.toString()));
    }
  }
}
