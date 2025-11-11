import 'package:equatable/equatable.dart';

import '../details/country_detail_screen.dart';


abstract class CountryDetailsState extends Equatable {
  const CountryDetailsState();

  @override
  List<Object?> get props => [];
}

class DetailsInitial extends CountryDetailsState {}

class DetailsLoading extends CountryDetailsState {}

class DetailsLoaded extends CountryDetailsState {
  final CountryDetails details;
  const DetailsLoaded(this.details);

  @override
  List<Object?> get props => [details];
}

class DetailsError extends CountryDetailsState {
  final String error;
  const DetailsError(this.error);

  @override
  List<Object?> get props => [error];
}
