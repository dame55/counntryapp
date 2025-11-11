import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:countryapp/models/country.dart';

class CountryTile extends StatelessWidget {
  final CountrySummary country;
  final VoidCallback? onTap;
  final Widget? trailing;

  const CountryTile({super.key, required this.country, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Hero(
        tag: 'flag-${country.cca2}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CachedNetworkImage(
            imageUrl: country.flagUrl,
            width: 64,
            height: 40,
            fit: BoxFit.cover,
            placeholder: (c, u) => Container(width: 64, height: 40, color: Colors.grey[200]),
            errorWidget: (c, u, e) => Container(width: 64, height: 40, color: Colors.grey[200], child: const Icon(Icons.error)),
          ),
        ),
      ),
      title: Text(country.name),
      subtitle: Text('Population: ${country.formattedPopulation()}'),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
