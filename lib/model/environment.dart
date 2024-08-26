import 'dart:convert';

import 'package:fireprime/customised_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class Environment {
  String environmentName;

  Map<String, List<CustomisedImage>> images = {};

  Environment({required this.environmentName});

  Future<Map<String, List<CustomisedImage>>> getImagesJSON() async {
    String envNameLower = environmentName.toLowerCase();
    print('in images');
    print(envNameLower);
    String jsonString =
        await rootBundle.loadString('assets/images/spain/images_spain.json');
    print('loaded');
    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    jsonData.forEach((question, value) {
      List<CustomisedImage> imagesPath = [];
      for (int i = 0; i < value.length; ++i) {
        imagesPath
            .add(CustomisedImage(value[i]['path'], value[i]['description']));
      }
      images[question] = imagesPath;
    });
    return images;
  }

  List<CustomisedImage> getImagePath(String question, BuildContext context) {
    List<CustomisedImage> imagePath = [];
    if (images.containsKey(question)) {
      for (int i = 0; i < images[question]!.length; ++i) {
        String description =
            context.tr('$question-images.${images[question]![i].description}');
        imagePath.add(CustomisedImage(images[question]![i].path, description));
      }
    }
    return imagePath;
  }
}
