import 'dart:typed_data';

import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_editor_plus/options.dart' as o;
import 'package:screenshot/screenshot.dart';

import '../config/config_color.dart';
import '../config/config_image.dart';

class ImageFilters extends StatefulWidget {
  const ImageFilters({
    super.key,
    required this.image,
    this.useCache = true,
    this.options,
  });
  final Uint8List image;

  final bool useCache;
  final o.FiltersOption? options;

  @override
  _ImageFiltersState createState() => _ImageFiltersState();
}

class _ImageFiltersState extends State<ImageFilters> {
  late img.Image decodedImage;
  ColorFilterGenerator selectedFilter = PresetFilters.none;
  Uint8List resizedImage = Uint8List.fromList([]);
  double filterOpacity = 1;
  Uint8List? filterAppliedImage;
  ScreenshotController screenshotController = ScreenshotController();
  late List<ColorFilterGenerator> filters;

  @override
  void initState() {
    filters = [
      PresetFilters.none,
      ...widget.options?.filters ?? presetFiltersList.sublist(1)
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          icon: Image.asset(arrowLeft, width: 24, height: 24, color: white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: const Icon(
              Icons.check,
              size: 24,
              color: white,
            ),
            onPressed: () async {
              EasyLoading.show();
              final data = await screenshotController.capture();
              EasyLoading.dismiss();
              if (mounted) {
                Navigator.pop(context, data);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Screenshot(
          controller: screenshotController,
          child: Stack(
            children: [
              Image.memory(
                widget.image,
                fit: BoxFit.cover,
              ),
              FilterAppliedImage(
                key: Key('selectedFilter:${selectedFilter.name}'),
                image: widget.image,
                filter: selectedFilter,
                fit: BoxFit.cover,
                opacity: filterOpacity,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 160,
          child: Column(children: [
            SizedBox(
              height: 40,
              child: selectedFilter == PresetFilters.none
                  ? Container()
                  : selectedFilter.build(
                      Slider(
                        min: 0,
                        max: 1,
                        divisions: 100,
                        value: filterOpacity,
                        onChanged: (value) {
                          filterOpacity = value;
                          setState(() {});
                        },
                      ),
                    ),
            ),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var filter in filters)
                    GestureDetector(
                      onTap: () {
                        selectedFilter = filter;
                        setState(() {});
                      },
                      child: Column(children: [
                        Container(
                          height: 64,
                          width: 64,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(48),
                            border: Border.all(
                              color: selectedFilter == filter
                                  ? white
                                  : Colors.black,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(48),
                            child: FilterAppliedImage(
                              key: Key('filterPreviewButton:${filter.name}'),
                              image: widget.image,
                              filter: filter,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text(
                          i18n(filter.name),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ]),
                    ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
