# These tests are for the Groups Index page filtering by search boxes, which
# filter by provider(s) and/or member(s)
describe 'Filtering groups', reset_provider: true, js: true do
  before :all do
    VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
      create_group(
        name: 'Group_3',
        description: 'test group 3',
        provider_id: 'MMT_2',
        members: %w[qhw5mjoxgs2vjptmvzco]
      )

      create_group(
        name: 'Group_4',
        description: 'test group 4',
        provider_id: 'MMT_2',
        members: %w[qhw5mjoxgs2vjptmvzco rarxd5taqea q6ddmkhivmuhk]
      )

      create_group(
        name: 'Group_5',
        description: 'test group 5',
        provider_id: 'MMT_1',
        members: %w[mmt1a]
      )

      create_group(
        name: 'Group_6',
        description: 'test group 6',
        provider_id: 'LARC',
        members: %w[larc1a]
      )

      create_group(
        name: 'Group_7',
        description: 'test group 7',
        provider_id: 'NSIDC_ECS',
        members: %w[nsidcecs1a]
      )

      create_group(
        name: 'Group_8',
        description: 'test group 8',
        provider_id: 'SEDAC',
        members: %w[sedac1a]
      )

    end
  end

  context 'when viewing the groups page' do
    before do
      # we need to set these available providers, or the filter will not show
      # the groups in all the providers
      login(providers: %w[MMT_1 MMT_2 LARC SEDAC NSIDC_ECS])

      VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
        visit groups_path
      end
    end

    it 'displays only the groups from the current provider by default' do
      expect(page).to have_checked_field('Current Provider')

      expect(page).to have_content('Local admin group for provider MMT_2')
    end

    it 'displays the correct search boxes' do
      expect(page).to have_no_select('provider-group-filter')
      expect(page).to have_select('member-group-filter')
    end

    context 'when choosing to display groups from Available Providers' do
      before do
        VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
          within '.groups-filters' do
            choose 'Available Providers'

            click_on 'Apply Filters'
          end
        end
      end

      it 'displays groups from all Available Providers' do
        expect(page).to have_checked_field('Available Providers')

        # groups created on our local cmr setup
        within '.groups-table' do
          #expect(page).to have_content('LARC Admin Group Test group for provider LARC 2')
          expect(page).to have_content('Local admin group for provider MMT_1')
          expect(page).to have_content('Local admin group for provider MMT_2')
          #expect(page).to have_content('NSIDC_ECS Admin Group Test group for provider NSIDC_ECS 2')
        end
      end

      it 'displays the correct search boxes' do
        # provider select should include all available providers
        expect(page).to have_select('provider-group-filter', options: %w[MMT_1 MMT_2 LARC SEDAC NSIDC_ECS])
        expect(page).to have_select('member-group-filter')
      end

      context 'when searching by filter box' do
        context 'by provider' do
          before do
            VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
              select 'MMT_2', from: 'provider-group-filter'
              click_on 'Apply Filter'
            end
          end

          it 'displays the search params and correct groups' do
            expect(page).to have_css('li.select2-selection__choice', text: 'MMT_2')

            VCR.use_cassette("edl/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
              click_on 'Last'
            end

            within '.groups-table' do
              within all('tr')[2] do
                expect(page).to have_content('Group_3 test group 3 MMT_2 1')
              end
              within all('tr')[3] do
                expect(page).to have_content('Group_4 test group 4 MMT_2 3')
              end
              expect(page).to have_no_content('LARC Admin Group Test group for provider LARC 2')
              expect(page).to have_no_content('MMT_1 Admin Group Test group for provider MMT_1 2')
              expect(page).to have_no_content('NSIDC_ECS Admin Group Test group for provider NSIDC_ECS 2')
              expect(page).to have_no_content('SEDAC Admin Group Test group for provider SEDAC 2')
            end
          end
        end

        context 'by member' do
          before do
            VCR.use_cassette("edl/urs/search/rarxd5taqea/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
              within '#groups-member-filter' do
                page.find('.select2-search__field').native.send_keys('rarxd5taqea')
              end

              page.find('ul#select2-member-group-filter-results li.select2-results__option--highlighted').click
            end

            VCR.use_cassette("edl/urs/search/hw5mjoxgs2vjptmvzco/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
              within '#groups-member-filter' do
                page.find('.select2-search__field').native.send_keys('qhw5mjoxgs2vjptmvzco')
              end

              page.find('ul#select2-member-group-filter-results li.select2-results__option--highlighted').click
            end

            VCR.use_cassette("edl/urs/search/q6ddmkhivmuhk/#{File.basename(__FILE__, ".rb")}_vcr", record: :none) do
              within '#groups-member-filter' do
                page.find('.select2-search__field').native.send_keys('q6ddmkhivmuhk')
              end

              page.find('ul#select2-member-group-filter-results li.select2-results__option--highlighted').click
            end

            VCR.use_cassette('edl/urs/multiple_users', record: :none) do
              click_on 'Apply Filter'
            end
          end

          it 'displays the search params and correct groups' do
            expect(page).to have_css('li.select2-selection__choice', text: '06dutmtxyfxma Sppfwzsbwz ')
            expect(page).to have_css('li.select2-selection__choice', text: 'Rvrhzxhtra Vetxvbpmxf')

            within '.groups-table' do
              within all('tr')[1] do
                expect(page).to have_content('Group_2 test group 2 MMT_2 3')
              end

              expect(page).to have_no_content('Group_4 test group 4 MMT_2 1')
              expect(page).to have_no_content('MMT_2 Admin Group Test group for provider MMT_2 2')

              expect(page).to have_no_content('LARC Admin Group Test group for provider LARC 2')
              expect(page).to have_no_content('MMT_1 Admin Group Test group for provider MMT_1 2')
              expect(page).to have_no_content('NSIDC_ECS Admin Group Test group for provider NSIDC_ECS 2')
              expect(page).to have_no_content('SEDAC Test Group')
            end
          end
        end

        context 'when a URS user contains script tags' do
          before do
            VCR.use_cassette('urs/search/xss_user', record: :none) do
              within '#groups-member-filter' do
                page.find('.select2-search__field').native.send_keys('rotoo')
              end

              page.find('ul#select2-member-group-filter-results li.select2-results__option--highlighted').click
            end
          end

          it 'only displays the user name' do
            expect(page).to have_css('li.select2-selection__choice', text: 'rotoo')
          end
        end
      end
    end
  end
end
