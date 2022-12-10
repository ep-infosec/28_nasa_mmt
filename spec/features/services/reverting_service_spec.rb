describe 'Reverting to previous services', reset_provider: true, js: true do
  before :all do
    # service for simple reverting service test
    @simple_revert_ingest_response, @simple_revert_concept_response = publish_service_draft(revision_count: 2)

    # service for reverting service with many revisions
    @multiple_revisions_ingest_response, @multiple_revisions_concept_response = publish_service_draft(revision_count: 4, long_name: 'Reverting Services Test', number_revision_long_names: true)
  end

  before do
    login
  end

  context 'when the latest revision is a published service' do
    before do
      visit service_path(@simple_revert_ingest_response['concept-id'])

      click_on 'Revisions'
    end

    it 'displays the correct phrasing for reverting records' do
      expect(page).to have_content('Revert to this Revision', count: 1)
    end

    context 'when reverting the service' do
      before do
        click_on 'Revert to this Revision'
        click_on 'Yes'

        wait_for_jQuery
        wait_for_cmr
      end

      it 'displays all the correct revision information' do
        expect(page).to have_content('Revision Created Successfully!')

        expect(page).to have_content('Published', count: 1)
        expect(page).to have_content('Revision View', count: 2)
        expect(page).to have_content('Revert to this Revision', count: 2)
      end
    end

    context 'when reverting to a revision before the previous revision from a different provider context' do
      context 'when visiting the revisions page from a different provider' do
        before do
          login(provider: 'MMT_1', providers: %w(MMT_1 MMT_2))

          visit service_revisions_path(@multiple_revisions_ingest_response['concept-id'])
        end

        it 'displays all the correct revision information' do
          within 'main header' do
            expect(page).to have_content('Reverting Services Test -- revision 04')
          end

          expect(page).to have_content('Published', count: 1)
          expect(page).to have_content('Revision View', count: 3)
          expect(page).to have_content('Revert to this Revision', count: 3)
        end

        context 'when reverting to the earliest revision' do
          before do
            visit service_revisions_path(@multiple_revisions_ingest_response['concept-id'])

            within '#service-revisions-table tbody tr:last-child' do
              # make sure we are clicking on the correct link
              expect(page).to have_content('1 - Revision')

              click_on 'Revert to this Revision'
            end
          end

          it 'displays a modal informing the user they need to switch providers' do
            expect(page).to have_content('Reverting this service requires you change your provider context to MMT_2')
          end

          context 'when clicking Yes' do
            before do
              find('.not-current-provider-link').click
              wait_for_jQuery
            end

            it 'reverts the service to the correct revision and displays the correct revision information and switches provider context' do
              within 'main header' do
                expect(page).to have_content('Reverting Services Test -- revision 01')
              end

              expect(page).to have_content('Published', count: 1)
              expect(page).to have_content('Revision View', count: 4)
              expect(page).to have_content('Revert to this Revision', count: 4)

              expect(User.first.provider_id).to eq('MMT_2')
            end
          end
        end
      end
    end

    context 'when reverting the service fails ingestion into CMR' do
      before do
        # Do something to the revision so it fails
        # Add a new field to the metadata, similar to a field name changing
        # and old metadata still having the old field name
        new_concept = @simple_revert_concept_response.deep_dup
        new_concept.body['BadField'] = 'Not going to work'

        allow_any_instance_of(Cmr::CmrClient).to receive(:get_concept).and_return(new_concept)

        click_on 'Revert to this Revision', match: :first
        click_on 'Yes'

        wait_for_jQuery
        wait_for_cmr
      end

      it 'displays an error message' do
        expect(page).to have_content('extraneous key [BadField] is not permitted')
      end
    end
  end

  context 'when the latest revision is a deleted service' do
    before do
      ingest_response, _concept_response = publish_service_draft

      visit service_path(ingest_response['concept-id'])

      click_on 'Delete Service Record'
      click_on 'Yes'

      wait_for_jQuery
      wait_for_cmr
    end

    it 'displays the correct phrasing for reverting records' do
      expect(page).to have_content('Reinstate', count: 1)
    end

    context 'when reverting the service' do
      before do
        click_on 'Reinstate'
        click_on 'Yes'

        wait_for_jQuery
        wait_for_cmr
      end

      it 'displays all the correct revision information' do
        expect(page).to have_content('Revision Created Successfully!')

        expect(page).to have_content('Published', count: 1)
        expect(page).to have_content('Deleted', count: 1)
        expect(page).to have_content('Revision View', count: 1)
        expect(page).to have_content('Revert to this Revision', count: 1)
      end
    end
  end
end
