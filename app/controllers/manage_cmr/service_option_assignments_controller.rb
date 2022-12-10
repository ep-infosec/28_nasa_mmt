# :nodoc:
class ServiceOptionAssignmentsController < ManageCmrController
  add_breadcrumb 'Service Option Assignments', :service_option_assignments_path

  def index; end

  def new
    authorize :service_option_assignment

    set_service_entries
    set_service_options
  end

  def create
    authorize :service_option_assignment

    payload = service_option_assignment_params.fetch('service_option_assignment_catalog_guid_toList', []).map do |catalog_item_guid|
      {
        'CatalogItemGuid'             => catalog_item_guid,
        'ServiceEntryGuid'            => service_option_assignment_params[:service_entry_guid],
        'AppliesOnlyToGranules'       => (service_option_assignment_params[:applies_only_to_granules] || false),
        'ServiceOptionDefinitionGuid' => service_option_assignment_params[:service_option_definition_guid]
      }
    end

    if echo_provider_token.blank?
      flash[:error] = "Error retrieving echo provider token.  Try logging in with launchpad"
      redirect_back(fallback_location: manage_collections_path)
      return
    end

    response = echo_client.create_service_option_assignments(echo_provider_token, payload)

    if response.success?
      redirect_to service_option_assignments_path, flash: { success: 'Service Option Assignments successfully created' }
    else
      Rails.logger.error("Create Service Option Assignments Error: #{response.clean_inspect}")
      flash[:error] = response.error_message

      set_service_entries
      set_service_options

      render :new
    end
  end

  def update
    # Initialize the assignments array for the view
    @assignments = []

    if echo_provider_token.blank?
      flash[:error] = "Error retrieving echo provider token.  Try logging in with launchpad"
      redirect_back(fallback_location: manage_collections_path)
      return
    end

    assignments_response = echo_client.get_service_option_assignments_by_service(echo_provider_token, service_option_assignment_params['service_entries_toList'])

    if assignments_response.success?
      service_option_associations = Array.wrap(assignments_response.parsed_body(parser: 'libxml').fetch('Item', []))

      # Collect all of the guids/ids we'll need to lookup in order to populate the table in the view
      collection_ids       = service_option_associations.map { |a| a['CatalogItemGuid'] }.compact
      service_entry_guids  = service_option_associations.map { |a| a['ServiceEntryGuid'] }.compact
      service_option_guids = service_option_associations.map { |a| a['ServiceOptionDefinitionGuid'] }.compact

      # Retrieve all collections associated with the requested service implementations
      assignment_collections_response = cmr_client.get_collections_by_post({ concept_id: collection_ids, page_size: collection_ids.count }, token)
      assignment_collections = if collection_ids.any? && assignment_collections_response.success?
                                 assignment_collections_response.body['items'] || []
                               else
                                 Rails.logger.error("Retrieve Collections to Update Service Option Assignments Error: #{assignment_collections_response.clean_inspect}") if assignment_collections_response.error?

                                 []
                               end

      # Retrieve all service entries associated with the requested service implementations
      assignment_service_entries_response = echo_client.get_service_entries(echo_provider_token, service_entry_guids)
      assignment_service_entries = if service_entry_guids.any? && assignment_service_entries_response.success?
                                     Array.wrap(assignment_service_entries_response.parsed_body(parser: 'libxml')['Item'])
                                   else
                                     Rails.logger.error("#{request.uuid} - ServiceOptionAssignmentsController#update - Retrieve Service Entries to Update Service Option Assignments Error: #{assignment_service_entries_response.clean_inspect}") if assignment_service_entries_response.error?
                                     flash[:error] = I18n.t("controllers.service_option_assignments.update.get_service_entries.flash.timeout_error", request: request.uuid) if assignment_service_entries_response.timeout_error?
                                     []
                                   end

      # Retrieve all service options associated with the requested service implementations
      assignment_service_options_response = get_service_option_list(echo_provider_token, service_option_guids)
      assignment_service_options = Array.wrap(assignment_service_options_response.fetch('Result', []))

      # Use the data collected above (which we did in bulk to avoid multiple calls to ECHO) to
      # add new keys containing full objects to the assignments array that we use to populate
      # the table within the view
      service_option_associations.each do |association|
        # Look for the collection by concept-id. If no collection is found we will ignore this association
        collection = assignment_collections.find { |c| c.fetch('meta', {}).fetch('concept-id', nil) == association['CatalogItemGuid'] }

        # Ignore associations where the collection no longer exists
        if collection.nil?
          Rails.logger.debug "Collection with concept-id `#{association['CatalogItemGuid']}` not found in #{assignment_collections.map { |c| c.fetch('meta', {}).fetch('concept-id', nil) }}"

          next
        end

        # Ignore associations where the service entry no longer exists
        service_entry = assignment_service_entries.find { |c| c['Guid'] == association['ServiceEntryGuid'] }
        if service_entry.nil?
          Rails.logger.debug "Service Entry with guid `#{association['ServiceEntryGuid']}` not found in #{assignment_service_entries.map { |s| s['Guid'] }}"

          next
        end

        # Ignore associations where the service option no longer exists
        service_option = assignment_service_options.find { |c| c['Guid'] == association['ServiceOptionDefinitionGuid'] }
        if service_option.nil?
          Rails.logger.debug "Service Option with guid `#{association['ServiceOptionDefinitionGuid']}` not found in #{assignment_service_options.map { |s| s['Guid'] }}"

          next
        end

        # Merge fully qualified objects in with the association object guids and
        # push the record to the instance variable
        @assignments << {
          'CatalogItem'   => collection,
          'ServiceEntry'  => service_entry,
          'ServiceOption' => service_option
        }.merge(association)
      end
    else
      Rails.logger.error("#{request.uuid} - ServiceOptionAssignmentsController#update - Retrieve Service Options Assignments to Update Error: #{assignments_response.clean_inspect}")
      flash[:error] = I18n.t("controllers.service_option_assignments.update.get_service_option_assignments.flash.timeout_error", request: request.uuid) if assignments_response.timeout_error?
    end

    render action: :edit
  end

  def destroy
    authorize :service_option_assignment

    if echo_provider_token.blank?
      flash[:error] = "Error retrieving echo provider token.  Try logging in with launchpad"
      redirect_back(fallback_location: manage_collections_path)
      return
    end

    response = echo_client.remove_service_option_assignments(echo_provider_token, service_option_assignment_params.fetch('service_option_assignment', []))

    if response.success?
      redirect_to service_option_assignments_path, flash: { success: 'Successfully deleted the selected service option assignments.' }
    else
      Rails.logger.error("#{request.uuid} - ServiceOptionAssignmentsController#destroy - Delete Service Option Assignments Error: #{response.clean_inspect}")
      redirect_to service_option_assignments_path, flash: { error: response.error_message }
    end
  end

  private

  # params used in controller:
  # In create:
  #   :service_entry_guid,
  #   :service_option_definition_guid,
  #   :applies_only_to_granules,
  #   :service_option_assignment_catalog_guid_toList
  # In update:
  #   :service_entries_toList
  # In destroy:
  #   :service_option_assignment
  def service_option_assignment_params
    params.permit(:service_entry_guid, :service_option_definition_guid, :applies_only_to_granules, service_option_assignment_catalog_guid_toList: [], service_entries_toList: [], service_option_assignment: [])
  end

  def set_service_entries
    @service_entries = begin
      get_service_implementations_with_datasets.map { |option| [option['Name'], option['Guid']] }
    rescue
      []
    end
  end

  def set_service_options
    if echo_provider_token.blank?
      flash[:error] = "Error retrieving echo provider token.  Try logging in with launchpad"
      redirect_back(fallback_location: manage_collections_path)
      return
    end

    service_option_response = echo_client.get_service_options_names(echo_provider_token)
    @service_options = if service_option_response.success?
                         # Retreive the service options and sort by name, ignoring case
                         Array.wrap(service_option_response.parsed_body(parser: 'libxml').fetch('Item', [])).sort_by { |option| option.fetch('Name', '').downcase }.map { |option| [option['Name'], option['Guid']] }
                       else
                         Rails.logger.error("#{request.uuid} - ServiceOptionAssignmentsController#set_service_options - Retrieve Service Options Error: #{service_option_response.clean_inspect}")
                         flash[:error] = I18n.t("controllers.service_option_assignments.set_service_options.flash.timeout_error", request: request.uuid) if service_option_response.timeout_error?
                         []
                       end
  end
end
