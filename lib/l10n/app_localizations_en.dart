// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mario Shift Manager';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get createAccount => 'Create account';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToAccount => 'Sign in to your account';

  @override
  String get fullName => 'Full name';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get register => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signIn => 'Sign in';

  @override
  String get passwordResetTitle => 'Reset password';

  @override
  String get passwordResetSub => 'We will send a reset link';

  @override
  String get sendLink => 'Send link';

  @override
  String get emailSent => 'Email sent! ✅';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get resend => 'Resend';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get chooseLanguage => 'Choose your preferred language';

  @override
  String get continueBtn => 'Continue';

  @override
  String get adminPanel => 'Admin panel';

  @override
  String get hello => 'Hello';

  @override
  String get todayNoShift => 'No shift today';

  @override
  String get schedule => 'Schedule';

  @override
  String get hours => 'Hours';

  @override
  String get notification => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get myWork => 'My Work';

  @override
  String get addShift => 'Add Shift';

  @override
  String get workers => 'Workers';

  @override
  String get statistics => 'Statistics';

  @override
  String get allShifts => 'All Shifts';

  @override
  String get morning => 'Morning';

  @override
  String get night => 'Night';

  @override
  String get half => 'Half';

  @override
  String get dayOff => 'Day Off';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get noShiftThisWeek => 'No shifts this week';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get shiftsAdded => 'shifts saved';

  @override
  String get shiftDeleted => 'Shift deleted';

  @override
  String get shiftUpdated => 'Shift updated ✓';

  @override
  String get selectWorker => 'Select worker';

  @override
  String get selectShiftType => 'Shift type';

  @override
  String get workTime => 'Work time';

  @override
  String get selectDays => 'Select days';

  @override
  String get startTime => 'Start';

  @override
  String get endTime => 'End';

  @override
  String get thisWeek => 'This week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get monFri => 'Mon-Fri';

  @override
  String get weekdays => 'Mon';

  @override
  String get preview => 'Preview';

  @override
  String get swapRequest => 'Shift swap';

  @override
  String get sendRequest => 'Send request';

  @override
  String get myRequests => 'My requests';

  @override
  String get newRequest => 'New request';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get pending => 'Pending';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get rejectReason => 'Reason for rejection';

  @override
  String get copyWeek => 'Copy week';

  @override
  String get exportExcel => 'Excel export';

  @override
  String get tomorrowReminder => 'Tomorrow reminder';

  @override
  String get sendReminders => 'Send reminders';

  @override
  String get totalHours => 'Total hours';

  @override
  String get workDays => 'Work days';

  @override
  String get restDays => 'Rest days';

  @override
  String get monthlyProgress => 'Monthly progress';

  @override
  String get workInfo => 'Work info';

  @override
  String get weeklySchedule => 'Weekly schedule';

  @override
  String get upcomingShifts => 'Upcoming shifts';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get currentWeek => 'Current week';

  @override
  String get lastWeek => 'Last week';

  @override
  String get noData => 'No data';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get searchWorker => 'Search worker...';

  @override
  String get addWorker => 'Add worker';

  @override
  String get phone => 'Phone';

  @override
  String get optional => 'optional';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordsNotMatch => 'Passwords do not match';

  @override
  String get emailAlreadyUsed => 'This email is already registered';

  @override
  String get userNotFound => 'User not found';

  @override
  String get wrongPassword => 'Wrong email or password';

  @override
  String get networkError => 'No internet connection';

  @override
  String get todayShifts => 'Today\'s shifts';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String minutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get totalShifts => 'Total shifts';

  @override
  String get averageHours => 'Average hours/day';

  @override
  String get copyWeekConfirm => 'Copy this week\'s schedule to next week?';

  @override
  String get yes => 'Yes, copy';

  @override
  String get shiftsCopied => 'shifts copied';

  @override
  String get noShiftsThisWeek => 'No shifts this week to copy';

  @override
  String get selectMonth => 'Select month';

  @override
  String get exportMonth => 'Export';

  @override
  String get fabrika => 'Mario Konditorijas fabrika v1.0';

  @override
  String get languageSelectTitle => 'Choose language';

  @override
  String get languageSelectSubtitle => 'Select the language you prefer';

  @override
  String get languageSelectHint =>
      'After selection, the app will use this language.';

  @override
  String get languageHeaderSubtitle => 'Shift Management · Shift Manager';

  @override
  String get languageAvailableCount => '4 languages available';

  @override
  String get continueButton => 'Continue';
}
