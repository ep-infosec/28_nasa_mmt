# Essentially a Hash object but is used for capturing arbitrary
# JSON for storing and representing UMM JSON Schemas
class JsonObj
  # The JSON string this class represents
  attr_accessor :parsed_json

  def initialize(json)
    @parsed_json = json
  end

  # Getter for accessing the JSON stored within +parsed_json+
  #
  # ==== Attributes
  #
  # * +key+ - The key to retrieve from +parsed_json+
  def [](key)
    parsed_json[key]
  end

  # Setter for setting values within +parsed_json+
  #
  # ==== Attributes
  #
  # * +key+ - The key to set within +parsed_json+
  # * +value+ - The value to associate with the provided key within  +parsed_json+
  def []=(key, value)
    parsed_json[key] = value
  end

  # Override default inspect for a more concise representation of the object
  def inspect
    '#<JsonObj>'
  end

  # UMM-S 1.1 introducted RelatedURLs as a top level field, this method is
  # used to create the correct underscored version of that name
  def underscore_fix_for_related_urls(key)
    if key == 'RelatedURLs'
      'related_urls'
    else
      key.underscore
    end
  end
end

# Subclass of JsonObj that accepts a filename instead of JSON. The supplied
# file will be parsed and stored within +parsed_json+ thanks to JsonObj
class JsonFile < JsonObj
  # Path to the file containing the JSON
  attr_accessor :file_path

  # The name of the file to parse
  attr_accessor :file

  attr_accessor :schema_type

  def initialize(schema_type, filename)
    @schema_type = schema_type
    @file_path = File.join(Rails.root, 'lib', 'assets', 'schemas', schema_type, filename)
    @file = File.read(file_path)

    super(JSON.parse(@file))
  end

  # Override default inspect for a more concise representation of the object
  def inspect
    "#<JsonObj file: \"#{file_path}\">"
  end

  # Recursively replace all '$ref' keys in the schema file with their actual values
  #
  # ==== Attributes
  #
  # * +fragment+ - The JSON to recursively replace references for
  def fetch_references(fragment)
    # Loop through each key in the current hash element
    fragment.each do |key, element|
      # Loop through arrays and keep looking,
      # unless they are enum or required arrays
      if element.is_a?(Array) && %w[enum required].index(key).nil?
        element.each do |value|
          fetch_references(anyKey: value)
        end
      end

      # Skip this element if it's not a hash, no $ref will exist
      next unless element.is_a?(Hash)

      # If we have a reference to follow
      if element.key?('$ref')
        file, path = element['$ref'].split('#')

        # Fetch the reference from the file that it's defined to be in
        referenced_property = if file.blank?
                                # This is an internal reference (lives within the file we're parsing)
                                parsed_json['definitions'][path.split('/').last]
                              else
                                # Fetch the reference from an external file
                                referenced_file = UmmJsonSchema.new(schema_type, file)
                                referenced_file.fetch_references(referenced_file.parsed_json)
                                referenced_schema = referenced_file.parsed_json
                                referenced_schema['definitions'][path.split('/').last]
                              end

        # Merge the retrieved reference into the schema
        element.merge!(referenced_property)

        # Remove the $ref key so we don't attempt to parse it again
        element.delete('$ref')
      end

      # Keep diggin'
      fetch_references(element)
    end
  end
end
