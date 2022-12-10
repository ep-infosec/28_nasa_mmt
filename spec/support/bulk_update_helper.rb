module Helpers
  # :nodoc:
  module BulkUpdateHelper
    def create_bulk_update(provider_id: 'MMT_2', payload: {}, admin: false)
      ActiveSupport::Notifications.instrument 'mmt.performance', activity: 'Helpers::BulkUpdateHelper#create_bulk_update' do
        bulk_update_params = payload

        bulk_update_response = cmr_client.create_bulk_update(provider_id, bulk_update_params, admin ? 'access_token_admin' : 'access_token')

        raise Array.wrap(bulk_update_response.body['errors']).join(' /// ') unless bulk_update_response.success?

        # Synchronous way of waiting for CMR to complete the ingest work
        wait_for_cmr

        return bulk_update_response.body
      end
    end

    def wait_for_complete_bulk_update(task_id:, provider_id: 'MMT_2')
      ActiveSupport::Notifications.instrument 'mmt.performance', activity: 'Helpers::BulkUpdateHelper#wait_for_complete_bulk_update' do
        attempts = 0
        while attempts < 30
          # we want to loop through until we get a 'COMPLETE' status result,
          # however, we probably shouldn't allow it to loop infinitely

          bulk_update_response = cmr_client.get_bulk_update(provider_id, task_id, 'token')
          task = bulk_update_response.body || {}

          break if task['task-status'] == 'COMPLETE'
          attempts += 1

          sleep 0.5 # Platforms seem to take a little longer to get to 'COMPLETE'
        end
      end
    end
  end
end
