import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/elements/DrawerMenu.dart';
import 'package:flyweb/src/elements/SocialItemMenu.dart';
import 'package:flyweb/src/elements/WebViewElementState.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/menu.dart';
import 'package:flyweb/src/models/setting.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/models/social.dart';
import 'package:flyweb/src/pages/AboutScreen.dart';
import 'package:flyweb/src/pages/LanguageScreen.dart';
import 'package:flyweb/src/pages/NoticiationScreen.dart';
import 'package:flyweb/src/pages/WebScreen.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:launch_review/launch_review.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SideMenuElement extends StatefulWidget {
  Settings settings;
  GlobalKey<WebViewElementState> key0 = GlobalKey();

  SideMenuElement({Key? key, required this.settings, required this.key0})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _SideMenuElement();
  }
}

class _SideMenuElement extends State<SideMenuElement> {
  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);

    var appLanguage = Provider.of<AppLanguage>(context, listen: false);
    var languageCode = appLanguage.appLocal.languageCode;

    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[
                themeProvider.isLightTheme
                    ? HexColor(Setting.getValue(
                        widget.settings.setting!, "firstColor"))
                    : themeProvider.darkTheme.primaryColor,
                themeProvider.isLightTheme
                    ? HexColor(Setting.getValue(
                        widget.settings.setting!, "secondColor"))
                    : themeProvider.darkTheme.primaryColor,
              ])),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 70.0,
                      height: 70.0,
                      child: Image.network(Setting.getValue(
                          widget.settings.setting!, "logo_header")),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(renderLang("title", languageCode),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(renderLang("sub_title", languageCode),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    )
                  ],
                ),
              )),
          _renderMenuDrawer(context, themeProvider)
        ],
      ),
    );
  }

  Widget _renderMenuDrawer(context, themeProvider) {
    var appLanguage = Provider.of<AppLanguage>(context, listen: false);
    var languageCode = appLanguage.appLocal.languageCode;

    return new Column(
      children: widget.settings.menus!
          .map(
            (Menu menu) => menu.type! == "socials"
                ? _renderSocialList(widget.settings.socials!)
                : DrawerMenu(
                    icon_url: menu.iconUrl!,
                    text: renderMenuTitle(menu, languageCode),
                    type: menu.type!,
                    onTap: () async {
                      if (menu.type == "about") {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: AboutScreen(widget.settings)));
                      } else if (menu.type == "notification") {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: NoticiationScreen(widget.settings)));
                      } else if (menu.type == "share") {
                        shareApp(
                            context,
                            renderLang("title", languageCode),
                            Setting.getValue(
                                widget.settings.setting!, "share"));
                      } else if (menu.type == "rate_us") {
                        LaunchReview.launch(
                            androidAppId: Setting.getValue(
                                widget.settings.setting!, "android_id"),
                            iOSAppId: Setting.getValue(
                                widget.settings.setting!, "ios_id"));
                      } else if (menu.type == "languages") {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: LanguageScreen(widget.settings)));
                      } else if (menu.type == "dark") {
                        if (themeProvider.isLightTheme) {
                          themeProvider.setDarkMode();
                        } else {
                          themeProvider.setLightMode();
                        }
                      } else {
                        var url = menu.url;
                        if (menu.type == 'home') {
                          url = renderLang("url", languageCode);
                        }
                        if (menu.type == 'url') {
                          url = renderMenuUrl(menu, languageCode);
                        }
                        if (Setting.getValue(widget.settings.setting!,
                                "tab_navigation_enable") ==
                            "true") {
                          final result = await Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: WebScreen(url!, widget.settings)));
                        } else {
                          widget.key0.currentState!.webViewController?.loadUrl(
                              urlRequest: URLRequest(url: Uri.parse(url!)));

                          Navigator.pop(context);
                        }
                      }
                    }),
          )
          .toList(),
    );
  }

  Widget _renderSocialList(List<Social> socials) {
    return new Wrap(
      children: socials
          .map(
            (Social social) => SocialItemMenu(
                icon_url: social.iconUrl!,
                text: I18n.current!.social(social.title!),
                onTap: () async {
                  if (await canLaunch(
                      social.linkUrl!.replaceAll("id_app", social.idApp!))) {
                    await launch(
                        social.linkUrl!.replaceAll("id_app", social.idApp!));
                  } else {
                    launch(social.url!.replaceAll("id_app", social.idApp!));
                  }
                }),
          )
          .toList(),
    );
  }

  shareApp(BuildContext context, String text, String share) {
    final RenderBox box = context.findRenderObject() as RenderBox;

    Share.share(share,
        subject: text,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  String renderLang(type, languageCode) {
    if (widget.settings.translation[languageCode] != null) {
      if (widget.settings.translation[languageCode] != null)
        return widget.settings.translation[languageCode]![type]!;
    }
    return " ";
  }

  String renderMenuUrl(Menu menu, languageCode) {
    if (menu != null) {
      if (menu.translation[languageCode] != null) {
        return menu.translation[languageCode]!["url"]!;
      }else{
        return menu.url!;
      }
    }else{
      return menu.url!;
    }
    return "";
  }

  String renderMenuTitle(Menu menu, languageCode) {
    if (menu != null) {
        if (menu.translation[languageCode] != null) {
          if (menu.translation[languageCode]!["title"] != "") {
            return menu.translation[languageCode]!["title"]!;
          } else
            return menu.label!;
        } else
          return menu.label!;
    }
    return "";
  }
}
