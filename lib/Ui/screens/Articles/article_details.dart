import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/model/article_model.dart';
import '../../../settings.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import '../widgets/AnimatedRoutes/blur_page_route.dart';

class ArticleDetails extends StatelessWidget {
  final ArticleModel article;
  final String title;

  const ArticleDetails({super.key, required this.article, required this.title});
  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map;
    return BlurredRouter(
      builder: (context) {
        return ArticleDetails(
          article: arguments['model'], title: arguments['title'],
        );
      },
    );
  }

  share(String slugId, BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: context.color.backgroundColor,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text("copylink".translate(context)),
              onTap: () async {
                String deepLink = "https://${AppSettings.shareNavigationWebUrl}/blog-details/$slugId";

                await Clipboard.setData(ClipboardData(text: deepLink));

                Future.delayed(Duration.zero, () {
                  Navigator.pop(context);
                  HelperUtils.showSnackBarMessage(
                      context, "copied".translate(context));
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text("share".translate(context)),
              onTap: () async {
                String deepLink = "https://${AppSettings.shareNavigationWebUrl}/blog-details/$slugId";

                String text =
                    "Exciting find! 🏡 Check out this amazing property I came across.  Let me know what you think! ⭐\n Here are the details:\n$deepLink.";
                await Share.share(text);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(
        title: title,
        context,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(
            15.0,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(article.date.toString())
                      .size(context.font.small)
                      .color(Color(0xff6b6b6b)),
                  Text('Admin')
                      .size(context.font.small)
                      .color(Color(0xff6b6b6b)),
                ],
              ),
              Divider(thickness: 1, color: Color(0xffdddddd),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Share: ')
                      .size(context.font.small)
                      .color(Color(0xff6b6b6b)),
                  InkWell(
                    onTap: () {
                      share(article.slug ?? "", context);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.color.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromARGB(33, 0, 0, 0),
                              offset: Offset(0, 2),
                              blurRadius: 15,
                              spreadRadius: 0)
                        ],
                      ),
                      child: Icon(
                        Icons.share,
                        color: context.color.tertiaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(thickness: 1, color: Color(0xffdddddd),),
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
