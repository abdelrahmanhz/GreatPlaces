import 'dart:io';

import 'package:flutter/material.dart';
import 'package:great_places/helpers/db_helper.dart';

import '../models/place.dart';

class GreatPlacesProvider with ChangeNotifier {
  List<Place> _items = [];
  static const String dbTable = 'user_places';

  List<Place> get items {
    return [..._items];
  }

  void addPlace(
    String pickedTitle,
    File pickedImage,
  ) {
    final newPlace = Place(
      id: DateTime.now().toString(),
      image: pickedImage,
      title: pickedTitle,
      location: null,
    );
    _items.add(newPlace);
    notifyListeners();
    DBHelper.insert(dbTable, {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
    });
  }

  Future<void> fetchAndSetPlaces() async {
    final dataList = await DBHelper.getData(dbTable);
    _items = dataList
        .map((item) => Place(
            id: item['id'],
            title: item['title'],
            location: null,
            image: File(item['image'])))
        .toList();
    notifyListeners();
  }
}
