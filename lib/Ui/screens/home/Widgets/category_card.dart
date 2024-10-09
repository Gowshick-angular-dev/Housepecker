import 'package:flutter/cupertino.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:Housepecker/utils/responsiveSize.dart';
import 'package:flutter/material.dart';

import '../../../../data/helper/design_configs.dart';
import '../../../../data/model/category.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/ui_utils.dart';

class CategoryCard extends StatelessWidget {
  final bool? frontSpacing;
  final Function(Category category) onTapCategory;
  final Category category;
  const CategoryCard(
      {super.key,
      required this.frontSpacing,
      required this.onTapCategory,
      required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTapCategory.call(category);
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width/4.9,
        decoration: BoxDecoration(
          color: Color(0xff117af9).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Color(0xfff0f0f0),
              offset: Offset(0, 2),
              blurRadius: 2.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(
                child: UiUtils.imageType(category.image!,
                    width: 35,
                    height: 35,
                    fit: BoxFit.cover,
                    color: Constant.adaptThemeColorSvg
                        ? context.color.tertiaryColor
                        : null),
              ),
              SizedBox(height: 5),
              SizedBox(
                child: Text(category.category!,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff333333)
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
