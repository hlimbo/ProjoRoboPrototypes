extends RefCounted
class_name IPackedStringArrayConverter

# Implement this function in derived classes to convert data
# obtained into target class type. Use cases include converted
# a row of columns in a csv file to a specific class type.
# Variant return type depends on the derived class's type
func on_convert(data: PackedStringArray) -> Variant:
	return []
	
func read_csv_file(file_path: String, delimiter: String) -> Array:
	var csv_file = FileAccess.open(file_path,FileAccess.READ)
	var is_first_row: bool = true
	var lines: Array[PackedStringArray] = []
	while csv_file.get_position() < csv_file.get_length():
		var line: PackedStringArray = csv_file.get_csv_line(delimiter)
		
		# skip first row assuming it is a title row
		if is_first_row:
			is_first_row = false
			continue

		lines.append(line)
	
	var datum: Array = []
	for line in lines:
		var data = on_convert(line)
		datum.append(data)
		
	return datum
