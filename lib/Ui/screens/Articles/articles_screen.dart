import 'package:flutter/cupertino.dart';
import 'package:Housepecker/Ui/screens/widgets/AnimatedRoutes/blur_page_route.dart'
    show BlurredRouter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart' show Html;

import '../../../app/routes.dart';
import '../../../data/cubits/fetch_articles_cubit.dart';
import '../../../data/model/article_model.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/api.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import '../widgets/Erros/no_data_found.dart';
import '../widgets/Erros/no_internet.dart' show NoInternet;
import '../widgets/Erros/something_went_wrong.dart';
import '../widgets/shimmerLoadingContainer.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const ArticlesScreen();
      },
    );
  }

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {

    context.read<FetchArticlesCubit>().fetchArticles();
    _pageScrollController.addListener(pageScrollListen);
    super.initState();
  }

  void pageScrollListen() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchArticlesCubit>().hasMoreData()) {
        context.read<FetchArticlesCubit>().fetchArticlesMore();
      }
    }
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: context.color.tertiaryColor,
      onRefresh: () async {
        context.read<FetchArticlesCubit>().fetchArticles();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: UiUtils.getTranslatedLabel(
            context,
            "articles",
          ),
        ),
        body: BlocBuilder<FetchArticlesCubit, FetchArticlesState>(
          builder: (context, state) {
            if (state is FetchArticlesInProgress) {
              return buildArticlesShimmer();
            }
            if (state is FetchArticlesFailure) {
              if (state.errorMessage is ApiException) {
                if (state.errorMessage.errorMessage == "no-internet") {
                  return NoInternet(
                    onRetry: () {
                      context.read<FetchArticlesCubit>().fetchArticles();
                    },
                  );
                }
              }
              return const SomethingWentWrong();
            }
            if (state is FetchArticlesSuccess) {
              if (state.articlemodel.isEmpty) {
                return const NoDataFound();
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                        controller: _pageScrollController,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: state.articlemodel.length,
                        itemBuilder: (context, index) {
                          ArticleModel article = state.articlemodel[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: buildArticleCard(context, article),
                          );

                          // return article(state, index);
                        }),
                  ),
                  if (state.isLoadingMore) const CircularProgressIndicator(),
                  if (state.loadingMoreError)
                    Text(UiUtils.getTranslatedLabel(
                        context, "somethingWentWrng"))
                ],
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget buildArticleCard(BuildContext context, ArticleModel article) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.articleDetailsScreenRoute,
          arguments: {
            "model": article,
          },
        );
      },
      child: Container(
        width: double.infinity,
        // height: 290
        padding: EdgeInsets.all( 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent,
          border: Border.all(
            width: 1,
            color: Color(0xffd9d9d9),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: UiUtils.getImage(
                article.image!,
                fit: BoxFit.cover,
                width: 110,
                height: 110,
              ),
            ),
            SizedBox( width: 15,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    (article.title ?? "").firstUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500
                    ),
                  )
                      .color(
                        Color(0xff333333),
                      )
                      .size(13)
                      .setMaxLines(
                        lines: 2,
                      ),
                  SizedBox( height: 7,),
                  Text(stripHtmlTags(article.description ?? "").trim())
                      .setMaxLines(lines: 2)
                      .size(12)
                      .color(Color(0xff7d7d7d)),
                  SizedBox( height: 7,),

                  Text(article.date == null
                          ? ""
                          : article.date.toString())
                      .size(context.font.smaller)
                      .color(context.color.textLightColor),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String strippedString = htmlString.replaceAll(exp, '');
    return strippedString;
  }

  Widget buildArticlesShimmer() {
    return ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                height: 287.rh(context),
                decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    border: Border.all(
                        width: 1.5, color: context.color.borderColor)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomShimmer(
                      width: double.infinity,
                      height: 160.rh(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CustomShimmer(
                        width: 100.rw(context),
                        height: 10.rh(context),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CustomShimmer(
                        width: 160.rw(context),
                        height: 10.rh(context),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CustomShimmer(
                        width: 150.rw(context),
                        height: 10.rh(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Container article(FetchArticlesSuccess state, int index) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 50,
        maxHeight: double.infinity,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(state.articlemodel[index].title!).color(Colors.black),
              const Divider(),
              if (state.articlemodel[index].image != "") ...[
                Image.network(state.articlemodel[index].image!)
              ],
              const Divider(),
              Html(data: state.articlemodel[index].description!)
            ],
          ),
        ),
      ),
    );
  }
}
