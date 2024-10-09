part of '../personalized_property_screen.dart';

class CategoryInterestChoose extends StatefulWidget {
  final PageController controller;
  final PersonalizedVisitType type;
  final Function(List<int> selectedCategoryId) onInteraction;
  const CategoryInterestChoose(
      {super.key,
      required this.controller,
      required this.onInteraction,
      required this.type});

  @override
  State<CategoryInterestChoose> createState() => _CategoryInterestChooseState();
}

class _CategoryInterestChooseState extends State<CategoryInterestChoose>
    with AutomaticKeepAliveClientMixin {
  List<int> selectedCategoryId = personalizedInterestSettings.categoryIds;

  @override
  Widget build(BuildContext context) {
    bool isFirstTime = widget.type == PersonalizedVisitType.FirstTime;
    super.build(context);
    return Column(
      children: [

        Container(
          padding: EdgeInsets.all(20),
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xfff6faff),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Choose Your".translate(context))
                      .color(context.color.textColorDark)
                      .size(17)
                      .centerAlign(),
                  Text("Interest".translate(context))
                      .color(context.color.textColorDark)
                      .size(17)
                      .centerAlign(),

                ],
              ),
              Spacer(
                flex: isFirstTime ? 1 : 2,
              ),
              if (isFirstTime)
                GestureDetector(
                    onTap: () {
                      HelperUtils.killPreviousPages(
                          context, Routes.main, {"from": "login"});
                    },
                    child: Chip(
                        label: Text("skip".translate(context))
                            .color(context.color.buttonColor))),

            ],
          ),
        ),

        const SizedBox(
          height: 25,
        ),
        Wrap(
          children: List.generate(
              (context.watch<FetchCategoryCubit>().getCategories().length),
              (index) {
            Category categorie =
                context.watch<FetchCategoryCubit>().getCategories()[index];
            bool isSelected =
                selectedCategoryId.contains(int.parse(categorie.id!));
            return Padding(
              padding: const EdgeInsets.all(3.0),
              child: GestureDetector(
                onTap: () {
                  selectedCategoryId.addOrRemove(int.parse(categorie.id!));
                  widget.onInteraction.call(selectedCategoryId);
                  setState(() {});
                },
                child: Chip(
                    shape: StadiumBorder(
                        side: BorderSide(color: isSelected
                            ? Color(0xffffa920)
                            : Color(0xffd9d9d9))),
                    backgroundColor: isSelected
                        ? Color(0xfffffbf3)
                        : Color(0xfff2f2f2),
                    padding: const EdgeInsets.all(5),
                    label: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(categorie.category.toString(),style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 13,
                      ),)
                    )),
              ),
            );
          }),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
