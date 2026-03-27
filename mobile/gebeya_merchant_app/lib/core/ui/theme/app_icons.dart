import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Semantic aliases for app icons.
/// Usage: Icon(AppIcons.dashboard)
abstract final class AppIcons {
  // Navigation
  static const IconData dashboard = LucideIcons.layoutDashboard;
  static const IconData products = LucideIcons.package;
  static const IconData inventory = LucideIcons.warehouse;
  static const IconData sales = LucideIcons.scrollText;
  static const IconData more = LucideIcons.moreHorizontal;

  // Common Actions
  static const IconData add = LucideIcons.plus;
  static const IconData edit = LucideIcons.pencil;
  static const IconData delete = LucideIcons.trash2;
  static const IconData search = LucideIcons.search;
  static const IconData filter = LucideIcons.filter;
  static const IconData close = LucideIcons.x;
  static const IconData back = LucideIcons.chevronLeft;
  static const IconData forward = LucideIcons.chevronRight;
  static const IconData check = LucideIcons.check;
  static const IconData dropdown = LucideIcons.chevronDown;
  static const IconData download = LucideIcons.download;
  static const IconData swap = LucideIcons.arrowLeftRight;
  static const IconData visibility = LucideIcons.eye;
  static const IconData visibilityOff = LucideIcons.eyeOff;

  // Features & Objects
  static const IconData user = LucideIcons.user;
  static const IconData location = LucideIcons.mapPin;
  static const IconData business = LucideIcons.building;
  static const IconData store = LucideIcons.store;
  static const IconData settings = LucideIcons.settings;
  static const IconData logout = LucideIcons.logOut;
  static const IconData calendar = LucideIcons.calendar;
  static const IconData time = LucideIcons.clock;
  static const IconData money = LucideIcons.dollarSign;
  static const IconData warning = LucideIcons.alertTriangle;
  static const IconData email = LucideIcons.mail;
  static const IconData lock = LucideIcons.lock;
  static const IconData rocket = LucideIcons.rocket;
  static const IconData star = LucideIcons.star;

  // Dashboard & Analytics
  static const IconData trendingUp = LucideIcons.trendingUp;
  static const IconData trendingDown = LucideIcons.trendingDown;
  static const IconData chart = LucideIcons.lineChart;
  static const IconData analytics = LucideIcons.barChart3;
  static const IconData percent = LucideIcons.percent;
  static const IconData receipt = LucideIcons.receipt;
}
