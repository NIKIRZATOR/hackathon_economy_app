import 'package:flutter/material.dart';

import 'bottom_bar_functions.dart';

class CityMapBottomBar extends StatelessWidget {
  const CityMapBottomBar({super.key, required this.height, required this.wight});

  final double height;
  final double wight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 0.07,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () => openTasks(context),
            child: const Text('Задания'),
          ),
          TextButton(
            onPressed: () => openShop(context, height, wight),
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
