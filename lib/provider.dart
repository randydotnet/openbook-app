import 'package:Openbook/pages/auth/create_account/blocs/create_account.dart';
import 'package:Openbook/services/auth_api.dart';
import 'package:Openbook/services/bottom_sheet.dart';
import 'package:Openbook/services/categories_api.dart';
import 'package:Openbook/services/communities_api.dart';
import 'package:Openbook/services/connections_circles_api.dart';
import 'package:Openbook/services/connections_api.dart';
import 'package:Openbook/services/date_picker.dart';
import 'package:Openbook/services/devices_api.dart';
import 'package:Openbook/services/dialog.dart';
import 'package:Openbook/services/intercom.dart';
import 'package:Openbook/services/notifications_api.dart';
import 'package:Openbook/services/push_notifications/push_notifications.dart';
import 'package:Openbook/services/universal_links/universal_links.dart';
import 'package:Openbook/services/emoji_picker.dart';
import 'package:Openbook/services/emojis_api.dart';
import 'package:Openbook/services/environment_loader.dart';
import 'package:Openbook/services/follows_api.dart';
import 'package:Openbook/services/httpie.dart';
import 'package:Openbook/services/image_picker.dart';
import 'package:Openbook/services/follows_lists_api.dart';
import 'package:Openbook/services/localization.dart';
import 'package:Openbook/services/modal_service.dart';
import 'package:Openbook/services/navigation_service.dart';
import 'package:Openbook/services/posts_api.dart';
import 'package:Openbook/services/storage.dart';
import 'package:Openbook/services/string_template.dart';
import 'package:Openbook/services/theme.dart';
import 'package:Openbook/services/theme_value_parser.dart';
import 'package:Openbook/services/toast.dart';
import 'package:Openbook/services/url_launcher.dart';
import 'package:Openbook/services/user.dart';
import 'package:Openbook/services/utils_service.dart';
import 'package:Openbook/services/validation.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';

// TODO Waiting for dependency injection support
// https://github.com/flutter/flutter/issues/21980

class OpenbookProvider extends StatefulWidget {
  final Widget child;

  const OpenbookProvider({Key key, @required this.child}) : super(key: key);

  @override
  OpenbookProviderState createState() {
    return OpenbookProviderState();
  }

  static OpenbookProviderState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_OpenbookProvider)
            as _OpenbookProvider)
        .data;
  }
}

class OpenbookProviderState extends State<OpenbookProvider> {
  CreateAccountBloc createAccountBloc = CreateAccountBloc();
  ValidationService validationService = ValidationService();
  HttpieService httpService = HttpieService();
  AuthApiService authApiService = AuthApiService();
  PostsApiService postsApiService = PostsApiService();
  StorageService storageService = StorageService();
  UserService userService = UserService();
  ToastService toastService = ToastService();
  StringTemplateService stringTemplateService = StringTemplateService();
  EmojisApiService emojisApiService = EmojisApiService();
  ThemeService themeService = ThemeService();
  ImagePickerService imagePickerService = ImagePickerService();
  DatePickerService datePickerService = DatePickerService();
  EmojiPickerService emojiPickerService = EmojiPickerService();
  FollowsApiService followsApiService = FollowsApiService();
  CommunitiesApiService communitiesApiService = CommunitiesApiService();
  CategoriesApiService categoriesApiService = CategoriesApiService();
  NotificationsApiService notificationsApiService = NotificationsApiService();
  DevicesApiService devicesApiService = DevicesApiService();
  ConnectionsApiService connectionsApiService = ConnectionsApiService();
  ConnectionsCirclesApiService connectionsCirclesApiService =
      ConnectionsCirclesApiService();
  FollowsListsApiService followsListsApiService = FollowsListsApiService();
  ThemeValueParserService themeValueParserService = ThemeValueParserService();
  ModalService modalService = ModalService();
  NavigationService navigationService = NavigationService();

  LocalizationService localizationService;
  UniversalLinksService universalLinksService = UniversalLinksService();
  BottomSheetService bottomSheetService = BottomSheetService();
  PushNotificationsService pushNotificationsService =
      PushNotificationsService();
  UrlLauncherService urlLauncherService = UrlLauncherService();
  IntercomService intercomService = IntercomService();
  DialogService dialogService = DialogService();
  UtilsService utilsService = UtilsService();

  SentryClient sentryClient;

