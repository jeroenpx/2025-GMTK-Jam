extends Resource
class_name Limitations

enum VisitType {DEFAULT, NATURE, ZIPLINE, PIER, CIVILISATION, REST }
enum NumericalType{MIN, MAX, CONSTANT}
@export var visit_type: VisitType
@export var numerical_type: NumericalType
@export var value: int
