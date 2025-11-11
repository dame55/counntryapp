import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonCountryTile extends StatelessWidget {
  const SkeletonCountryTile({super.key});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(width: 50, height: 30, color: Colors.white),
      ),
      title: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(height: 12, color: Colors.white),
      ),
      subtitle: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(height: 10, margin: const EdgeInsets.only(top: 6), color: Colors.white),
      ),
    );
  }
}