  @override
  void initState() {
    super.initState();
    initAsyncState();
    imageCache.maximumSize = 200 << 20; // 200MB
    connectionsCirclesApiService.setHttpService(httpService);
    httpService.setUtilsService(utilsService);
    connectionsCirclesApiService
        .setStringTemplateService(stringTemplateService);
    communitiesApiService.setHttpieService(httpService);
    communitiesApiService.setStringTemplateService(stringTemplateService);
    followsListsApiService.setHttpService(httpService);
    followsListsApiService.setStringTemplateService(stringTemplateService);
    connectionsApiService.setHttpService(httpService);
    authApiService.setHttpService(httpService);
    followsApiService.setHttpService(httpService);
    createAccountBloc.setAuthApiService(authApiService);
    createAccountBloc.setUserService(userService);
    userService.setAuthApiService(authApiService);
    userService.setPostsApiService(postsApiService);
    userService.setEmojisApiService(emojisApiService);
    userService.setHttpieService(httpService);
    userService.setStorageService(storageService);
    userService.setFollowsApiService(followsApiService);
    userService.setFollowsListsApiService(followsListsApiService);
    userService.setConnectionsApiService(connectionsApiService);
    userService.setConnectionsCirclesApiService(connectionsCirclesApiService);
    userService.setCommunitiesApiService(communitiesApiService);
    userService.setCategoriesApiService(categoriesApiService);
    userService.setNotificationsApiService(notificationsApiService);
    userService.setDevicesApiService(devicesApiService);
    userService.setCreateAccountBlocService(createAccountBloc);
    emojisApiService.setHttpService(httpService);
    categoriesApiService.setHttpService(httpService);
    postsApiService.setHttpieService(httpService);
    postsApiService.setStringTemplateService(stringTemplateService);
    notificationsApiService.setHttpService(httpService);
    notificationsApiService.setStringTemplateService(stringTemplateService);
    devicesApiService.setHttpService(httpService);
    devicesApiService.setStringTemplateService(stringTemplateService);
    validationService.setAuthApiService(authApiService);
    validationService.setFollowsListsApiService(followsListsApiService);
    validationService.setCommunitiesApiService(communitiesApiService);
    validationService
        .setConnectionsCirclesApiService(connectionsCirclesApiService);
    themeService.setStorageService(storageService);
    pushNotificationsService.setUserService(userService);
    intercomService.setUserService(userService);
    dialogService.setThemeService(themeService);
    dialogService.setThemeValueParserService(themeValueParserService);
  }

  void initAsyncState() async {
    Environment environment =
        await EnvironmentLoader(environmentPath: ".env.json").load();
    httpService.setMagicHeader(
        environment.magicHeaderName, environment.magicHeaderValue);
    authApiService.setApiURL(environment.apiUrl);
    postsApiService.setApiURL(environment.apiUrl);
    emojisApiService.setApiURL(environment.apiUrl);
    followsApiService.setApiURL(environment.apiUrl);
    connectionsApiService.setApiURL(environment.apiUrl);
    connectionsCirclesApiService.setApiURL(environment.apiUrl);
    followsListsApiService.setApiURL(environment.apiUrl);
    communitiesApiService.setApiURL(environment.apiUrl);
    categoriesApiService.setApiURL(environment.apiUrl);
    notificationsApiService.setApiURL(environment.apiUrl);
    devicesApiService.setApiURL(environment.apiUrl);
    intercomService.bootstrap(
        iosApiKey: environment.intercomIosKey,
        androidApiKey: environment.intercomAndroidKey,
        appId: environment.intercomAppId);

    sentryClient = SentryClient(dsn: environment.sentryDsn);
  }

  @override
  Widget build(BuildContext context) {
    return new _OpenbookProvider(
      data: this,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    universalLinksService.dispose();
    pushNotificationsService.dispose();
  }

  setLocalizationService(LocalizationService newLocalizationService) {
    localizationService = newLocalizationService;
    createAccountBloc.setLocalizationService(localizationService);
    httpService.setLocalizationService(localizationService);
  }

  setValidationService(ValidationService newValidationService) {
    validationService = newValidationService;
  }
}

class _OpenbookProvider extends InheritedWidget {
  final OpenbookProviderState data;

  _OpenbookProvider({Key key, this.data, Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_OpenbookProvider old) {
    return true;
  }
}
