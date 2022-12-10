describe 'Searching published collections', js: true, reset_provider: true do
  short_name = "Search Test Collection Short Name 16532535"
  entry_title = "2008 Long Description for Search Test Collection 52367465"
  version = "4719635"
  provider = 'MMT_2'
  granule_count = '0'
  tags_count = '0'

  before :all do
    @token = 'jwt_access_token'
    VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
      @ingest_response, @concept_response = publish_collection_draft(native_id: '123456785', token: @token, short_name: short_name, entry_title: entry_title, version: version)
    end
  end

  before do
    @token = 'jwt_access_token'
    allow_any_instance_of(ApplicationController).to receive(:echo_provider_token).and_return(@token)
    login
    visit manage_collections_path
  end

  context 'when performing a collection search by concept_id' do
    before do
      fill_in 'keyword', with: @ingest_response['concept-id']
      VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
        @token = 'jwt_access_token'
        allow_any_instance_of(ApplicationController).to receive(:token).and_return(@token)
        click_on 'Search Collections'
      end
    end

    it 'displays the query and collection results' do
      expect(page).to have_collection_search_query(1, "Keyword: #{@ingest_response['concept-id']}")
    end

    it 'displays expected Short Name, Entry Title, Provider, Version, Last Modified, Granule Count and Tag Count values' do
      expect(page).to have_content(short_name)
      expect(page).to have_content(version)
      expect(page).to have_content(entry_title)
      expect(page).to have_content(provider)
      within '#search-results tbody tr:nth-child(1) td:nth-child(5)' do
        expect(page).to have_content(granule_count)
      end
      within '#search-results tbody tr:nth-child(1) td:nth-child(6)' do
        expect(page).to have_content(tags_count)
      end
    end
  end

  context 'when performing a collection search by short name' do
    before do
      fill_in 'keyword', with: short_name
      VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
        @token = 'jwt_access_token'
        allow_any_instance_of(ApplicationController).to receive(:token).and_return(@token)
        click_on 'Search Collections'
      end
    end

    it 'displays the query and collection results' do
      expect(page).to have_content("Keyword: #{short_name}")
    end

    it 'displays expected Short Name, Entry Title Provider, Version, Last Modified, Granule Count and Tag Count values' do
      expect(page).to have_content(short_name)
      expect(page).to have_content(version)
      expect(page).to have_content(entry_title)
      expect(page).to have_content(provider)
      within '#search-results tbody tr:nth-child(1) td:nth-child(5)' do
        expect(page).to have_content(granule_count)
      end
      within '#search-results tbody tr:nth-child(1) td:nth-child(6)' do
        expect(page).to have_content(tags_count)
      end
    end
  end

  context 'when performing a collection search by entry title' do
    before do
      fill_in 'keyword', with: entry_title
      VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
        @token = 'jwt_access_token'
        allow_any_instance_of(ApplicationController).to receive(:token).and_return(@token)
        click_on 'Search Collections'
      end
    end

    it 'displays the query and collection results' do
      expect(page).to have_content("Keyword: #{entry_title}")
    end

    it 'displays expected Short Name, Entry Title, Provider, Version, Last Modified, Granule Count and Tag Count values' do
      expect(page).to have_content(short_name)
      expect(page).to have_content(version)
      expect(page).to have_content(entry_title)
      expect(page).to have_content(provider)
      within '#search-results tbody tr:nth-child(1) td:nth-child(5)' do
        expect(page).to have_content(granule_count)
      end
      within '#search-results tbody tr:nth-child(1) td:nth-child(6)' do
        expect(page).to have_content(tags_count)
      end
    end
  end

  context 'when performing a collection search by partial entry title' do
    before do
      fill_in 'keyword', with: entry_title[0..17]
      VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
        @token = 'jwt_access_token'
        allow_any_instance_of(ApplicationController).to receive(:token).and_return(@token)
        click_on 'Search Collections'
      end
    end

    it 'displays the query and collection results' do
      expect(page).to have_content("Keyword: #{entry_title[0..17]}")
    end

    it 'displays expected Short Name, Entry Title, Provider, Version, Last Modified, Granule Count and Tag Count values' do
      expect(page).to have_content(short_name[0..25])
      expect(page).to have_content(version)
      expect(page).to have_content(entry_title)
      expect(page).to have_content(provider)
      within '#search-results tbody tr:nth-child(1) td:nth-child(5)' do
        expect(page).to have_content(granule_count)
      end
      within '#search-results tbody tr:nth-child(1) td:nth-child(6)' do
        expect(page).to have_content(tags_count)
      end
    end
  end

  context 'when searching by provider' do
    before do
      VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
        click_on 'search-drop'
        select 'LARC', from: 'provider_id'
        @token = 'jwt_access_token'
        allow_any_instance_of(ApplicationController).to receive(:token).and_return(@token)
        click_on 'Search Collections'
      end
    end

    it 'displays the query and collection results' do
      expect(page).to have_content('35 Collection Results for: Provider Id: LARC')
    end

    it 'displays expected data' do
      expect(page).to have_content('TL3CH4D')
      expect(page).to have_content('TES/Aura L3 CH4 Daily Gridded V002')
    end
  end

  context 'when searching by short name for a collection which has a granule count' do
    before do
      fill_in 'keyword', with: 'MIRCCMF'
      VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
        @token = 'jwt_access_token'
        allow_any_instance_of(ApplicationController).to receive(:token).and_return(@token)
        click_on 'Search Collections'
      end
    end

    it 'displays the results list with column granule count' do
      within '#search-results thead' do
        expect(page).to have_content('Granule Count')
      end

      within '#search-results tbody tr:nth-child(1) td:nth-child(5)' do
        expect(page).to have_content('1')
      end
    end
  end

  context 'when searching by short name for a collection which has a tag count' do
    search_tag_1_key = 'tag.search.example.01'
    search_tag_1_description = 'This is a search example tag'
    tag_collection_short_name = "Collection Tagging search example 3125735735"

    before :all do
      @token = 'jwt_access_token'
      VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
        @ingest_response, _concept_response = publish_collection_draft(native_id: '12345678905', token: @token, short_name: tag_collection_short_name)
        cmr_client.delete_permission('ACL1200442557-CMR', @token)
        @sys_group_response = create_group(provider_id: nil, description:'my group description', admin: true, members: ['admin', 'adminuser'])
        @acl_concept = setup_tag_permissions(@sys_group_response['group_id'], @token)
        reindex_permitted_groups
        # create tags
        create_tags(search_tag_1_key, search_tag_1_description, @token)
        # associate with a collection
        associate_tag_to_collection_by_short_name(search_tag_1_key, tag_collection_short_name, @token)
      end
    end

    after :all do
      VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
        remove_group_permissions(@acl_concept)
        delete_group(concept_id: @sys_group_response['group_id'], admin: true)
        reindex_permitted_groups
      end
    end

    before do
      fill_in 'keyword', with: tag_collection_short_name
    end

    context 'when retrieving all tag information succeeds' do
      before do
        VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
          @token = 'jwt_access_token'
          allow_any_instance_of(ApplicationController).to receive(:token).and_return(@token)
          click_on 'Search Collections'
        end
      end

      it 'displays the results list with column tags count link' do
        within '#search-results thead' do
          expect(page).to have_content('Tag Count')
        end

        within '#search-results tbody tr:nth-child(1) td:nth-child(6)' do
          expect(page).to have_link('1', href: '#tags-modal')
        end
      end

      context 'when clicking on the Tags link' do
        before do
          within '#search-results tbody tr:nth-child(1) td:nth-child(6)' do
            VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
              @token = 'jwt_access_token'
              allow_any_instance_of(ApplicationController).to receive(:token).and_return(@token)
              click_on '1'
            end
          end
          wait_for_jQuery
        end

        it 'displays the tags modal with the correct tag information' do
          within '#tags-modal' do
            expect(page).to have_content("Tag Key: #{search_tag_1_key}")
            expect(page).to have_content("Description: #{search_tag_1_description}")
          end
        end
      end
    end

    context "when retrieving the collection's tags fails" do
      before do
        json_fail_response = cmr_fail_response(JSON.parse('{"errors": "this is a json failure response"}'), 403)
        allow_any_instance_of(Cmr::CmrClient).to receive(:search_collections).and_return(json_fail_response)

        VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
          @token = 'jwt_access_token'
          allow_any_instance_of(ApplicationController).to receive(:token).and_return(@token)
          click_on 'Search Collections'
        end
      end

      it 'displays an error message' do
        expect(page).to have_content('There was an error searching for Tags: this is a json failure response')
      end

      it 'displays no tags for the collection' do
        within '#search-results tbody tr:nth-child(1) td:nth-child(6)' do
          expect(page).to have_content('0')
        end
      end
    end

    context "when retrieving the collection's tags succeeds but retrieving the tag information fails" do
      before do
        VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
          @token = 'jwt_access_token'
          allow_any_instance_of(ApplicationController).to receive(:token).and_return(@token)
          click_on 'Search Collections'
        end
      end

      it 'displays the tags link with the correct number of tags' do
        within '#search-results tbody tr:nth-child(1) td:nth-child(6)' do
          expect(page).to have_link('1', href: '#tags-modal')
        end
      end

      context 'when clicking on the Tags link' do
        before do
          tags_fail_response = cmr_fail_response(JSON.parse('{"error": "this is a tags retrieval failure response"}'), 403)
          allow_any_instance_of(Cmr::CmrClient).to receive(:get_tags).and_return(tags_fail_response)

          within '#search-results tbody tr:nth-child(1) td:nth-child(6)' do
            VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
              click_on('1')
            end
          end
          wait_for_jQuery(5)
        end

        it 'displays the tags modal with an error message' do
          within '#tags-modal' do
            expect(page).to have_css('.eui-banner--danger', text: 'There was an error retrieving Tag information: this is a tags retrieval failure response')
          end
        end

        it 'displays the tags modal with the tag keys but no description' do
          within '#tags-modal' do
            expect(page).to have_content("Tag Key: #{search_tag_1_key}")
            expect(page).to have_content('Description: Not retrieved')
          end
        end
      end
    end
  end

  context 'when performing a search that has no results' do
    before do
      fill_in 'keyword', with: 'NO HITS'
      VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
        @token = 'jwt_access_token'
        allow_any_instance_of(ApplicationController).to receive(:token).and_return(@token)
        click_on 'Search Collections'
      end
    end

    it 'displays collection results' do
      expect(page).to have_content(' Results')
    end
  end
end
