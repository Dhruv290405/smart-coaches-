import 'package:smart_coach_new/core/utils/enums.dart';

class Constants {
  static const List<String> genderList = ['Male', 'Female', 'Other'];

  static const List<String> locationList = ['Front', 'Middle', 'Rear', 'Engine'];
  static const List<String> placementTypeList = ['Front', 'Rear', 'Internal'];
  static const List<String> serviceProviderList = ['Airtel', 'Jio', 'Vi', 'BSNL'];
  static const List<String> simStatusList = ['Active', 'Inactive', 'Registration'];
  static const List<String> batteryTypeList = ['Alkaline', 'Li-ion', 'Lithium-ion', 'Nickel-Cadmium (NiCd)', 'Nickel-Metal Hydride (NiMH)', 'Lead-acid', 'Sodium-ion'];
  static const List<String> lineList = ['Up', 'Down'];
  static const List<String> trainOperatorList = ['IRCTC', 'Konkan Railway Corporation'];

  static List<String> valueFormats = [
    DataTypes.number.name,
    DataTypes.decimal.name,
    DataTypes.percentage.name,
    DataTypes.binary.name
  ];
  static List<String> conditionConnectors = [ConditionConnectors.none.name, ConditionConnectors.and.name, ConditionConnectors.or.name];
  static final List<OperatorOption> operatorOptions = [
    OperatorOption(label: 'Greater than (>)', value: '>'),
    OperatorOption(label: 'Less than (<)', value: '<'),
    OperatorOption(label: 'Equal to (=)', value: '='),
    OperatorOption(label: 'Less than Equal to (<=)', value: '<='),
    OperatorOption(label: 'Greater than Equal to (>=)', value: '>='),
    OperatorOption(label: 'Not equal to (!=)', value: '!='),
  ];

  static const List<String> evaluationUnitValues = [
    'Milliseconds',
    'Seconds',
    'Minutes',
    'Hours',
    'Days',
    'Weeks'
  ];

  static const String deleteConfirmationMessage = 'Are you sure you want to delete?';
  static const String saveSensorConfirmationMessage = 'Are you sure you want to save these sensor configuration?';
  static const String confirmSave = 'Confirm Save';

  static const String dateTimeFormatToShowInTable = 'yyyy-MM-dd HH:mm';
}

class OperatorOption {
  final String label;
  final String value;

  OperatorOption({required this.label, required this.value});
}