# meta-name: Packed String Array Converter
# meta-description: Used to read from packed string array and convert to its target object type 
# meta-default: true
# meta-space-indent: 4
extends IPackedStringArrayConverter

# replace Variant with the specific object type being returned
func on_convert(data: PackedStringArray) -> Variant:
	return
