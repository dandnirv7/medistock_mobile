import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Centralized Lucide icon references for the MediStock app.
///
/// All UI icons must be obtained through [AppIcons] so the look is
/// consistent across the app and unknown icon names never throw.
class AppIcons {
  AppIcons._();

  // -- Domain icons --
  static const IconData dashboard = LucideIcons.layoutDashboard;
  static const IconData medicines = LucideIcons.pill;
  static const IconData categories = LucideIcons.tags;
  static const IconData suppliers = LucideIcons.truck;
  static const IconData stockIn = LucideIcons.arrowDownToLine;
  static const IconData stockOut = LucideIcons.arrowUpFromLine;
  static const IconData stockMovements = LucideIcons.arrowRightLeft;
  static const IconData stockLevels = LucideIcons.boxes;
  static const IconData lowStock = LucideIcons.alertTriangle;
  static const IconData expired = LucideIcons.calendarClock;
  static const IconData expiringSoon = LucideIcons.clock;
  static const IconData safe = LucideIcons.checkCircle;
  static const IconData alerts = LucideIcons.bell;
  static const IconData profile = LucideIcons.user;

  // -- Action / state icons --
  static const IconData empty = LucideIcons.inbox;
  static const IconData errorIcon = LucideIcons.triangle;
  static const IconData retry = LucideIcons.refreshCw;
  static const IconData add = LucideIcons.plus;
  static const IconData remove = LucideIcons.minus;
  static const IconData close = LucideIcons.x;
  static const IconData search = LucideIcons.search;
  static const IconData filter = LucideIcons.slidersHorizontal;
  static const IconData edit = LucideIcons.pencil;
  static const IconData delete = LucideIcons.trash;
  static const IconData save = LucideIcons.save;
  static const IconData check = LucideIcons.check;
  static const IconData info = LucideIcons.info;
  static const IconData question = LucideIcons.helpCircle;
  static const IconData verified = LucideIcons.badgeCheck;
  static const IconData schedule = LucideIcons.clock;
  static const IconData calendar = LucideIcons.calendar;
  static const IconData calendarToday = LucideIcons.calendarDays;
  static const IconData swapHoriz = LucideIcons.arrowRightLeft;
  static const IconData swapVert = LucideIcons.moveVertical;

  // -- Navigation icons --
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData chevronLeft = LucideIcons.chevronLeft;
  static const IconData chevronDown = LucideIcons.chevronDown;
  static const IconData chevronUp = LucideIcons.chevronUp;
  static const IconData arrowDownward = LucideIcons.arrowDown;
  static const IconData arrowUpward = LucideIcons.arrowUp;
  static const IconData arrowRight = LucideIcons.arrowRight;
  static const IconData arrowLeft = LucideIcons.arrowLeft;
  static const IconData arrowRightLeft = LucideIcons.arrowRightLeft;

  // -- Inventory / medicine --
  static const IconData medication = LucideIcons.pill;
  static const IconData medicalServices = LucideIcons.stethoscope;
  static const IconData syringe = LucideIcons.syringe;
  static const IconData package = LucideIcons.package;
  static const IconData barcode = LucideIcons.qrCode;
  static const IconData boxes = LucideIcons.boxes;
  static const IconData warehouse = LucideIcons.warehouse;

  // -- Form / input --
  static const IconData visibility = LucideIcons.eye;
  static const IconData visibilityOff = LucideIcons.eyeOff;
  static const IconData lock = LucideIcons.lock;
  static const IconData call = LucideIcons.phone;
  static const IconData message = LucideIcons.messageCircle;
  static const IconData email = LucideIcons.mail;
  static const IconData note = LucideIcons.stickyNote;

  // -- Profile / app --
  static const IconData person = LucideIcons.user;
  static const IconData logout = LucideIcons.logOut;
  static const IconData settings = LucideIcons.settings;
  static const IconData security = LucideIcons.shieldCheck;
  static const IconData flag = LucideIcons.flag;
  static const IconData history = LucideIcons.history;
  static const IconData categoryOutlined = LucideIcons.tag;
  static const IconData localShipping = LucideIcons.truck;

  // -- Generic fallback --
  /// Always-valid fallback glyph used when an icon name is unknown/null.
  static const IconData fallback = LucideIcons.circleDot;

