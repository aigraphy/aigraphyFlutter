import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../aigraphy_widget.dart';
import '../bloc/listen_language/bloc_listen_language.dart';
import '../bloc/person/bloc_person.dart';
import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import '../config/config_helper.dart';
import '../widget/click_widget.dart';

class ChooseLanguage extends StatefulWidget {
  const ChooseLanguage({super.key});

  @override
  State<ChooseLanguage> createState() => _ChooseLanguageState();
}

class _ChooseLanguageState extends State<ChooseLanguage> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> languages = [];

  void updateLanguage(int index) {
    if (_currentIndex == index) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      for (final lang in languages) {
        lang['select'] = false;
      }
      _currentIndex = index;
      languages[_currentIndex]['select'] = !languages[_currentIndex]['select'];
    });
    context.read<ListenLanguageBloc>().add(ChangeLanguage(
        locale: languages[_currentIndex]['locale'], context: context));
    context
        .read<PersonBloc>()
        .add(UpdateLanguageUser(languages[_currentIndex]['locale']));

    Navigator.of(context).pop();
  }

  void setDefautLanguage() {
    for (int i = 0; i < langsData.length; i++) {
      final select =
          context.read<ListenLanguageBloc>().locale == langsData[i]['locale'];
      if (select) {
        _currentIndex = i;
      }
      langsData[i].addAll({'select': select});
      languages.add(langsData[i]);
    }
  }

  @override
  void initState() {
    super.initState();
    setDefautLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AigraphyWidget.createAppBar(context: context, title: 'Language'),
      body: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (context, index) {
            return ClickWidget(
              function: () {
                updateLanguage(index);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: spaceCadet, borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.only(
                    left: 24, top: 8, bottom: 8, right: 8),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.asset(
                              languages[index]['image'],
                              width: 32,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            languages[index]['title'],
                            style: style7(color: white),
                          )
                        ],
                      ),
                    ),
                    Checkbox(
                      checkColor: white,
                      activeColor: blue,
                      value: languages[index]['select'],
                      shape: const CircleBorder(),
                      onChanged: (bool? value) {
                        updateLanguage(index);
                      },
                    )
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemCount: languages.length),
    );
  }
}
