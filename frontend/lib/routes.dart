import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:qr_app/helper/services/auth_services.dart';
import 'package:qr_app/views/screen/inventory_check.dart';
import 'package:qr_app/views/screen/produce/detail.dart';
import 'package:qr_app/views/screen/produce/list.dart';
import 'package:qr_app/views/screen/setting/index.dart';
import 'package:qr_app/views/screen/auth/login_screen.dart';
import 'package:qr_app/views/screen/stocktake/detail.dart';
import 'package:qr_app/views/screen/stocktake/list.dart';
import 'package:qr_app/views/ui/calendar_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/accordions_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/alerts_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/avatar_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/badges_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/breadcrumb_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/buttons_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/cards_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/carousel_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/collapse_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/dropdowns_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/embed_video_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/links_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/list_group_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/modals_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/notifications_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/pagination_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/placeholders_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/progress_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/spinners_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/tabs_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/tool_tip_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/typography_screen.dart';
import 'package:qr_app/views/ui/components/base_ui/utilities_screen.dart';
import 'package:qr_app/views/ui/components/chart_screen.dart';
import 'package:qr_app/views/ui/components/extended_ui/portlets_screen.dart';
import 'package:qr_app/views/ui/components/extended_ui/range_slider_screen.dart';
import 'package:qr_app/views/ui/components/extended_ui/scroll_bar_screen.dart';
import 'package:qr_app/views/ui/components/forms/basic_element_screen.dart';
import 'package:qr_app/views/ui/components/forms/file_uploads_screen.dart';
import 'package:qr_app/views/ui/components/forms/form_editor_screen.dart';
import 'package:qr_app/views/ui/components/forms/form_validation_screen.dart';
import 'package:qr_app/views/ui/components/forms/form_wizard_screen.dart';
import 'package:qr_app/views/ui/components/forms/x_editable_screen.dart';
import 'package:qr_app/views/ui/components/icon/remix_icon_screen.dart';
import 'package:qr_app/views/ui/components/map_screen.dart';
import 'package:qr_app/views/ui/components/table_screen.dart';
import 'package:qr_app/views/ui/email/email_compose_screen.dart';
import 'package:qr_app/views/ui/email/email_read_screen.dart';
import 'package:qr_app/views/ui/email/inbox_screen.dart';
import 'package:qr_app/views/ui/utilities/coming_soon_screen.dart';
import 'package:qr_app/views/ui/utilities/error_404_screen.dart';
import 'package:qr_app/views/ui/utilities/error_500_screen.dart';
import 'package:qr_app/views/ui/utilities/faqs_screen.dart';
import 'package:qr_app/views/ui/utilities/maintenance_screen.dart';
import 'package:qr_app/views/ui/utilities/pricing_screen.dart';
import 'package:qr_app/views/ui/utilities/starter_page_screen.dart';
import 'package:qr_app/views/ui/utilities/timeline_screen.dart';
import 'package:qr_app/views/ui/dashboard_screen.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return AuthService.isLoggedIn
        ? null
        : const RouteSettings(name: '/auth/login');
  }
}

List<GetPage> getPageRoute() {
  var routes = [
    GetPage(name: '/auth/login', page: () => LoginScreen()),
    GetPage(name: '/produce-list', page: () => ProduceListScreen()),
    GetPage(name: '/produce-detail', page: () => ProduceDetailScreen()),
    GetPage(name: '/inventory-check', page: () => InventoryCheckScreen()),
    GetPage(name: '/stocktake-list', page: () => StockTakeListScreen()),
    GetPage(name: '/stocktake-detail', page: () => StockTakeDetailScreen()),
    GetPage(name: '/setting', page: () => SettingScreen()),

    // Utilities - Cũ
    GetPage(
      name: '/utilities/starter',
      page: () => StarterPageScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/utilities/maintenance',
      page: () => MaintenanceScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/utilities/coming_soon',
      page: () => ComingSoonScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/utilities/time_line',
      page: () => TimelineScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/utilities/faqs',
      page: () => FaqsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/utilities/pricing',
      page: () => PricingScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/utilities/page-404',
      page: () => Error404Screen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/utilities/page-500',
      page: () => Error500Screen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: '/email/inbox',
      page: () => InboxScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/email/read',
      page: () => EmailReadScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/email/compose',
      page: () => EmailComposeScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/dashboard',
      page: () => DashboardScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/app/calendar',
      page: () => CalendarScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/accordions',
      page: () => AccordionsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/alerts',
      page: () => AlertsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/avatar',
      page: () => AvatarScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/button',
      page: () => ButtonsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/badges',
      page: () => BadgesScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/breadcrumb',
      page: () => BreadcrumbScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/card',
      page: () => CardsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/carousel',
      page: () => CarouselScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/collapse',
      page: () => CollapseScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/dropdown',
      page: () => DropdownsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/embed_video',
      page: () => EmbedVideoScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/links',
      page: () => LinksScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/list_group',
      page: () => ListGroupScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/modals',
      page: () => ModalsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/notification',
      page: () => NotificationsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/placeholders',
      page: () => PlaceholdersScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/pagination',
      page: () => PaginationScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/progress',
      page: () => ProgressScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/spinner',
      page: () => SpinnersScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/tab',
      page: () => TabsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/tooltip',
      page: () => ToolTipScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/typography',
      page: () => TypographyScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/components/utilities',
      page: () => UtilitiesScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/extended_ui/range_slider',
      page: () => RangeSliderScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/extended_ui/scrollbar',
      page: () => ScrollBarScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/extended_ui/portlets',
      page: () => PortletsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/icon/remix_icon',
      page: () => RemixIconScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/chart',
      page: () => ChartScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/table',
      page: () => TableScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/maps',
      page: () => MapScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/forms/basic_element',
      page: () => BasicElementScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/forms/validation',
      page: () => FormValidationScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/forms/file_upload',
      page: () => FileUploadsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/forms/form_editors',
      page: () => FormEditorScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/forms/x_editable',
      page: () => XEditableScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: '/forms/form_wizard',
      page: () => FormWizardScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
  return routes
      .map(
        (e) => GetPage(
          name: e.name,
          page: e.page,
          middlewares: e.middlewares,
          transition: Transition.noTransition,
        ),
      )
      .toList();
}
