part of 'favorites_cubit.dart';
abstract class FavoritesState extends Equatable {
  const FavoritesState();
  @override List<Object?> get props => [];
}
class FavoritesInitial extends FavoritesState {}
class FavoritesLoaded extends FavoritesState {
  final Set<String> favorites;
  const FavoritesLoaded(this.favorites);
  @override List<Object?> get props => [favorites];
}
