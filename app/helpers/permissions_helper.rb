# :nodoc:
module PermissionsHelper
  ErrorCodeMessages = {
    409 => 'This permission could not be created because there is already another permission with the same name.',
    403 => 'You are not authorized to create a permission. Please contact your system administrator.'
  }.freeze

  def display_access_constraints(access_value)
    return unless access_value.any?

    filters = ['that have access constraint values']

    if access_value['min_value'] && access_value['max_value']
      filters << if access_value['min_value'] == access_value['max_value']
                   "equal to #{access_value['min_value']}"
                 else
                   "between #{access_value['min_value']} and #{access_value['max_value']}"
                 end

      filters << '(or are undefined)' if access_value['include_undefined_value'] == true
    elsif access_value['include_undefined_value']
      filters << 'that are undefined'
    end

    filters.join(' ')
  end

  def display_temporal_filters(temporal)
    return unless temporal.any?

    filters = ['that have a start and end date']

    # contains means start and end are within the values of the acl
    # disjoint means they are outside of that range
    # intersect means need to overlap in some way
    filters << case temporal['mask']
               when 'contains'
                 'contained within'
               when 'intersect'
                 'having some overlap with'
               when 'disjoint'
                 'outside of'
               end

    filters << "the date range #{temporal['start_date']} to #{temporal['stop_date']}"

    filters.join(' ')
  end

  def display_filters(access_value, temporal)
    access_constraint_text = display_access_constraints(access_value)
    temporal_text = display_temporal_filters(temporal)

    if access_constraint_text.blank? && temporal_text.blank?
      return
    elsif access_constraint_text.blank?
      temporal_text
    elsif temporal_text.blank?
      access_constraint_text
    else
      "#{access_constraint_text} and #{temporal_text}"
    end
  end

  def collection_constraint_summary(permission)
    collection_applicable = permission.fetch('catalog_item_identity', {}).fetch('collection_applicable', false)

    collection_concept_ids = permission_concept_ids(permission)

    sentence_fragments = ['This permission']

    if collection_applicable
      sentence_fragments << if collection_concept_ids.any?
                              "grants its assigned groups access to #{pluralize(collection_concept_ids.count, 'collection')}"
                            else
                              'grants its assigned groups access to all of its collections'
                            end

      sentence_fragments <<
        display_filters(permission_collection_access_constraints(permission), permission_collection_temporal_filters(permission))
    else
      sentence_fragments << 'does not grant access to collections'
    end

    "#{sentence_fragments.join(' ')}."
  end

  def granule_constraint_summary(permission)
    granule_applicable = permission.fetch('catalog_item_identity', {}).fetch('granule_applicable', false)

    collection_concept_ids = permission_concept_ids(permission)

    sentence_fragments = ['This permission']

    if granule_applicable
      sentence_fragments << 'grants its assigned groups access to granules'

      sentence_fragments <<
        display_filters(permission_granule_access_constraints(permission), permission_granule_temporal_filters(permission))

      sentence_fragments << if collection_concept_ids.any?
                              "that belong to the #{pluralize(collection_concept_ids.count, 'selected collection')}"
                            else
                              'that belong to any of its collections'
                            end

      sentence_fragments <<
        display_filters(permission_collection_access_constraints(permission), permission_collection_temporal_filters(permission))
    else
      sentence_fragments << 'does not grant access to granules'
    end

    "#{sentence_fragments.join(' ')}."
  end

  def permission_collections(permission)
    concept_ids = permission_concept_ids(permission)

    return {} unless concept_ids.any?

    collection_response = cmr_client.get_collections_by_post({ provider_id: permission.fetch('catalog_item_identity', {})['provider_id'], concept_id: concept_ids, page_size: concept_ids.count }, token)

    return {} unless collection_response.success?

    collection_response.body
  end

  # Return the collections that the current user does NOT have access to which
  # is the difference between the collections that are stored on the permission
  # and the collections that are returned from pinging CMR with the users token
  def unauthorized_permission_collections(permission)
    permitted_collections = permission_collections(permission).fetch('items', []).map { |collection| collection.fetch('meta', {})['concept-id'] }

    (permission_concept_ids(permission) - permitted_collections)
  end

  #
  # Shortcuts for deeply nested keys within permission object
  #

  def permission_concept_ids(permission)
    permission.fetch('catalog_item_identity', {}).fetch('collection_identifier', {}).fetch('concept_ids', [])
  end

  def permission_collection_access_constraints(permission)
    permission.fetch('catalog_item_identity', {}).fetch('collection_identifier', {}).fetch('access_value', {})
  end

  def permission_granule_access_constraints(permission)
    permission.fetch('catalog_item_identity', {}).fetch('granule_identifier', {}).fetch('access_value', {})
  end

  def permission_collection_temporal_filters(permission)
    permission.fetch('catalog_item_identity', {}).fetch('collection_identifier', {}).fetch('temporal', {})
  end

  def permission_granule_temporal_filters(permission)
    permission.fetch('catalog_item_identity', {}).fetch('granule_identifier', {}).fetch('temporal', {})
  end

  def permission_provider(permission)
    permission.fetch('catalog_item_identity', {}).fetch('provider_id', nil)
  end
end
