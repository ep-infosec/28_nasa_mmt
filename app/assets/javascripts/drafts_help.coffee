$(document).ready ->

  $('i.eui-fa-info-circle').on 'click', (element) ->
    # get path from data-help-path attribute
    # properties/EntryId
    # definitions/ProcessingLevelType/properties/ProcessingLevelDescription
    overrideHelp = $(element.target).data('overrideHelp')
    helpPath = $(element.target).data('helpPath').split('/')
    title = fixTitle(helpPath[helpPath.length - 1])
    minItems = getMinItems(helpPath)
    maxItems = getMaxItems(helpPath)
    minLength = getMinLength(helpPath)
    maxLength = getMaxLength(helpPath)
    pattern = getPattern(helpPath)
    description = overrideHelp || getDescription(helpPath)
    format = getFormat(helpPath)

    # Set the field title and description
    $('#help-modal .title').text(title)
    $('#help-modal .description').text(description)
    $('#help-modal .validations').html('')

    # Display or hide validation hints
    validations = $('#help-modal .validations')
    $(validations).parent().show()
    $("<li>Minimum Items: #{minItems}</li>").appendTo(validations) if minItems?
    $("<li>Maximum Items: #{maxItems}</li>").appendTo(validations) if maxItems?
    $("<li>Format: #{format}</li>").appendTo(validations) if format?
    $("<li>Minimum Length: #{minLength}</li>").appendTo(validations) if minLength?
    $("<li>Maximum Length: #{maxLength}</li>").appendTo(validations) if maxLength?
    $("<li>Pattern: #{pattern}</li>").appendTo(validations) if pattern?
    if !format? and !minItems? and !minLength? and !maxLength? and !pattern?
      $(validations).parent().hide()

    helpUrl = $(element.target).data('helpUrl')
    $helpUrlElement = $('#help-modal .help-url')
    if helpUrl?.length > 0
      $helpUrlElement.attr('href', "https://wiki.earthdata.nasa.gov/display/CMR/#{helpUrl}")
      $helpUrlElement.show()
    else
      $helpUrlElement.hide()

  fixTitle = (title) ->
    typeInTitle = ['Type', 'CollectionDataType', 'DataType', 'MimeType'
      'SpatialCoverageType', 'TemporalRangeType', 'URLContentType',
      'ServiceType', 'DataResourceSpatialType', 'DataResourceTemporalType',
      'CouplingType']

    title = title.replace( /Type$/, '' ) unless title in typeInTitle

    newTitle = switch title
      when 'URLs' then 'URLs'
      when 'URL' then 'URL'
      when 'URLValue' then 'URL Value'
      when 'URI' then 'URI'
      when 'URLContentType' then 'URL Content Type'
      when 'RelatedURL' then 'Related URL'
      when 'RelatedURLs' then 'Related URLs'
      when 'LicenseURL' then 'License URL'
      when 'DataID' then 'Data ID'
      when 'StateProvince' then 'State / Province'
      when 'StreetAddresses' then 'Street Address'
      when 'DOI' then 'DOI'
      when 'AssociatedDOIs' then 'Associated DOIs'
      when 'DataResourceDOI' then 'Data Resource DOI'
      when 'CRSIdentifier' then 'CRS Identifier'
      when 'UOMLabel' then 'UOM Label'
      when 'AvgCompressionRateASCII' then 'Avg Compression Rate ASCII'
      when 'AvgCompressionRateNetCDF4' then 'Avg Compression Rate NetCDF4'
      when 'URL Value' then 'URL Value'
      when 'S3CredentialsAPIEndpoint' then 'S3 Credentials API Endpoint'
      when 'S3CredentialsAPIDocumentationURL' then 'S3 Credentials API Documentation URL'
      else title.replace( /([A-Z])/g, " $1" )

    newTitle

  getSchemaProperties = (path) ->
    schema = globalJsonSchema
    schema = (schema[x]) for x in path
    schema

  getDescription = (path) ->
    schema = getSchemaProperties(path)
    schema.description

  getMinItems = (path) ->
    schema = getSchemaProperties(path)
    minItems = if schema.minItems? then schema.minItems else null
    if !minItems? and schema['$ref']?
      ref = schema['$ref'].split('/')
      ref.shift()
      minItems = getMinItems(ref)

    minItems

  getMaxItems = (path) ->
    schema = getSchemaProperties(path)
    maxItems = if schema.maxItems? then schema.maxItems else null
    if !maxItems? and schema['$ref']?
      ref = schema['$ref'].split('/')
      ref.shift()
      maxItems = getMaxItems(ref)

    maxItems

  getMinLength = (path) ->
    schema = getSchemaProperties(path)
    minLength = schema.minLength || schema.items?.minLength
    ref = schema['$ref']?.split('/') || schema.items?['$ref']?.split('/') || []
    if !minLength? and ref.length > 0
      ref.shift()
      minLength = getMinLength(ref)

    minLength

  getMaxLength = (path) ->
    schema = getSchemaProperties(path)
    maxLength = schema.maxLength || schema.items?.maxLength
    ref = schema['$ref']?.split('/') || schema.items?['$ref']?.split('/') || []
    if !maxLength? and ref.length > 0
      ref.shift()
      maxLength = getMaxLength(ref)

    maxLength

  getPattern = (path) ->
    schema = getSchemaProperties(path)
    pattern = schema.pattern || schema.items?.pattern
    ref = schema['$ref']?.split('/') || schema.items?['$ref']?.split('/') || []
    if !pattern? and ref.length > 0
      ref.shift()
      pattern = getPattern(ref)

    pattern

  getFormat = (path) ->
    schema = getSchemaProperties(path)
    format = schema.format || schema.items?.format
    ref = schema['$ref']?.split('/') || schema.items?['$ref']?.split('/') || []
    if !format? and ref.length > 0
      ref.shift()
      format = getFormat(ref)

    return "date-time (yyyy-MM-dd'T'HH:mm:ssZ)" if format == 'date-time'
