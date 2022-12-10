describe 'Show Existing Tool Collection Associations', js: true, reset_provider: true do

  native_id = Faker::Crypto.md5

  before do
    login(provider: 'LARC', providers: %w[MMT_2 LARC])
  end

  before :all do
    # publish the tool to test
    @tool_ingest_response, _concept_response = publish_tool_draft(provider_id: 'LARC', native_id: native_id)

    # get all provider collections
    @provider_collections = get_collections_by_provider('LARC')

    # gets number of collections to be assigned to the tool
    @tool_collections = @provider_collections[0..25]

    # assign 26 collections to the tool
    cmr_client.add_collection_associations(@tool_ingest_response['concept-id'], @tool_collections, 'access_token', 'tools')

    wait_for_cmr
  end

  after :all do
    cmr_client.delete_tool('LARC', native_id, 'access_token')
  end

  context 'when there are paginated collection associations' do
    before do
      visit tool_collection_associations_path(@tool_ingest_response['concept-id'])
      click_on 'refresh the page'
    end

    it 'lists the first page of collection associations' do
      expect(page).to have_content('Showing Collection Associations 1 - 25 of 26')
      within '#collection-associations' do
        expect(page).to have_selector('tbody tr', count: 25)
      end
      within '.eui-pagination' do
        # first, 1, 2, next, last
        expect(page).to have_selector('li', count: 5)
        expect(page).to have_css('.active-page', text: '1')
      end
    end

    context 'when clicking to the second page' do
      before do
        click_link '2'
      end

      it 'lists the second page of collection associations' do
        expect(page).to have_content('Showing Collection Association 26 - 26 of 26')
        within '#collection-associations' do
          expect(page).to have_selector('tbody tr', count: 1)
        end
        within '.eui-pagination' do
          # first, previous, 1, 2, last
          expect(page).to have_selector('li', count: 5)
          expect(page).to have_css('.active-page', text: '2')
        end
      end

    end

    context 'when searching for new collections to associate from only my provider' do
      before do
        visit new_tool_collection_association_path(@tool_ingest_response['concept-id'])

        within '#collection-search' do
          select 'Entry Title', from: 'Search Field'
          find(:css, "input[id$='query_text']").set('*')
          click_button 'Submit'
        end
      end

      it 'displays the existing collection associations' do
        expect(page).to have_content('Disabled rows')
        expect(page).to have_selector('tbody tr', count: 29)
        expect(page).to have_selector('#selected_collections_', count: 3)
        expect(page).to have_selector('tbody tr.disabled', count: 26)
      end
    end

    context 'when searching for new collections to associate from all providers' do
      before do
        visit new_tool_collection_association_path(@tool_ingest_response['concept-id'])

        within '#collection-search' do
          select 'Entry Title', from: 'Search Field'
          find(:css, "input[id$='query_text']").set('*')
          choose 'which_provider_all_providers'
          click_button 'Submit'
        end
      end

      it 'displays the collections from other providers' do
        expect(page).to have_content('LARC')
        expect(page).to have_content('SEDAC')
        expect(page).to have_content('NSIDC_ECS')
      end
    end
  end
end
