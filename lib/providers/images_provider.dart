import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/model/customised_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImagesProvider with ChangeNotifier {
  Map<String, List<CustomisedImage>> images = {};

  ImagesProvider();

  Future<void> getImagesJSON(String environment) async {
    images = {};
    String envNameLower = environment.toLowerCase();
    String jsonString;

    try {
      print('Loading images_$envNameLower.json');
      jsonString = await rootBundle
          .loadString('assets/images/$envNameLower/images_$envNameLower.json');
      print('Loaded images_$envNameLower.json');
    } catch (e) {
      jsonString = await rootBundle
          .loadString('assets/images/default/images_default.json');
    }
    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    jsonData.forEach(
      (question, value) {
        List<CustomisedImage> imagesPath = [];
        for (int i = 0; i < value.length; ++i) {
          imagesPath
              .add(CustomisedImage(value[i]['path'], value[i]['description']));
        }
        images[question] = imagesPath;
      },
    );
  }

  bool containsKey(String question) {
    return images.containsKey(question);
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
