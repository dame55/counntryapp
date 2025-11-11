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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.name ?? 'Country',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flag Banner
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: d.flagUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Key Statistics
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Key Statistics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildStatRow("Area", "${d.area} sq km"),
                          _buildStatRow("Population", "${d.population}"),
                          _buildStatRow("Region", d.region),
                          _buildStatRow("Sub Region", d.subregion),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Timezones
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Timezone',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: d.timezones
                            .map(
                              (tz) => Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 18),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  tz,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
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

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