  // -- Flutter-style aliases (so old Icons.* references map 1:1) --
  // Each alias preserves the prior public name but routes through a
  // Lucide glyph. The unused-icon warning is suppressed because some
  // aliases are only referenced by string keys (byName) or in tests.
  // ignore: unused_field
  static const IconData accountCircleOutlined = LucideIcons.userCircle;
  // ignore: unused_field
  static const IconData dashboardOutlined = LucideIcons.layoutDashboard;
  // ignore: unused_field
  static const IconData medicalServicesOutlined = LucideIcons.stethoscope;
  // ignore: unused_field
  static const IconData medicationOutlined = LucideIcons.pill;
  // ignore: unused_field
  static const IconData localShippingOutlined = LucideIcons.truck;
  // ignore: unused_field
  static const IconData localPharmacy = LucideIcons.pill;
  // ignore: unused_field
  static const IconData inventory2 = LucideIcons.package;
  // ignore: unused_field
  static const IconData inventory2Outlined = LucideIcons.package;
  // ignore: unused_field
  static const IconData inventoryOutlined = LucideIcons.package;
  // ignore: unused_field, constant_identifier_names
  static const IconData category_outlined = LucideIcons.tag;
  // ignore: unused_field, constant_identifier_names
  static const IconData arrow_downward = LucideIcons.arrowDown;
  // ignore: unused_field, constant_identifier_names
  static const IconData arrow_upward = LucideIcons.arrowUp;
  // ignore: unused_field, constant_identifier_names
  static const IconData calendar_today = LucideIcons.calendarDays;
  // ignore: unused_field, constant_identifier_names
  static const IconData calendar_today_outlined = LucideIcons.calendarDays;
  // ignore: unused_field, constant_identifier_names
  static const IconData error_outline = LucideIcons.triangle;
  // ignore: unused_field, constant_identifier_names
  static const IconData info_outline = LucideIcons.info;
  // ignore: unused_field, constant_identifier_names
  static const IconData check_circle_outline = LucideIcons.checkCircle;
  // ignore: unused_field, constant_identifier_names
  static const IconData help_outline = LucideIcons.helpCircle;
  // ignore: unused_field, constant_identifier_names
  static const IconData lock_outline = LucideIcons.lock;
  // ignore: unused_field, constant_identifier_names
  static const IconData visibility_outlined = LucideIcons.eye;
  // ignore: unused_field, constant_identifier_names
  static const IconData visibility_off = LucideIcons.eyeOff;
  // ignore: unused_field, constant_identifier_names
  static const IconData visibility_off_outlined = LucideIcons.eyeOff;
  // ignore: unused_field, constant_identifier_names
  static const IconData chevron_right = LucideIcons.chevronRight;
  // ignore: unused_field, constant_identifier_names
  static const IconData delete_outline = LucideIcons.trash;
  // ignore: unused_field, constant_identifier_names
  static const IconData edit_outlined = LucideIcons.pencil;
  // ignore: unused_field, constant_identifier_names
  static const IconData save_outlined = LucideIcons.save;
  // ignore: unused_field, constant_identifier_names
  static const IconData note_outlined = LucideIcons.stickyNote;
  // ignore: unused_field, constant_identifier_names
  static const IconData history_outlined = LucideIcons.history;
  // ignore: unused_field, constant_identifier_names
  static const IconData settings_outlined = LucideIcons.settings;
  // ignore: unused_field, constant_identifier_names
  static const IconData shield_outlined = LucideIcons.shieldCheck;
  // ignore: unused_field, constant_identifier_names
  static const IconData flag_outlined = LucideIcons.flag;
  // ignore: unused_field, constant_identifier_names
  static const IconData verified_outlined = LucideIcons.badgeCheck;
  // ignore: unused_field, constant_identifier_names
  static const IconData person_outline = LucideIcons.user;
  // ignore: unused_field, constant_identifier_names
  static const IconData swap_horiz = LucideIcons.arrowRightLeft;
  // ignore: unused_field, constant_identifier_names
  static const IconData swap_vert = LucideIcons.moveVertical;
  // ignore: unused_field, constant_identifier_names
  static const IconData event_busy = LucideIcons.calendarX;
  // ignore: unused_field, constant_identifier_names
  static const IconData g_mobiledata = LucideIcons.mail;
  // ignore: unused_field, constant_identifier_names
  static const IconData warning_amber_outlined = LucideIcons.alertTriangle;
  // ignore: unused_field, constant_identifier_names
  static const IconData logout_v1 = LucideIcons.logOut;

  // ignore: unused_field, constant_identifier_names
  static const IconData inventory2_outlined = LucideIcons.package;
  // ignore: unused_field, constant_identifier_names
  static const IconData visibilityOff_outlined = LucideIcons.eyeOff;
  // ignore: unused_field, constant_identifier_names
  static const IconData medicalServices_outlined = LucideIcons.stethoscope;
  // -- Lookup table --
  static const Map<String, IconData> _map = <String, IconData>{
    'dashboard': dashboard,
    'medicines': medicines,
    'categories': categories,
    'suppliers': suppliers,
    'stockIn': stockIn,
    'stockOut': stockOut,
    'stockMovements': stockMovements,
    'stockLevels': stockLevels,
    'lowStock': lowStock,
    'expired': expired,
    'expiringSoon': expiringSoon,
    'safe': safe,
    'alerts': alerts,
    'profile': profile,
    'empty': empty,
    'error': errorIcon,
    'retry': retry,
    'add': add,
    'remove': remove,
    'close': close,
    'search': search,
    'filter': filter,
    'edit': edit,
    'delete': delete,
    'save': save,
    'check': check,
    'info': info,
    'question': question,
    'verified': verified,
    'schedule': schedule,
    'calendar': calendar,
    'calendarToday': calendarToday,
    'swapHoriz': swapHoriz,
    'swapVert': swapVert,
    'chevronRight': chevronRight,
    'chevronLeft': chevronLeft,
    'chevronDown': chevronDown,
    'chevronUp': chevronUp,
    'arrowDownward': arrowDownward,
    'arrowUpward': arrowUpward,
    'arrowRight': arrowRight,
    'arrowLeft': arrowLeft,
    'arrowRightLeft': arrowRightLeft,
    'medication': medication,
    'medicalServices': medicalServices,
    'syringe': syringe,
    'package': package,
    'barcode': barcode,
    'boxes': boxes,
    'warehouse': warehouse,
    'visibility': visibility,
    'visibilityOff': visibilityOff,
    'lock': lock,
    'call': call,
    'message': message,
    'email': email,
    'note': note,
    'person': person,
    'logout': logout,
    'settings': settings,
    'security': security,
    'flag': flag,
    'history': history,
    'categoryOutlined': categoryOutlined,
    'localShipping': localShipping,
  };

  /// Resolve an [IconData] by string name. Returns [fallback] for null/empty/
  /// unknown input and never throws.
  static IconData byName(String? name) {
    if (name == null || name.isEmpty) return fallback;
    return _map[name] ?? fallback;
  }
}
