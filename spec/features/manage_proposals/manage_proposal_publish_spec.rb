describe 'When publishing collection draft proposals', js: true do
  before do
    real_login(method: 'launchpad')
    fake_service_account_cert
    allow_any_instance_of(PermissionChecking).to receive(:is_non_nasa_draft_approver?).and_return(true)
    mock_urs_get_users
  end

  context 'when processing a delete request' do
    context 'when the target collection exists' do
      before do
        mock_retrieve_approved_proposals(proposal_info: [{ short_name: 'Delete Request', entry_title: 'Delete Request Title', request_type: 'delete' }])
        @ingest_response, _concept_response = publish_collection_draft(native_id: 'dmmt_collection_1')
        VCR.use_cassette('launchpad/token_service_success', record: :none) do
          visit manage_proposals_path
        end
      end

      context 'when the collection has granules' do
        before do
          mock_cmr_get_collections(granule_count: 1)
          click_on 'Delete'
          click_on 'Yes'
        end

        it 'provides an error message' do
          expect(page).to have_content('This collection cannot be deleted using the MMT because it has associated granules. Use the CMR API to delete the collection and its granules.')
        end
      end

      context 'when successfully deleting the collection' do
        before do
          @email_count = ActionMailer::Base.deliveries.count
          mock_cmr_get_collections
          click_on 'Delete'
        end

        context 'when dMMT can update the proposal_status' do
          before do
            mock_update_proposal_status
            click_on 'Yes'
          end

          it 'generates a success message' do
            expect(page).to have_content('Collection Metadata Deleted Successfully!')
          end

          it 'cannot find the record' do
            visit collection_path(@ingest_response['concept-id'])

            expect(page).to have_content('This collection is not available. It is either being published right now, does not exist, or you have insufficient permissions to view this collection.')
          end

          it 'sends an e-mail' do
            # Expecting identical e-mails to the user and approver
            expect(ActionMailer::Base.deliveries.count).to eq(@email_count + 2)
            expect(ActionMailer::Base.deliveries.last.body.parts[0].body.raw_source).to match(/deleted from the CMR \(test\)/)
            expect(ActionMailer::Base.deliveries.last.body.parts[1].body.raw_source).to match(/deleted from the CMR \(test\)/)
          end
        end

        context 'when dMMT cannot update the proposal_status' do
          before do
            mock_update_proposal_status(succeed: false)
            click_on 'Yes'
          end

          it 'generates a success message for the delete action' do
            expect(page).to have_content('Collection Metadata Deleted Successfully!')
          end

          it 'generates an error message for the proposal status update' do
            expect(page).to have_content('Proposal status was not updated in the Draft Metadata Management Tool successfully.')
          end

          it 'cannot find the record' do
            visit collection_path(@ingest_response['concept-id'])

            expect(page).to have_content('This collection is not available. It is either being published right now, does not exist, or you have insufficient permissions to view this collection.')
          end

          it 'sends an e-mail' do
            # Expecting identical e-mails to the user and approver
            expect(ActionMailer::Base.deliveries.count).to eq(@email_count + 2)
            expect(ActionMailer::Base.deliveries.last.body.parts[0].body.raw_source).to match(/deleted from the CMR \(test\)/)
            expect(ActionMailer::Base.deliveries.last.body.parts[1].body.raw_source).to match(/deleted from the CMR \(test\)/)
          end
        end

        context 'when dMMT can update the proposal status, but cannot delete the record' do
          before do
            mock_proposal_delete_failure_after_publish
            click_on 'Yes'
          end
        end
      end
    end

    context 'when the collection does not exist' do
      before do
        mock_retrieve_approved_proposals(proposal_info: [{ short_name: "Delete Request", entry_title: "Delete Request Title", request_type: 'delete', native_id: 'DNE_ID' }])
        VCR.use_cassette('launchpad/token_service_success', record: :none) do
          visit manage_proposals_path
        end
        mock_cmr_get_collections(hits: 0)
        mock_update_proposal_status
        click_on 'Delete'
        click_on 'Yes'
      end

      it 'provides an error message' do
        expect(page).to have_content('Collection metadata was not deleted successfully because it could not be found.')
      end
    end
  end

  context 'when processing a create request' do
    before do
      @create_native_id = "proposal_id_#{Faker::Number.number(digits: 15)}"
      mock_retrieve_approved_proposals(proposal_info: [{ short_name: "Create Request", entry_title: "Create Request Title", request_type: 'create', native_id: @create_native_id },
                                                     { short_name: "Second Create Request", entry_title: "Create Request Title", request_type: 'create', native_id: "proposal_id_#{Faker::Number.number(digits: 15)}" }])
      VCR.use_cassette('launchpad/token_service_success', record: :none) do
        visit manage_proposals_path
      end
    end

    after do
      cmr_client.delete_collection('MMT_2', @create_native_id, 'ABC-2')
    end

    context 'when creating a new record' do
      before do
        @email_count = ActionMailer::Base.deliveries.count
        mock_update_proposal_status
        within '.open-draft-proposals tbody tr:nth-child(1)' do
          click_on 'Publish'
        end
        select 'MMT_2', from: 'provider-publish-target'
        within '#approver-proposal-modal' do
          click_on 'Publish'
        end
      end

      it 'sends an e-mail' do
        # Expecting identical e-mails to the user and approver
        expect(ActionMailer::Base.deliveries.count).to eq(@email_count + 2)
        expect(ActionMailer::Base.deliveries.last.body.parts[0].body.raw_source).to match(/published to the CMR \(test\). The collection's concept ID is/)
        # &#39; = ' in html
        expect(ActionMailer::Base.deliveries.last.body.parts[1].body.raw_source).to match(/published to the CMR \(test\). The collection&#39;s concept ID is/)
      end

      it 'creates a new record' do
        expect(page).to have_content('Collection Metadata Successfully Published!')

        # CMR needs a second to be able to find the record
        wait_for_cmr
        fill_in 'keyword', with: 'Create Request'
        click_on 'Search Collections'
        expect(page).to have_content('Create Request Title')
        expect(page).to have_link('Create Request')
      end

      context 'when publishing a create request with the same entry_title' do
        before do
          within '.open-draft-proposals tbody tr:nth-child(2)' do
            click_on 'Publish'
          end
          select 'MMT_2', from: 'provider-publish-target'
          within '#approver-proposal-modal' do
            click_on 'Publish'
          end
        end

        it 'provides an error message' do
          expect(page).to have_content('Collection metadata was not successfully published.')
          expect(page).to have_content('This proposal has the following errors:')
          expect(page).to have_content('The Entry Title [Create Request Title] must be unique.')
        end
      end
    end
  end

  context 'when processing an update request' do
    before do
      @update_native_id = "full_collection_draft_proposal_id_#{Faker::Number.number(digits: 15)}"
      mock_retrieve_approved_proposals(proposal_info: [{ short_name: "Create Request_#{Faker::Number.number(digits: 15)}", entry_title: "Create Request Title_#{Faker::Number.number(digits: 15)}", request_type: 'update', native_id: @update_native_id }])
      VCR.use_cassette('launchpad/token_service_success', record: :none) do
        visit manage_proposals_path
      end
    end

    after do
      cmr_client.delete_collection('MMT_2', @update_native_id, 'ABC-2')
    end

    context 'when the proposal status update in dMMT succeeds' do
      context 'when there is an existing record with the same native id' do
        before do
          @ingest_response, _concept_response = publish_collection_draft(native_id: @update_native_id)
          mock_update_proposal_status
          click_on 'Publish'
          click_on 'Yes'
        end

        it 'updates the record' do
          expect(page).to have_content('Collection Metadata Successfully Published!')

          # CMR needs a moment to update the record
          wait_for_cmr
          response = cmr_client.get_collections({ 'native_id': @update_native_id }, 'ABC-2')
          expect(response.body['items'][0]['meta']['revision-id'].to_i - @ingest_response['revision-id'].to_i).to eq(1)
        end
      end
    end

    context 'when the proposal status update in dMMT fails' do
      context 'when there is an existing record with the same native id' do
        before do
          @ingest_response, _concept_response = publish_collection_draft(native_id: @update_native_id)
          mock_update_proposal_status(succeed: false)
          click_on 'Publish'
          click_on 'Yes'
        end

        it 'updates the record' do
          expect(page).to have_content('Collection Metadata Successfully Published!')

          # CMR needs a moment to update the record
          wait_for_cmr
          response = cmr_client.get_collections({ 'native_id': @update_native_id }, 'ABC-2')
          expect(response.body['items'][0]['meta']['revision-id'].to_i - @ingest_response['revision-id'].to_i).to eq(1)
        end

        it 'has an error message for failing to update the proposal status' do
          expect(page).to have_content('Proposal status was not updated in the Draft Metadata Management Tool successfully.')
        end
      end
    end
  end
end
