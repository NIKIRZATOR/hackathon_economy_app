import 'package:flutter/material.dart';


void openTasks(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Открыть Задания')),
  );
}

void openShop(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Открыть Магазин')),
  );
}

void openAlmanac(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Открыть Альманах')),
  );
}
