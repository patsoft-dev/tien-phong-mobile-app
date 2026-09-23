import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:qr_app/controller/my_controller.dart';
import 'package:qr_app/helper/widgets/my_form_validator.dart';
import 'package:qr_app/helper/widgets/my_text_utils.dart';

class CalendarController extends MyController {
  late final TextEditingController titleTE;
  late final TextEditingController descriptionTE;
  late final TextEditingController locationTE;

  late final MyFormValidator basicValidator;
  late final DataSource events;

  final List<Appointment> _appointmentCollection = <Appointment>[];
  final List<Color> colorCollection = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.pink,
    Colors.purple,
    Colors.brown,
  ];

  final List<CalendarView> allowedViews = const [
    CalendarView.day,
    CalendarView.week,
    CalendarView.workWeek,
    CalendarView.schedule,
  ];

  late Color selectedColor;
  DateTime? selectedDate;

  @override
  void onInit() {
    super.onInit();

    titleTE = TextEditingController(text: 'Title');
    descriptionTE = TextEditingController(text: 'Description');
    locationTE = TextEditingController(text: 'Location');

    basicValidator = MyFormValidator();
    selectedColor = colorCollection.first;
    events = _initializeAppointments();
  }

  void onSelectedColor(Color? value) {
    if (value != null) {
      selectedColor = value;
      update();
    }
  }

  void onSelectDate(CalendarSelectionDetails details) {
    selectedDate = details.date;
  }

  void dragEnd(AppointmentDragEndDetails details) {
    final Appointment oldAppointment = details.appointment as Appointment;
    final Duration duration = oldAppointment.endTime.difference(
      oldAppointment.startTime,
    );

    final DateTime start = DateTime(
      details.droppingTime!.year,
      details.droppingTime!.month,
      details.droppingTime!.day,
      details.droppingTime!.hour,
    );

    final Appointment updatedAppointment = Appointment(
      subject: oldAppointment.subject,
      color: oldAppointment.color,
      startTime: start,
      endTime: start.add(duration),
    );

    events.appointments!
      ..remove(oldAppointment)
      ..add(updatedAppointment);

    events.notifyListeners(
      CalendarDataSourceAction.reset,
      events.appointments!,
    );
  }

  void addEvent() {
    final DateTime eventStart = selectedDate ?? DateTime.now();

    final appointment = Appointment(
      startTime: eventStart,
      endTime: eventStart.add(const Duration(hours: 1)),
      color: selectedColor,
      subject: descriptionTE.text,
      location: locationTE.text,
    );

    _appointmentCollection.add(appointment);
    events.appointments = _appointmentCollection;

    titleTE.clear();
    descriptionTE.clear();
    locationTE.clear();

    events.notifyListeners(CalendarDataSourceAction.add, <Appointment>[
      appointment,
    ]);

    Get.back();
    update();
  }

  DataSource _initializeAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, now.hour);

    _appointmentCollection.addAll([
      Appointment(
        startTime: today,
        endTime: today.add(const Duration(hours: 1)),
        subject: 'Planning',
        color: Colors.green,
      ),
      Appointment(
        startTime: today.add(const Duration(days: 1, hours: 2)),
        endTime: today.add(const Duration(days: 1, hours: 3)),
        subject: 'Meeting',
        color: Colors.red,
      ),
      Appointment(
        startTime: today.add(const Duration(days: 1, hours: 1)),
        endTime: today.add(const Duration(days: 1, hours: 2)),
        subject: 'Retrospective',
        color: Colors.pink,
      ),
      Appointment(
        startTime: today.add(const Duration(days: 2, hours: 5)),
        endTime: today.add(const Duration(days: 2, hours: 6)),
        subject: 'Birthday',
        color: Colors.pink,
      ),
      Appointment(
        startTime: today.add(const Duration(days: 3, hours: 3)),
        endTime: today.add(const Duration(days: 3, hours: 4)),
        subject: 'Consulting',
        color: Colors.deepPurple,
      ),
    ]);

    return DataSource(_appointmentCollection);
  }

  List<String> get dummyTexts =>
      List.generate(12, (index) => MyTextUtils.getDummyText(60));
}

class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }
}
