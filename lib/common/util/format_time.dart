import 'package:intl/intl.dart';

import '../constant/helper.dart';

enum Format { dMy, mdy, Mdy, dMydMy, My, EMd, E, M, y, dMMy, dMyHm }

mixin FormatTime {
  static String formatTime({Format? format, DateTime? dateTime}) {
    final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
    String formatted;
    DateFormat formatter;
    switch (format!) {
      case Format.dMy:
        formatter = DateFormat(
          'dd/MM/yyyy',
        );
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.dMMy:
        formatter = DateFormat(
          'dd MMM yyyy',
        );
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.y:
        formatter = DateFormat(
          'yyyy',
        );
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.Mdy:
        formatter = DateFormat(
          'MMMM dd, yyyy',
        );
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.mdy:
        formatter = DateFormat(
          'MMM dd, yyyy',
        );
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.M:
        formatter = DateFormat(
          'MMM',
        );
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.EMd:
        formatter = DateFormat(
          'EEEE, MMMM dd',
        );
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.E:
        formatter = DateFormat(
          'EEEE',
        );
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.dMyHm:
        formatter = DateFormat(
          'dd/MM/yyyy HH:mm',
        );
        formatted = formatter.format(dateTime ?? now);
        break;
      case Format.dMydMy:
        if (sevenDaysAgo.year == now.year) {
          formatter = DateFormat(
            'dd MMM yyyy',
          );
          formatted = DateFormat(
                'dd MMM',
              ).format(sevenDaysAgo) +
              ' - ' +
              formatter.format(now);
        } else {
          formatter = DateFormat(
            'dd MMM yyyy',
          );
          formatted =
              formatter.format(sevenDaysAgo) + ' - ' + formatter.format(now);
        }
        break;
      case Format.My:
        formatter = DateFormat(
          'MMMM yyyy',
        );
        formatted = formatter.format(dateTime ?? now);
        break;
    }
    return formatted;
  }

  static String convertTime(int duration) {
    final minutesStr = (duration / 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }
}
