import 'package:flutter/material.dart';

import '../config/config_color.dart';
import '../config/config_font_styles.dart';
import 'click_widget.dart';

class TextFieldCpn extends StatelessWidget {
  const TextFieldCpn({
    required this.controller,
    required this.focusNode,
    this.labelText,
    this.labelRight,
    this.showSuffixIcon = false,
    this.showPrefixIcon = false,
    this.colorSuffixIcon,
    this.colorPrefixIcon,
    this.suffixIcon,
    this.prefixIcon,
    this.focusNext,
    this.hasMutilLine = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.readOnly = false,
    this.functionPrefix,
    this.functionSuffer,
    this.enabled = true,
    this.hintText,
    this.labelStyle,
    this.autoFocus = false,
    this.filled = true,
    this.fillColor,
    this.borderColor,
    this.onChanged,
    this.onEditingComplete,
    this.suffixWidget,
    this.keyboardType,
    this.inputBorder,
    this.contentPadding,
    this.style,
    this.textAlign,
    Key? key,
  }) : super(key: key);
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? focusNext;
  final String? labelText;
  final Widget? labelRight;
  final bool showSuffixIcon;
  final bool showPrefixIcon;
  final String? prefixIcon;
  final Color? colorPrefixIcon;
  final String? suffixIcon;
  final Widget? suffixWidget;
  final Color? colorSuffixIcon;
  final bool hasMutilLine;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Function()? functionPrefix;
  final Function()? functionSuffer;
  final Function(String)? onChanged;
  final Function()? onEditingComplete;
  final String? hintText;
  final TextStyle? labelStyle;
  final bool autoFocus;
  final bool filled;
  final Color? fillColor;
  final Color? borderColor;
  final TextInputType? keyboardType;
  final InputBorder? inputBorder;
  final double? contentPadding;
  final TextStyle? style;
  final TextAlign? textAlign;

  OutlineInputBorder createInputDecoration(BuildContext context,
      {Color? color}) {
    return OutlineInputBorder(
        borderSide: BorderSide(color: borderColor ?? white),
        borderRadius: BorderRadius.circular(12));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null && inputBorder == null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labelText!,
                style: labelStyle ?? style6(color: white),
              ),
              if (labelRight != null) ...[labelRight!]
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextField(
            textAlignVertical: TextAlignVertical.center,
            textAlign: textAlign ?? TextAlign.start,
            controller: controller,
            focusNode: focusNode,
            maxLines: maxLines ?? (hasMutilLine ? null : 1),
            minLines: minLines,
            readOnly: readOnly,
            maxLength: maxLength,
            autofocus: autoFocus,
            onChanged: onChanged,
            onEditingComplete: onEditingComplete,
            keyboardType: hasMutilLine
                ? TextInputType.multiline
                : (keyboardType ?? TextInputType.text),
            onSubmitted: (value) {
              focusNode.unfocus();
              FocusScope.of(context).requestFocus(focusNext);
            },
            style: style ?? style7(color: white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: style7(color: white),
              fillColor: fillColor ?? white,
              filled: filled,
              contentPadding: EdgeInsets.all(contentPadding ?? 18),
              prefixIcon: showPrefixIcon
                  ? ClickWidget(
                      function: functionPrefix ?? () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: prefixIcon != null
                            ? Image.asset(
                                prefixIcon!,
                                height: 24,
                                width: 24,
                                color: colorPrefixIcon ?? white,
                              )
                            : const SizedBox(),
                      ),
                    )
                  : const SizedBox(),
              prefixIconConstraints: const BoxConstraints(
                minHeight: 16,
                minWidth: 16,
              ),
              suffixIcon: showSuffixIcon
                  ? Padding(
                      padding:
                          const EdgeInsets.only(left: 8, top: 12, right: 4),
                      child: suffixWidget ??
                          ClickWidget(
                            function: functionSuffer ?? () {},
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: suffixIcon != null
                                  ? Image.asset(
                                      suffixIcon!,
                                      height: 24,
                                      width: 24,
                                      color: colorSuffixIcon ?? blue,
                                    )
                                  : const SizedBox(),
                            ),
                          ),
                    )
                  : const SizedBox(),
              suffixIconConstraints: const BoxConstraints(
                minHeight: 16,
                minWidth: 16,
              ),
              focusedBorder:
                  inputBorder ?? createInputDecoration(context, color: white),
              enabledBorder: inputBorder ?? createInputDecoration(context),
              errorBorder:
                  inputBorder ?? createInputDecoration(context, color: red1),
              enabled: enabled,
            )),
      ],
    );
  }
}
