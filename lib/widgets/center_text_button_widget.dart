// ignore_for_file: must_be_immutable

import 'package:crud/utils/colors_utils.dart';
import 'package:crud/widgets/bounce_click_widget.dart';
import 'package:crud/utils/font_utils.dart';
import 'package:flutter/material.dart';

class CenterTextButtonWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final String? title;
  final TextStyle? style;
  final VoidCallback? onTap;
  final List<Color>? gradientColor;
  final double? elevation;
  final Color? titleColor;
  Color? color;
  CenterTextButtonWidget({
    Key? key,
    this.height,
    this.width,
    this.title,
    this.style,
    this.gradientColor,
    this.onTap,
    this.elevation,
    this.color,
    this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return BounceClickWidget(
      onTap: onTap,
      child: Card(
        elevation: elevation ?? 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Container(
          height: height ?? 54,
          width: width ?? screenSize.width * 0.92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: color ?? ColorUtils.redColor,
            gradient: LinearGradient(
              colors: gradientColor ?? [ ColorUtils.oXFF6750A4,  ColorUtils.oXFF6750A4],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Center(
            child: Text(
              title ?? '',
              style: style ??
                  FontUtils.h22(
                    fontColor: titleColor ?? ColorUtils.whiteColor,
                    fontWeight: FWT.bold,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
