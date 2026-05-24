import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_lv.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('lv'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Mario Shift Manager'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @passwordResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get passwordResetTitle;

  /// No description provided for @passwordResetSub.
  ///
  /// In en, this message translates to:
  /// **'We will send a reset link'**
  String get passwordResetSub;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendLink;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email sent! ✅'**
  String get emailSent;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseLanguage;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get adminPanel;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @todayNoShift.
  ///
  /// In en, this message translates to:
  /// **'No shift today'**
  String get todayNoShift;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notification;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @myWork.
  ///
  /// In en, this message translates to:
  /// **'My Work'**
  String get myWork;

  /// No description provided for @addShift.
  ///
  /// In en, this message translates to:
  /// **'Add Shift'**
  String get addShift;

  /// No description provided for @workers.
  ///
  /// In en, this message translates to:
  /// **'Workers'**
  String get workers;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @allShifts.
  ///
  /// In en, this message translates to:
  /// **'All Shifts'**
  String get allShifts;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @half.
  ///
  /// In en, this message translates to:
  /// **'Half'**
  String get half;

  /// No description provided for @dayOff.
  ///
  /// In en, this message translates to:
  /// **'Day Off'**
  String get dayOff;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @noShiftThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No shifts this week'**
  String get noShiftThisWeek;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @shiftsAdded.
  ///
  /// In en, this message translates to:
  /// **'shifts saved'**
  String get shiftsAdded;

  /// No description provided for @shiftDeleted.
  ///
  /// In en, this message translates to:
  /// **'Shift deleted'**
  String get shiftDeleted;

  /// No description provided for @shiftUpdated.
  ///
  /// In en, this message translates to:
  /// **'Shift updated ✓'**
  String get shiftUpdated;

  /// No description provided for @selectWorker.
  ///
  /// In en, this message translates to:
  /// **'Select worker'**
  String get selectWorker;

  /// No description provided for @selectShiftType.
  ///
  /// In en, this message translates to:
  /// **'Shift type'**
  String get selectShiftType;

  /// No description provided for @workTime.
  ///
  /// In en, this message translates to:
  /// **'Work time'**
  String get workTime;

  /// No description provided for @selectDays.
  ///
  /// In en, this message translates to:
  /// **'Select days'**
  String get selectDays;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endTime;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @nextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get nextWeek;

  /// No description provided for @monFri.
  ///
  /// In en, this message translates to:
  /// **'Mon-Fri'**
  String get monFri;

  /// No description provided for @weekdays.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdays;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @swapRequest.
  ///
  /// In en, this message translates to:
  /// **'Shift swap'**
  String get swapRequest;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get myRequests;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get newRequest;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @rejectReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection'**
  String get rejectReason;

  /// No description provided for @copyWeek.
  ///
  /// In en, this message translates to:
  /// **'Copy week'**
  String get copyWeek;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Excel export'**
  String get exportExcel;

  /// No description provided for @tomorrowReminder.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow reminder'**
  String get tomorrowReminder;

  /// No description provided for @sendReminders.
  ///
  /// In en, this message translates to:
  /// **'Send reminders'**
  String get sendReminders;

  /// No description provided for @totalHours.
  ///
  /// In en, this message translates to:
  /// **'Total hours'**
  String get totalHours;

  /// No description provided for @workDays.
  ///
  /// In en, this message translates to:
  /// **'Work days'**
  String get workDays;

  /// No description provided for @restDays.
  ///
  /// In en, this message translates to:
  /// **'Rest days'**
  String get restDays;

  /// No description provided for @monthlyProgress.
  ///
  /// In en, this message translates to:
  /// **'Monthly progress'**
  String get monthlyProgress;

  /// No description provided for @workInfo.
  ///
  /// In en, this message translates to:
  /// **'Work info'**
  String get workInfo;

  /// No description provided for @weeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly schedule'**
  String get weeklySchedule;

  /// No description provided for @upcomingShifts.
  ///
  /// In en, this message translates to:
  /// **'Upcoming shifts'**
  String get upcomingShifts;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @currentWeek.
  ///
  /// In en, this message translates to:
  /// **'Current week'**
  String get currentWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get lastWeek;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @searchWorker.
  ///
  /// In en, this message translates to:
  /// **'Search worker...'**
  String get searchWorker;

  /// No description provided for @addWorker.
  ///
  /// In en, this message translates to:
  /// **'Add worker'**
  String get addWorker;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNotMatch;

  /// No description provided for @emailAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get emailAlreadyUsed;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get wrongPassword;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get networkError;

  /// No description provided for @todayShifts.
  ///
  /// In en, this message translates to:
  /// **'Today\'s shifts'**
  String get todayShifts;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @totalShifts.
  ///
  /// In en, this message translates to:
  /// **'Total shifts'**
  String get totalShifts;

  /// No description provided for @averageHours.
  ///
  /// In en, this message translates to:
  /// **'Average hours/day'**
  String get averageHours;

  /// No description provided for @copyWeekConfirm.
  ///
  /// In en, this message translates to:
  /// **'Copy this week\'s schedule to next week?'**
  String get copyWeekConfirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes, copy'**
  String get yes;

  /// No description provided for @shiftsCopied.
  ///
  /// In en, this message translates to:
  /// **'shifts copied'**
  String get shiftsCopied;

  /// No description provided for @noShiftsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No shifts this week to copy'**
  String get noShiftsThisWeek;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get selectMonth;

  /// No description provided for @exportMonth.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportMonth;

  /// No description provided for @fabrika.
  ///
  /// In en, this message translates to:
  /// **'Mario Konditorijas fabrika v1.0'**
  String get fabrika;

  /// No description provided for @languageSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get languageSelectTitle;

  /// No description provided for @languageSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the language you prefer'**
  String get languageSelectSubtitle;

  /// No description provided for @languageSelectHint.
  ///
  /// In en, this message translates to:
  /// **'After selection, the app will use this language.'**
  String get languageSelectHint;

  /// No description provided for @languageHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shift Management · Shift Manager'**
  String get languageHeaderSubtitle;

  /// No description provided for @languageAvailableCount.
  ///
  /// In en, this message translates to:
  /// **'4 languages available'**
  String get languageAvailableCount;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'lv', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'lv':
      return AppLocalizationsLv();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
