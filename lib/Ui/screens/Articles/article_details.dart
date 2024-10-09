import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../data/model/article_model.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';

class ArticleDetails extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetails({super.key, required this.article});
  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map;
    return BlurredRouter(
      builder: (context) {
        return ArticleDetails(
          article: arguments['model'],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(
            20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width,
                child: ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                  child: UiUtils.getImage(
                    article.image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 15.rh(context),
              ),

              Text(
                (article.title ?? "").firstUpperCase(),
              )
                  .size(
                   17,
                  )
                  .color(Color(0xff333333))
                  .bold(
                    weight: FontWeight.w500,
                  ),
              const SizedBox(
                height: 12,
              ),
              Text(article.date.toString())
                  .size(context.font.small)
                  .color(Color(0xff6b6b6b)),

              SizedBox(
                height: 4.rh(context),
              ),
              Html(data: article.description ?? "")
            ],
          ),
        ),
      ),
    );
  }
}
