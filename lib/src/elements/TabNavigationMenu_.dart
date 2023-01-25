import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
//import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class TabNavigationMenu extends StatefulWidget {
  final Settings settings;
  final List<StreamController<int>> listStream;
  final TabController tabController;
  final int currentIndex;

  const TabNavigationMenu({
    Key? key,
    required this.settings,
    required this.listStream,
    required this.tabController,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TabNavigationMenu();
  }
}

class _TabNavigationMenu extends State<TabNavigationMenu> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    bool isLight = themeProvider.isLightTheme;
    Color tabColorIconActive = renderColor(
        isLight ? "tab_color_icon_active" : "tab_color_icon_active_dark");
    Color tabColorIconInactive = renderColor(
        isLight ? "tab_color_icon_inactive" : "tab_color_icon_inactive_dark");
    Color tabColorBackground = renderColor(
        isLight ? "tab_color_background" : "tab_color_background_dark");

    return Setting.getValue(
        widget.settings.setting!, "tab_navigation_enable") ==
        "true"
        ? Padding(
        padding: const EdgeInsets.all(10),
        child: Material(
            color: tabColorBackground,
            child: Container(
                decoration: BoxDecoration(
                  color: tabColorBackground,
                ),
                height: 43.0,
                child: TabBar(
                    indicatorColor: Colors.green,
                    onTap: (index) {
                      for (int i = 0; i < widget.listStream.length; i++) {
                        widget.listStream[i].add(index);
                      }
                    },
                    /*indicator: RectangularIndicator(
                      bottomLeftRadius: 100,
                      bottomRightRadius: 100,
                      topLeftRadius: 100,
                      topRightRadius: 100,
                    ),*/
                    controller: widget.tabController,
                    labelColor: tabColorIconActive,
                    unselectedLabelColor: tabColorIconInactive,
                    tabs:
                    List.generate(widget.settings.tab!.length, (index) {
                      return Tab(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.network(
                                  widget.settings.tab![index].icon_url!,
                                  width: 28,
                                  height: 28,
                                  color: widget.currentIndex == index
                                      ? tabColorIconActive
                                      : tabColorIconInactive),
                              Flexible(
                                  child: Text(
                                    renderTabTitle(index),
                                    //widget.settings.tab![index].title!,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.getFont(
                                      Setting.getValue(widget.settings.setting!,
                                          "google_font"),
                                      textStyle: TextStyle(
                                          fontSize:
                                          widget.settings.tab!.length == 7
                                              ? 9
                                              : 11,
                                          color: widget.currentIndex == index
                                              ? tabColorIconActive
                                              : tabColorIconInactive),
                                    ),
                                    /* style: TextStyle(
                                          fontSize:
                                              widget.settings.tab!.length == 5
                                                  ? 8
                                                  : 10,
                                          color: widget.currentIndex == index
                                              ? tab_color_icon_active
                                              : tab_color_icon_inactive)*/
                                  )),
                            ]),
                      );
                    })))))
        : Container(height: 0);
  }

  Color renderColor(color) {
    return HexColor(Setting.getValue(widget.settings.setting!, color));
  }

  String renderTabTitle(index) {
    var appLanguage = Provider.of<AppLanguage>(context);
    var languageCode = appLanguage.appLocal.languageCode;
    if (widget.settings.tab![index].translation[languageCode] != null) {
      return widget.settings.tab![index].translation[languageCode]!["title"]!;
    }
    return " ";
  }
}