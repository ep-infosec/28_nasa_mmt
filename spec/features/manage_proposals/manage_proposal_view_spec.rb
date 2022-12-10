describe 'Proposals listed on the Manage Proposals (MMT) page', js: true do
  context 'when logging in with URS' do
    before do
      login(real_login: true)
      allow_any_instance_of(PermissionChecking).to receive(:is_non_nasa_draft_approver?).and_return(true)
      mock_urs_get_users
      visit manage_proposals_path
    end

    it 'displays a useful error message' do
      expect(page).to have_content('Please log in with Launchpad to perform proposal approver actions in MMT.')
    end
  end

  context 'when logging in with Launchpad' do
    before do
      real_login(method: 'launchpad')
      fake_service_account_cert
      allow_any_instance_of(PermissionChecking).to receive(:is_non_nasa_draft_approver?).and_return(true)
      mock_urs_get_users
    end

    context 'when the user can be authenticated, has approver permissions, and there are two pages of proposals' do
      before do
        set_as_proposal_mode_mmt(with_draft_approver_acl: true)
        26.times do |num|
          mock_approve(create(:full_collection_draft_proposal, proposal_short_name: "Short Name: #{num}", proposal_entry_title: "Entry Title: #{num}", proposal_request_type: num.even? ? 'create' : 'delete'))
        end

        set_as_mmt_proper
        VCR.use_cassette('launchpad/token_service_success', record: :none) do
          visit manage_proposals_path
        end
      end

      it 'has the correct proposal count' do
        within '.manage-proposals-mmt section p' do
          expect(page).to have_content('Showing Approved Proposals 1 - 25 of 26')
        end
      end

      it 'has the correct paging buttons' do
        expect(page).to have_link('First')
        expect(page).to have_link('1')
        expect(page).to have_link('2')
        expect(page).to have_link('Next')
        expect(page).to have_link('Last')
      end
    end

    # Separating these tests from the ones with more approved proposals halves the
    # time to run the tests because it saves on FactoryBot creation time.
    context 'when the user can be authenticated and has approver permissions' do
      before do
        mock_urs_get_users(count: 0, users: [{ 'first_name' => 'ZZZ', 'last_name' => 'User', 'uid' => 'z_user' }, { 'first_name' => 'Test', 'last_name' => 'User', 'uid' => 'testuser' }])
        set_as_proposal_mode_mmt
        4.times do |num|
          mock_approve(create(:full_collection_draft_proposal, proposal_short_name: "Short Name: #{num}", proposal_entry_title: "Entry Title: #{num}", proposal_request_type: num.even? ? 'create' : 'delete'))
        end
        CollectionDraftProposal.last.update_column('submitter_id', 'z_user')

        set_as_mmt_proper
        VCR.use_cassette('launchpad/token_service_success', record: :none) do
          visit manage_proposals_path
        end
      end

      it 'displays short names correctly' do
        expect(page).to have_content('Short Name: 3')
        expect(page).to have_content('Short Name: 0')
      end

      it 'displays entry titles' do
        expect(page).to have_content('Entry Title: 3')
        expect(page).to have_content('Entry Title: 0')
      end

      it 'displays proposal status' do
        expect(page).to have_content('Approved')
      end

      it 'displays proposal request types' do
        expect(page).to have_content('Create')
        expect(page).to have_content('Delete')
      end

      it 'displays user names' do
        expect(page).to have_content('Test User')
        expect(page).to have_content('ZZZ User')
      end

      it 'has the correct header' do
        within '.manage-proposals-mmt section h2' do
          expect(page).to have_content('Approved Proposals')
        end
      end

      context 'when sorting short name' do
        before do
          VCR.use_cassette('launchpad/token_service_success', record: :none) do
            click_on 'Sort by Short Name Asc'
          end
        end

        it 'sorts in ascending order' do
          within '.open-draft-proposals tbody tr:nth-child(1)' do
            expect(page).to have_content('Short Name: 0')
          end
        end

        context 'when sorting short name desc' do
          before do
            VCR.use_cassette('launchpad/token_service_success', record: :none) do
              click_on 'Sort by Short Name Desc'
            end
          end

          it 'sorts in descending order' do
            within '.open-draft-proposals tbody tr:nth-child(1)' do
              expect(page).to have_content('Short Name: 3')
            end
          end
        end
      end

      context 'when sorting submitter' do
        before do
          VCR.use_cassette('launchpad/token_service_success', record: :none) do
            click_on 'Sort by Submitter Asc'
          end
        end

        it 'sorts in ascending order' do
          within '.open-draft-proposals tbody tr:nth-child(4)' do
            expect(page).to have_content('ZZZ User')
          end
        end

        context 'when sorting short name desc' do
          before do
            VCR.use_cassette('launchpad/token_service_success', record: :none) do
              click_on 'Sort by Submitter Desc'
            end
          end

          it 'sorts in descending order' do
            within '.open-draft-proposals tbody tr:nth-child(1)' do
              expect(page).to have_content('ZZZ User')
            end
          end
        end
      end

      context 'when clicking on the action buttons' do
        context 'when clicking on the publish button' do
          before do
            within '.open-draft-proposals tbody tr:nth-child(2)' do
              click_on 'Publish'
            end
          end

          it 'has the correct text and buttons' do
            expect(page).to have_text('Please select a provider to publish this metadata to the CMR.')
            within '#approver-proposal-modal' do
              expect(page).to have_no_link('Publish')
              expect(page).to have_link('Cancel')
            end
          end
        end

        context 'when clicking on the delete button' do
          before do
            within '.open-draft-proposals tbody tr:nth-child(1)' do
              click_on 'Delete'
            end
          end

          it 'has the correct text and buttons' do
            expect(page).to have_text('Are you sure you want to delete this metadata in the CMR?')
            expect(page).to have_button('Yes')
            expect(page).to have_link('No')
          end
        end
      end
    end

    context 'when getting an unauthorized error from dMMT' do
      before do
        # not sure if the token service actually returns an unauthorized error
        # but this was a pre-existing test when using EDL authentication
        # cassette is modified from a 500 error response
        VCR.use_cassette('launchpad/token_service_unauthorized', record: :none) do
          visit manage_proposals_path
        end
      end

      it 'has the appropriate flash message' do
        expect(page).to have_content('No Approved Proposals found')
        expect(page).to have_content('Your token could not be authorized. Please try refreshing the page')
        expect(page).to have_no_content('An internal error has occurred. Please contact')
      end
    end

    context 'when getting an internal error from dMMT' do
      before do
        VCR.use_cassette('launchpad/token_internal_error', record: :none) do
          visit manage_proposals_path
        end
      end

      it 'has the appropriate flash message' do
        expect(page).to have_content('No Approved Proposals found')
        expect(page).to have_no_content('Your token could not be authorized. Please try refreshing the page')
        expect(page).to have_content('An internal error has occurred. Please contact')
      end
    end
  end
end
