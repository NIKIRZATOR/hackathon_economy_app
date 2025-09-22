import 'package:flutter/material.dart';

import 'bottom_bar_functions.dart';

class CityMapBottomBar extends StatelessWidget {
  const CityMapBottomBar({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () => openTasks(context),
            child: const Text('Задания'),
          ),
          TextButton(
            onPressed: () => openShop(context),
            child: const Text('Магазин'),
          ),
          TextButton(
            onPressed: () => openAlmanac(context),
            child: const Text('Альманах'),
          ),
        ],
      ),
    );
  }
}
