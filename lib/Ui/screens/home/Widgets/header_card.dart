import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../../../../utils/ui_utils.dart';
import '../home_screen.dart';

class TitleHeader extends StatelessWidget {
  final String title;
  final String? subTitle;
  final VoidCallback? onSeeAll;
  bool? enableShowAll;
  TitleHeader({super.key, required this.title, this.onSeeAll, this.enableShowAll, this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0, bottom: 16, start: sidePadding, end: sidePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                  ),),
                if(subTitle != null && subTitle != '')
                  Text(subTitle!,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                        fontWeight: FontWeight.w500
                    ),),
              ],
            )

          ),
          if (enableShowAll ?? true)
            GestureDetector(
              onTap: () {
                onSeeAll?.call();
              },
              child: Text(UiUtils.getTranslatedLabel(context, "seeAll",),style: TextStyle(
                  color: Color(0xff117af9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500
              ),)

            )
        ],
      ),
    );
  }
}
