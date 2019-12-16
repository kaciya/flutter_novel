import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_novel/app/novel/entity/entity_novel_book_review.dart';
import 'package:flutter_novel/app/novel/entity/entity_novel_detail.dart';
import 'package:flutter_novel/app/novel/entity/entity_novel_short_comment.dart';
import 'package:flutter_novel/app/novel/view/widget/novel_book_intro_appbar_header_view.dart';
import 'package:flutter_novel/app/novel/view/widget/novel_book_intro_bottom_menu_view.dart';
import 'package:flutter_novel/app/novel/view/widget/novel_book_intro_header_tag_view.dart';
import 'package:flutter_novel/app/novel/view/widget/novel_book_intro_short_comment_view.dart';
import 'package:flutter_novel/app/novel/view_model/view_model_novel_intro.dart';
import 'package:flutter_novel/base/structure/base_view.dart';
import 'package:flutter_novel/base/structure/base_view_model.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart' hide NestedScrollView;

class NovelBookIntroView extends BaseStatefulView<NovelBookIntroViewModel> {
  @override
  BaseStatefulViewState<BaseStatefulView<BaseViewModel>,
      NovelBookIntroViewModel> buildState() {
    return _NovelBookIntroViewState();
  }
}

class _NovelBookIntroViewState
    extends BaseStatefulViewState<NovelBookIntroView, NovelBookIntroViewModel> {
  Color bgStartColor;
  Color bgNormalColor;
  Color bgEndColor;

  @override
  Widget buildView(BuildContext context, NovelBookIntroViewModel viewModel) {
    var pinnedHeaderHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;
    NovelDetailInfo detailInfo = viewModel?.contentEntity?.detailInfo;
    NovelShortComment commentInfo = viewModel?.contentEntity?.shortComment;
    NovelBookReview bookReview= viewModel?.contentEntity?.bookReviewInfo;

    if ((bgEndColor == null || bgEndColor == null) &&
        detailInfo?.cover != null) {
      initPageTopColor(
              Uri.decodeComponent(detailInfo.cover.split("/agent/").last))
          .then((data) {
        setState(() {
          bgStartColor = data?.lightVibrantColor?.color ?? Colors.white;
          bgNormalColor = data?.dominantColor?.color ?? Colors.white;
          bgEndColor = data?.darkMutedColor?.color ?? Colors.grey[300];
        });
      });
    }

    return Scaffold(
      body: NestedScrollView(pinnedHeaderSliverHeightBuilder: () {
        return pinnedHeaderHeight;
      }, headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return _headerSliverBuilder(context, detailInfo);
      }, body: Builder(builder: (context) {
        return Material(
          color: Colors.grey[350],
          child: Container(
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    NovelIntroShortCommentView(commentInfo)
                  ],
                ),
                NovelIntroBottomMenuView()
              ],
            ),
          ),
        );
      })),
    );
  }

  @override
  NovelBookIntroViewModel buildViewModel(BuildContext context) {
    return NovelBookIntroViewModel(Provider.of(context));
  }

  @override
  void initData() {}

  @override
  void loadData(BuildContext context, NovelBookIntroViewModel viewModel) {
    viewModel.getNovelInfo("592fe687c60e3c4926b040ca");
  }

  List<Widget> _headerSliverBuilder(
      BuildContext context, NovelDetailInfo detailInfo) {
    List<Widget> headerContentList = [
      /// 头部折叠介绍页
      SliverAppBar(
        //1.在标题左侧显示的一个控件，在首页通常显示应用的 logo；在其他界面通常显示为返回按钮
        leading: Icon(Icons.arrow_back),
        title: Text(detailInfo?.title ?? "正在查询"),
        backgroundColor: bgStartColor ?? Colors.white,
        flexibleSpace: FlexibleSpaceBar(
          background:
              NovelIntroAppBarHeaderView(detailInfo, bgStartColor, bgEndColor),
        ),
        expandedHeight: 240,
        centerTitle: true,
        pinned: true,
        floating: false,
        snap: false,
      ),

      /// 标签以及简介
      SliverToBoxAdapter(
        child: Builder(builder: (context) {
          if (detailInfo == null) {
            return Container(
              child: Text("正在加载中"),
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
            );
          } else {
            return NovelBookIntroHeaderTagView(detailInfo);
          }
        }),
      )
    ];

    return headerContentList;
  }

  Future<PaletteGenerator> initPageTopColor(String imgPath) async {
    PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
            CachedNetworkImageProvider(imgPath));
    return paletteGenerator;
  }
}
