import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/src/elements/WebViewElementState.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/floating.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/WebScreen.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class FloatingButton extends StatefulWidget {
  Settings settings;
  GlobalKey<WebViewElementState> key0;

  FloatingButton({
    Key? key,
    required this.settings,
    required this.key0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _FloatingButton();
  }
}

class _FloatingButton extends State<FloatingButton> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    bool isLight = themeProvider.isLightTheme;
    Color floating_icon_color = renderColor(
        isLight ? "floating_icon_color" : "floating_icon_color_dark");
    Color floating_background_color = renderColor(isLight
        ? "floating_background_color"
        : "floating_background_color_dark");

    return Setting.getValue(widget.settings.setting!, "floating_enable") == "1"
        ? Container(
            margin: EdgeInsets.only(
                bottom: double.parse(Setting.getValue(
                    widget.settings.setting!, "floating_margin_bottom"))),
            child: SpeedDial(
                child: renderChild(floating_icon_color),
                //activeChild: renderChild(floating_icon_color),
                backgroundColor: floating_background_color,
                foregroundColor: floating_icon_color,
                children: _renderFloating(widget.settings.floating!, context)))
        : Container(height: 0);
  }

  Color renderColor(color) {
    return HexColor(Setting.getValue(widget.settings.setting!, color));
  }

  Widget renderChild(floating_icon_color) {
    return Container(
      width: 18.0,
      height: 18.0,
      child: Image.network(
        Setting.getValue(widget.settings.setting!, "floating_icon"),
        width: 18,
        height: 18,
        color: floating_icon_color,
      ),
    );
  }

  List<SpeedDialChild> _renderFloating(List<Floating> floatings, context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    bool isLight = themeProvider.isLightTheme;
    var appLanguage = Provider.of<AppLanguage>(context);
    var languageCode = appLanguage.appLocal.languageCode;

    return floatings
        .asMap()
        .map((int index, Floating floating) => MapEntry(
              index,
              SpeedDialChild(
                  child: Container(
                    padding: EdgeInsets.all(13.0),
                    child: Image.network(floating.iconUrl!,
                        width: 15,
                        height: 15,
                        color: HexColor(isLight
                            ? floating.icon_color!
                            : floating.icon_color_dark!)),
                  ),
                  label: renderFloatingBy(languageCode, index, 'title'),
                  labelBackgroundColor:  isLight
                      ? Colors.white
                      : Colors.black45,
                  labelStyle: TextStyle(color: isLight
                      ? Colors.black
                      : Colors.white),
                  backgroundColor: HexColor(isLight
                      ? floating.background_color!
                      : floating.background_color_dark!),
                  foregroundColor: HexColor(isLight
                      ? floating.icon_color!
                      : floating.icon_color_dark!),
                  onTap: () async {
                    if (Setting.getValue(widget.settings.setting!,
                            "tab_navigation_enable") ==
                        "true") {
                      /*if (goToWeb) {
                setState(() {
                  goToWeb = false;
                });*/
                      final result = await Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: WebScreen(
                                  renderFloatingBy(languageCode, index, 'url'),
                                  widget.settings)));

                      /*setState(() {
                  goToWeb = true;
                });
              }*/
                    } else {
                      widget.key0.currentState!.webViewController?.loadUrl(
                          urlRequest: URLRequest(
                              url: Uri.parse(renderFloatingBy(
                                  languageCode, index, 'url'))));

                      //Navigator.pop(context);
                    }
                  }),
            ))
        .values
        .toList();
  }

  String renderFloatingBy(languageCode, index, String name) {
    if (widget.settings.floating![index] != null) {
      if (widget.settings.floating![index].translation[languageCode] != null) {
        return widget
            .settings.floating![index].translation[languageCode]![name]!;
      }
    }
    return "";
  }
}
