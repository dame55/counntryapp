part of 'countries_cubit.dart';

abstract class CountriesState extends Equatable {
  const CountriesState();
  @override
  List<Object?> get props => [];
}

class CountriesInitial extends CountriesState {}
class CountriesLoading extends CountriesState {}
class CountriesLoaded extends CountriesState {
  final List<CountrySummary> countries;
  const CountriesLoaded(this.countries);
  @override List<Object?> get props => [countries];
}
class CountriesEmpty extends CountriesState {
  final String message;
  const CountriesEmpty(this.message);
  @override List<Object?> get props => [message];
}
class CountriesError extends CountriesState {
  final String error;
  const CountriesError(this.error);
  @override List<Object?> get props => [error];
}
