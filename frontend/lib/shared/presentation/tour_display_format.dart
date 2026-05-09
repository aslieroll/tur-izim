/// Presentation-only formatting for tour lists and detail (no business rules).
String formatTourCalendarDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
