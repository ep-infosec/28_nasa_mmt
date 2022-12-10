# :nodoc:
module ManageMetadataHelper
  # lists of controllers to make checking which resource_type and current title easier
  # we only need to add controllers that don't inherit from manage_variables or
  # manage_services
  VARIABLES_CONTROLLERS = %w[
    manage_variables
    variables
    variable_drafts
    variable_generation_processes_searches
    variable_drafts_collection_searches
  ]

  SERVICES_CONTROLLERS = %w[
    manage_services
    services
    service_drafts
  ]

  TOOLS_CONTROLLERS = %w[
    manage_tools
    tools
    tool_drafts
  ]

  def is_variable_controller?
    (VARIABLES_CONTROLLERS & controller.lookup_context.prefixes).any? || (controller.lookup_context.prefixes.include?('collection_associations') && variable_id)
  end

  def variable_id
    return params[:variable_id] if params[:variable_id]
    return nil unless params[:id]

    params[:id] if params[:id].split('-').first.starts_with?(/V\d/)
  end

  def is_services_controller?
    (SERVICES_CONTROLLERS & controller.lookup_context.prefixes).any? || (controller.lookup_context.prefixes.include?('collection_associations') && params[:service_id])
  end

  def is_tools_controller?
    (TOOLS_CONTROLLERS & controller.lookup_context.prefixes).any? || (controller.lookup_context.prefixes.include?('collection_associations') && params[:tool_id])
  end

  def is_collection_draft_proposal_controller?
    controller.lookup_context.prefixes.each do |item|
      return true if item.start_with?('proposal') || (Rails.configuration.proposal_mode && resource_type == 'collections')
    end
    false
  end

  def current_manage_title
    if is_collection_draft_proposal_controller?
      'manage_collection_proposals'
    elsif controller.lookup_context.prefixes.include?('search')
      "manage_#{resource_type}"
    elsif controller.lookup_context.prefixes.include?('manage_cmr')
      'manage_cmr'
    elsif controller.lookup_context.prefixes.include?('manage_proposal')
      'manage_proposal'
    elsif is_variable_controller?
      'manage_variables'
    elsif is_services_controller?
      'manage_services'
    elsif is_tools_controller?
      'manage_tools'
    else
      # default, including collection drafts and everything under manage collections
      'manage_collections'
    end
  end

  # resource type for the Search button text based on the controller
  def resource_type
    case
    when controller_name.starts_with?('search')
      params[:record_type]
    when is_variable_controller?
      'variables'
    when is_services_controller?
      'services'
    when is_tools_controller?
      'tools'
    else
      # default
      'collections'
    end
  end

  def display_header_subtitle(metadata, type)
    return unless ['variable', 'service', 'tool'].any? { |type_fragment| type.downcase.include?(type_fragment) }

    metadata['LongName'] || 'Long Name Not Provided'
  end

  def edsc_map_path
    service_configs = Rails.configuration.services
    edsc_root = service_configs['earthdata'][Rails.configuration.cmr_env]['edsc_root']
    "#{edsc_root}/search/map"
  end

  def display_version(mime_type)
    index = mime_type.index('version=')
    'v' + mime_type[(index + 8)..-1]
  end
end
