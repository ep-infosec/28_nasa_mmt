# tests for create, show, edit, update, delete

describe 'Collection Permissions', reset_provider: true, js: true do
  let(:group1_id) { 'AG1200000069-MMT_2' }
  let(:group2_id) { 'AG1200000070-MMT_2' }
  let(:group3_id) { 'AG1200000071-MMT_2' }

  before do
    # stubs for groups
    groups_list_response = cmr_success_response(File.read('spec/fixtures/collection_permissions/get_cmr_groups_response.json'))
    allow_any_instance_of(Cmr::UrsClient).to receive(:get_edl_groups).and_return(groups_list_response)

    group1_response = cmr_success_response(File.read('spec/fixtures/collection_permissions/group1.json'))
    allow_any_instance_of(Cmr::UrsClient).to receive(:get_edl_group).with(group1_id).and_return(group1_response)

    group2_response = cmr_success_response(File.read('spec/fixtures/collection_permissions/group2.json'))
    allow_any_instance_of(Cmr::UrsClient).to receive(:get_edl_group).with(group2_id).and_return(group2_response)

    group3_response = cmr_success_response(File.read('spec/fixtures/collection_permissions/group3.json'))
    allow_any_instance_of(Cmr::UrsClient).to receive(:get_edl_group).with(group3_id).and_return(group3_response)

    login
  end

  context 'when creating a new collection permission with complete information' do
    let(:new_collection_permission_name) { "New Collection Permission #{Faker::Number.number(digits: 4)}" }
    before do
      visit new_permission_path

      fill_in('Name', with: new_collection_permission_name)

      check('Collections')
      within '#collection-access-constraints-container' do
        fill_in('Minimum Value', with: 5)
        fill_in('Maximum Value', with: 25)
        check('Include Undefined')
      end
      within '#collection-temporal-filter-container' do
        fill_in('Start Date', with: '2020-03-01T00:00:00Z')
        fill_in('Stop Date', with: '2020-04-27T00:00:00Z')
        choose('Contains')
      end

      check('Granules')
      within '#granule-access-constraints-container' do
        fill_in('Minimum Value', with: 1.1)
        fill_in('Maximum Value', with: 8.8)
        check('Include Undefined')
      end
      within '#granule-temporal-filter-container' do
        fill_in('Start Date', with: '2020-03-01T00:00:00Z')
        fill_in('Stop Date', with: '2020-04-27T00:00:00Z')
        choose('Intersect')
      end

      within '#permission-form-groups-table' do
        select('All Guest Users', from: 'Search')
        select('All Registered Users', from: 'Search, Order, and S3 (If Available)')
        select('Group 1', from: 'Search, Order, and S3 (If Available)')
      end

      click_on 'Submit'

      wait_for_cmr
    end

    it 'successfully creates the collection permission and redirects to the show page and displaying the collection permission information' do
      expect(page).to have_content('Collection Permission was successfully created.')

      expect(page).to have_content(new_collection_permission_name)

      within '#collection-constraint-summary' do
        expect(page).to have_content('between 5.0 and 25.0')
        expect(page).to have_content('(or are undefined)')

        expect(page).to have_content('contained within')
        expect(page).to have_content('the date range 2020-03-01T00:00:00Z to 2020-04-27T00:00:00Z')
      end

      within '#granule-constraint-summary' do
        expect(page).to have_content('between 1.1 and 8.8')
        expect(page).to have_content('(or are undefined)')

        expect(page).to have_content('having some overlap with')
        expect(page).to have_content('the date range 2020-03-01T00:00:00Z to 2020-04-27T00:00:00Z')
      end

      within '#permission-groups-table' do
        expect(page).to have_content('All Guest Users')
        expect(page).to have_content('All Registered Users')
        expect(page).to have_content('Group 1')
      end
    end
  end

  context 'when creating a collection permission with temporal filters but no access constraints' do
    let(:new_collection_permission_name) { "New Collection Permission with Temporal but no Access Constraint Filters #{Faker::Number.number(digits: 4)}" }
    before do
      visit new_permission_path

      fill_in('Name', with: new_collection_permission_name)

      within '#collection-temporal-filter-container' do
        fill_in('Start Date', with: '2020-03-01T00:00:00Z')
        fill_in('Stop Date', with: '2020-04-27T00:00:00Z')
        choose('Contains')
      end

      check('Granules')
      within '#granule-temporal-filter-container' do
        fill_in('Start Date', with: '2020-03-01T00:00:00Z')
        fill_in('Stop Date', with: '2020-04-27T00:00:00Z')
        choose('Disjoint')
      end

      within '#permission-form-groups-table' do
        select('All Guest Users', from: 'Search')
        select('All Registered Users', from: 'Search, Order, and S3 (If Available)')
      end

      click_on 'Submit'

      wait_for_cmr
    end

    it 'successfully creates the collection permission and redirects to the show page and displaying the collection permission information' do
      expect(page).to have_content('Collection Permission was successfully created.')

      expect(page).to have_content(new_collection_permission_name)

      within '#collection-constraint-summary' do
        expect(page).to have_content('This permission does not grant access to collections.')
      end

      within '#granule-constraint-summary' do
        expect(page).to have_content('outside of')
        expect(page).to have_content('the date range 2020-03-01T00:00:00Z to 2020-04-27T00:00:00Z')

        expect(page).to have_content('contained within')
        expect(page).to have_content('the date range 2020-03-01T00:00:00Z to 2020-04-27T00:00:00Z')
      end

      within '#permission-groups-table' do
        expect(page).to have_content('All Guest Users')
        expect(page).to have_content('All Registered Users')
      end
    end
  end

  context 'when updating a collection permission' do
    before :all do
      previous_collection_permission = {
        group_permissions: [ {
          user_type: 'guest',
          permissions: [ 'read' ]
        }, {
          user_type: 'registered',
          permissions: [ 'read', 'order' ]
        }, {
          group_id: "AG1200000069-MMT_2",
          permissions: [ 'order' ]
        }],
        catalog_item_identity: {
          'name': 'Collection Permission to Edit 01',
          'provider_id': 'MMT_2',
          'granule_applicable': false,
          'collection_applicable': true,
          'collection_identifier': {
            'access_value': {
              'min_value': 5.0,
              'max_value': 55.0,
              'include_undefined_value': true
            },
            'temporal': {
              'start_date': '2020-03-01T00:00:00Z',
              'stop_date': '2020-04-27T00:00:00Z',
              'mask': 'disjoint'
            }
          }
        }
      }

      @collection_permission_for_edit = add_group_permissions(previous_collection_permission)

      # while we can use stubbed groups for collection permissions, it seems
      # that we need to have ingested collections to create a collection
      # permission if it has selected collections
      ingest_response, concept_response_1 = publish_collection_draft
      @entry_id_1 = "#{concept_response_1.body['ShortName']}_#{concept_response_1.body['Version']}"
      ingest_response, concept_response_2 = publish_collection_draft
      @entry_id_2 = "#{concept_response_2.body['ShortName']}_#{concept_response_2.body['Version']}"
      ingest_response, concept_response_3 = publish_collection_draft
      @entry_id_3 = "#{concept_response_3.body['ShortName']}_#{concept_response_3.body['Version']}"

      wait_for_cmr
    end

    context 'when visiting the edit page' do
      before do
        visit edit_permission_path(@collection_permission_for_edit['concept_id'])
      end

      it 'populates the form with the collection permission information' do
        expect(page).to have_field('Name', with: 'Collection Permission to Edit 01', readonly: true)

        expect(page).to have_field('collection_applicable')
        expect(page).to have_field('granule_applicable')

        expect(page).to have_no_css('#collectionsChooser')

        within '#collection-access-constraints-container' do
          expect(page).to have_field('collection_access_value[min_value]', with: '5.0')
          expect(page).to have_field('collection_access_value[max_value]', with: '55.0')
          expect(page).to have_field('collection_access_value[include_undefined_value]', checked: true)
        end

        within '#search_groups_cell' do
          expect(page).to have_css('li.select2-selection__choice', text: 'All Guest Users')
        end

        within '#search_and_order_groups_cell' do
          expect(page).to have_css('li.select2-selection__choice', text: 'All Registered Users')
          expect(page).to have_css('li.select2-selection__choice', text: 'Group 1')
        end
      end

      context 'when updating the collection permission to have no access to collections' do
        before do
          uncheck('Collections')

          check('Granules')
          within '#granule-access-constraints-container' do
            fill_in('Minimum Value', with: 1.1)
            fill_in('Maximum Value', with: 8.8)
          end
          within '#granule-temporal-filter-container' do
            fill_in('Start Date', with: '2020-03-01T00:00:00Z')
            fill_in('Stop Date', with: '2020-04-27T00:00:00Z')
            choose('Disjoint')
          end

          select('Group 2', from: 'Search, Order, and S3 (If Available)')

          click_on 'Submit'

          wait_for_cmr
        end

        it 'successfully updates the collection permission and redirects to the show page and displaying the collection permission information' do
          expect(page).to have_content('Collection Permission to Edit 01')

          within '#collection-constraint-summary' do
            expect(page).to have_content('This permission does not grant access to collections.')
          end

          within '#granule-constraint-summary' do
            expect(page).to have_content('between 1.1 and 8.8')

            expect(page).to have_content('outside of')
            expect(page).to have_content('the date range 2020-03-01T00:00:00Z to 2020-04-27T00:00:00Z')
          end

          within '#permission-groups-table' do
            expect(page).to have_content('All Guest Users')
            expect(page).to have_content('All Registered Users')
            expect(page).to have_content('Group 1')
            expect(page).to have_content('Group 2')
          end
        end

        context 'when updating the collection permission with selected collections' do
          before do
            visit edit_permission_path(@collection_permission_for_edit['concept_id'])

            choose('Selected Collections')

            # choose the collections
            within '#collectionsChooser' do
              # selecting each individually as it seems more robust.
              select(@entry_id_1, from: 'Available Collections')
              find('.add_button').click

              select(@entry_id_2, from: 'Available Collections')
              find('.add_button').click

              select(@entry_id_3, from: 'Available Collections')
              find('.add_button').click
            end

            within '#search_and_order_groups_cell' do
              page.find('.select2-selection__choice[title="Group 1"] > .select2-selection__choice__remove').click
            end

            select('Group 3', from: 'Search, Order, and S3 (If Available)')

            click_on 'Submit'

            wait_for_cmr
          end

          it 'successfully updates the collection permission and redirects to the show page and displaying the collection permission information' do
            expect(page).to have_content('Collection Permission to Edit 01')

            within '#permission-groups-table' do
              expect(page).to have_content('All Guest Users')
              expect(page).to have_content('All Registered Users')
              expect(page).to have_content('Group 2')
              expect(page).to have_content('Group 3')
              expect(page).to have_no_content('Group 1')
            end
          end
        end
      end
    end
  end

  context 'when deleting a collection permission' do
    before do
      @collection_permission_to_delete = add_associated_permissions_to_group(group_id: group3_id, name: 'Testing Delete Collection Permission 01')

      visit permission_path(@collection_permission_to_delete['concept_id'])

      click_on 'Delete'
      click_on 'Yes'

      wait_for_cmr
    end

    it 'successfully deletes the collection permission and redirects to the index page and does not display the deleted collection permission' do
      expect(page).to have_content('Collection Permission was successfully deleted.')
      expect(page).to have_css('h2', text: 'Collection Permissions')
      expect(page).to have_no_content('Testing Delete Collection Permission 01')
    end
  end

  context 'when deleting a collection permission without proper permission' do
    before do
      failed_delete_acl_response = cmr_fail_response(JSON.parse(File.read('spec/fixtures/collection_permissions/failed_delete_acl_response.json')))
      allow_any_instance_of(Cmr::CmrClient).to receive(:delete_permission).and_return(failed_delete_acl_response)

      @collection_permission_to_delete_with_failure = add_associated_permissions_to_group(group_id: group3_id, name: 'Testing Delete Collection Permission 02')

      visit permission_path(@collection_permission_to_delete_with_failure['concept_id'])

      click_on 'Delete'
      click_on 'Yes'

      wait_for_cmr
    end

    it 'not successfully deletes the collection permission' do
      expect(page).to have_content("Permission to delete ACL is denied")
      expect(page).to have_content("Groups")
      expect(page).to have_content("Search")
      expect(page).to have_content("Order")
    end
  end

end
