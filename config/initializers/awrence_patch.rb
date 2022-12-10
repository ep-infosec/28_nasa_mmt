# Patch the awrence gem to UPCASE keys that we don't want CamelCase

class Hash
  private

  UPCASE_WORDS = %w(
    urls
    url_value
    url
    uri
    url_content_type
    related_url
    license_url
    data_id
    isbn
    doi
    associated_dois
    data_resource_doi
    iso_topic_categories
    online_access_url_pattern_match
    online_access_url_pattern_substitution
    crs_identifier
    uom_label
    avg_compression_rate_ascii
    avg_compression_rate_net_cdf4
    url_value
    s3_credentials_api_documentation_url
    s3_credentials_api_endpoint
  )

  def camelize(snake_word, first_upper = true)
    # Here is the patch
    if UPCASE_WORDS.include?(snake_word)
      return 'URLs' if snake_word == 'urls'
      return 'URLValue' if snake_word == 'url_value'
      return 'URL' if snake_word == 'url'
      return 'URI' if snake_word == 'uri'
      return 'URLContentType' if snake_word == 'url_content_type'
      return 'RelatedURL' if snake_word == 'related_url'
      return 'LicenseURL' if snake_word == 'license_url'
      return 'S3CredentialsAPIDocumentationURL' if snake_word == 's3_credentials_api_documentation_url'
      return 'S3CredentialsAPIEndpoint' if snake_word == 's3_credentials_api_endpoint'
      return 'DataID' if snake_word == 'data_id'
      return 'ISOTopicCategories' if snake_word == 'iso_topic_categories'
      return 'OnlineAccessURLPatternMatch' if snake_word == 'online_access_url_pattern_match'
      return 'OnlineAccessURLPatternSubstitution' if snake_word == 'online_access_url_pattern_substitution'
      return 'CRSIdentifier' if snake_word == 'crs_identifier'
      return 'UOMLabel' if snake_word == 'uom_label'
      return 'DOI' if snake_word == 'doi'
      return 'AssociatedDOIs' if snake_word == 'associated_dois'
      return 'DataResourceDOI' if snake_word == 'data_resource_doi'
      return 'AvgCompressionRateASCII' if snake_word == 'avg_compression_rate_ascii'
      return 'AvgCompressionRateNetCDF4' if snake_word == 'avg_compression_rate_net_cdf4'
      return 'URLValue' if snake_word == 'url_value'
      return snake_word.upcase
    end

    if first_upper
      snake_word.to_s.gsub(/\/(.?)/) { '::' + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    else
      snake_word.chars.first + camelize(snake_word)[1..-1]
    end
  end
end
