import 'package:aigraphy_flutter/app/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc/listen_language/bloc_listen_language.dart';
import '../../common/bloc/user/bloc_user.dart';
import '../../common/constant/colors.dart';
import '../../common/constant/helper.dart';
import '../../common/constant/styles.dart';
import '../../common/widget/animation_click.dart';

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
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
        .read<UserBloc>()
        .add(UpdateLanguageUser(languages[_currentIndex]['locale']));

    Navigator.of(context).pop();
  }

  void setDefautLanguage() {
    for (int i = 0; i < languagesData.length; i++) {
      final select = context.read<ListenLanguageBloc>().locale ==
          languagesData[i]['locale'];
      if (select) {
        _currentIndex = i;
      }
      languagesData[i].addAll({'select': select});
      languages.add(languagesData[i]);
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
      appBar: AppWidget.createSimpleAppBar(context: context, title: 'Language'),
      body: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (context, index) {
            return AnimationClick(
              function: () {
                updateLanguage(index);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: grey200, borderRadius: BorderRadius.circular(16)),
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
                            style: body(color: grey1100),
                          )
                        ],
                      ),
                    ),
                    Checkbox(
                      checkColor: grey1100,
                      activeColor: primary,
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
