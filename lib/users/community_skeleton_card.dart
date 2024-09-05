import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CommunitySkeletonCard extends StatelessWidget {
  const CommunitySkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 100,
          width: double.infinity,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Skeleton.replace(
                  width: 50,
                  height: 50,
                  child: Container(color: Colors.grey[300]),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Skeleton.replace(
                        width: 80,
                        height: 20,
                        child: Container(color: Colors.grey[300]),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Skeleton.replace(
                        width: 200,
                        height: 20,
                        child: Container(color: Colors.grey[300]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
