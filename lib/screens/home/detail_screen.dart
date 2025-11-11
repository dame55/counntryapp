import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../cubits/country_details_cubit.dart';
import '../../cubits/country_details_state.dart';
import '../../services/country_repository.dart';

class DetailScreen extends StatefulWidget {
  final String cca2;
  final String? name;

  const DetailScreen({super.key, required this.cca2, this.name});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late CountryDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = CountryDetailsCubit(CountryRepository());
    _cubit.loadDetails(widget.cca2);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.name ?? 'Country')),
        body: BlocBuilder<CountryDetailsCubit, CountryDetailsState>(
          builder: (context, state) {
            if (state is DetailsLoading || state is DetailsInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DetailsError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: ${state.error}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _cubit.loadDetails(widget.cca2),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is DetailsLoaded) {
              final d = state.details;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Hero(
                        tag: 'flag-${d.cca2}',
                        child: CachedNetworkImage(
                          imageUrl: d.flagUrl,
                          width: 260,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(d.name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Key Statistics', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text('Area: ${d.area} km²'),
                            Text('Population: ${d.population}'),
                            Text('Region: ${d.region}'),
                            Text('Subregion: ${d.subregion}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Timezones', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    for (final tz in d.timezones) Text(tz.toString()),
                    const SizedBox(height: 12),
                    Text('Capital: ${d.capital.isNotEmpty ? d.capital[0] : 'N/A'}'),
                  ],
                ),
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
