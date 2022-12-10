describe 'Delete Collection', js: true do
  before :all do
    collection_with_granule_title = SecureRandom.uuid
    @collection_with_granule_ingest_response, _collection_concept_response = publish_collection_draft(entry_title: collection_with_granule_title)
    _granule_ingest_response, _granule_concept_response = ingest_granules(collection_entry_title: collection_with_granule_title, count: 1)

    collection_with_granule_and_variable_title = SecureRandom.uuid
    @collection_with_granule_and_variable_ingest_response, _collection_concept_response = publish_collection_draft(entry_title: collection_with_granule_and_variable_title)
    _granule_ingest_response, _granule_concept_response = ingest_granules(collection_entry_title: collection_with_granule_and_variable_title, count: 2)
    _variable_ingest_response, _variable_concept_response = publish_variable_draft(collection_concept_id: @collection_with_granule_and_variable_ingest_response['concept-id'])

    @collection_with_variable_ingest_response, _collection_concept_response = publish_collection_draft
    _variable_ingest_response, _variable_concept_response = publish_variable_draft(collection_concept_id: @collection_with_variable_ingest_response['concept-id'])
    _variable_ingest_response, _variable_concept_response = publish_variable_draft(collection_concept_id: @collection_with_variable_ingest_response['concept-id'])

    @ingested_collection_for_delete_messages, _concept_response = publish_collection_draft

    wait_for_cmr # improves reliabliity of finding granules for collection
  end

  before do
    login
  end

  context 'when viewing a published collection' do
    context 'when the collection is in the current provider context' do
      before do
        ingest_response, _concept_response = publish_collection_draft

        visit collection_path(ingest_response['concept-id'])
      end

      context 'when the collection has no granules' do
        it 'displays a delete link' do
          expect(page).to have_content('Delete Collection Record')
        end

        context 'when clicking the delete link' do
          before do
            click_on 'Delete Collection Record'

            within '#delete-record-modal' do
              click_on 'Yes'
            end
          end

          it 'redirects to the revisions page and displays a confirmation message' do
            expect(page).to have_content('Collection Deleted Successfully!')

            expect(page).to have_content('Revision History')
            expect(page).to have_selector('tbody > tr', count: 2)

            within first('tbody > tr') do
              expect(page).to have_content('Deleted')
            end

            expect(page).to have_content('Reinstate', count: 1)
          end
        end
      end
    end

    context 'when switching provider context while deleting' do
      before do
        ingest_response_2, _concept_response = publish_collection_draft
        login(provider: 'LARC', providers: %w[MMT_2 LARC])
        visit collection_path(ingest_response_2['concept-id'])
      end

      context 'when the collection has no granules or variables' do
        context 'when clicking the delete link' do
          before do
            click_on 'Delete Collection Record'
          end

          it 'displays the provider context switch modal' do
            expect(page).to have_content('Deleting this collection requires you change your provider context to MMT_2. Would you like to change your provider context and perform this action?')
          end

          context 'when changing provider context' do
            before do
              find('.not-current-provider-link').click
            end

            it 'redirects to the revisions page and displays a confirmation message' do
              expect(page).to have_content('Collection Deleted Successfully!')

              expect(page).to have_content('Revision History')
              expect(page).to have_selector('tbody > tr', count: 2)

              within first('tbody > tr') do
                expect(page).to have_content('Deleted')
              end

              expect(page).to have_content('Reinstate', count: 1)
            end
          end
        end
      end
    end
  end

  context 'when viewing a published collection with records that will be cascade deleted' do
    context 'when the collection is in the current provider context' do
      context 'when viewing a published collection with granules' do
        before do
          visit collection_path(@collection_with_granule_ingest_response['concept-id'])
        end

        it 'displays the number of granules' do
          expect(page).to have_content('Granules (1)')
        end

        context 'when clicking the delete link' do
          before do
            click_on 'Delete Collection Record'
          end

          it 'displays the correct warning text and has a confirmation text field' do
            expect(page).to have_content('This collection has 1 associated granule.')
            expect(page).to have_content('Deleting this collection will delete all associated granules.')
            expect(page).to have_content('Please confirm that you wish to continue by entering "I want to delete this collection and the associated records" below.')
            expect(page).to have_field('confirmation-text')
            within '#cascade-delete-modal' do
              expect(page).to have_link('Cancel', href: 'javascript:void(0);')
              expect(page).to have_link('Close', href: 'javascript:void(0);')
            end
          end

          context 'when the user provides the incorrect confirmation text' do
            before do
              fill_in 'confirmation-text', with: 'Incorrect confirmation text'
              click_on 'Delete Collection'
            end

            it 'does not delete the record' do
              expect(page).to have_content('Collection was not deleted because incorrect confirmation text was provided.')
            end
          end
        end
      end

      context 'when viewing a published collection with granules and variables' do
        before do
          visit collection_path(@collection_with_granule_and_variable_ingest_response['concept-id'])
        end

        it 'displays the number of granules' do
          expect(page).to have_content('Granules (2)')
        end

        context 'when clicking the delete link' do
          before do
            click_on 'Delete Collection Record'
          end

          it 'displays the correct warning text and has a confirmation text field' do
            expect(page).to have_content('This collection has 2 associated granules and 1 associated variable.')
            expect(page).to have_content('Deleting this collection will delete all associated granules and variables.')
            expect(page).to have_content('Please confirm that you wish to continue by entering "I want to delete this collection and the associated records" below.')
            expect(page).to have_field('confirmation-text')
            within '#cascade-delete-modal' do
              expect(page).to have_link('Cancel', href: 'javascript:void(0);')
              expect(page).to have_link('Close', href: 'javascript:void(0);')
            end
          end

          context 'when the user provides the incorrect confirmation text' do
            before do
              fill_in 'confirmation-text', with: 'Incorrect confirmation text'
              click_on 'Delete Collection'
            end

            it 'does not delete the record' do
              expect(page).to have_content('Collection was not deleted because incorrect confirmation text was provided.')
            end
          end
        end
      end

      context 'when viewing a published collection with variables' do
        before do
          visit collection_path(@collection_with_variable_ingest_response['concept-id'])
        end

        it 'displays the number of granules' do
          expect(page).to have_content('Granules (0)')
        end

        context 'when clicking the delete link' do
          before do
            click_on 'Delete Collection Record'
          end

          it 'displays the correct warning text and has a confirmation text field' do
            expect(page).to have_content('This collection has 2 associated variables.')
            expect(page).to have_content('Deleting this collection will delete all associated variables.')
            expect(page).to have_content('Please confirm that you wish to continue by entering "I want to delete this collection and the associated records" below.')
            expect(page).to have_field('confirmation-text')
            within '#cascade-delete-modal' do
              expect(page).to have_link('Cancel', href: 'javascript:void(0);')
              expect(page).to have_link('Close', href: 'javascript:void(0);')
            end
          end

          context 'when the user provides the incorrect confirmation text' do
            before do
              fill_in 'confirmation-text', with: 'Incorrect confirmation text'
              click_on 'Delete Collection'
            end

            it 'does not delete the record' do
              expect(page).to have_content('Collection was not deleted because incorrect confirmation text was provided.')
            end
          end
        end
      end

      context 'when deleting the collection by providing the correct confirmation text' do
        context 'when the collection has granules' do
          before do
            collection_title = SecureRandom.uuid
            collection_ingest_response, _collection_concept_response = publish_collection_draft(entry_title: collection_title)
            _granule_ingest_response, _granule_concept_response = ingest_granules(collection_entry_title: collection_title, count: 1)
            wait_for_cmr # improves reliabliity of finding granules for collection

            visit collection_path(collection_ingest_response['concept-id'])
          end

          context 'when the user provides the correct confirmation text' do
            before do
              click_on 'Delete Collection Record'

              fill_in 'confirmation-text', with: 'I want to delete this collection and the associated records'
              click_on 'Delete Collection'
            end

            it 'deletes the record' do
              expect(page).to have_content('Collection Deleted Successfully!')
            end
          end
        end

        context 'when the collection has variables' do
          before do
            collection_ingest_response, _collection_concept_response = publish_collection_draft
            _variable_ingest_response, _variable_concept_response = publish_variable_draft(collection_concept_id: collection_ingest_response['concept-id'])

            visit collection_path(collection_ingest_response['concept-id'])
          end

          context 'when the user provides the correct confirmation text' do
            before do
              click_on 'Delete Collection Record'

              fill_in 'confirmation-text', with: 'I want to delete this collection and the associated records'
              click_on 'Delete Collection'
            end

            it 'deletes the record' do
              expect(page).to have_content('Collection Deleted Successfully!')
            end
          end
        end
      end
    end

    context 'when switching provider context while deleting' do
      before do
        login(provider: 'LARC', providers: %w[MMT_2 LARC])
      end

      context 'when viewing a published collection with granules and variables' do
        before do
          visit collection_path(@collection_with_granule_and_variable_ingest_response['concept-id'])
        end

        it 'displays the number of granules' do
          expect(page).to have_content('Granules (2)')
        end

        context 'when clicking the delete link' do
          before do
            click_on 'Delete Collection Record'
          end

          it 'displays the provider context switch modal' do
            expect(page).to have_content('Deleting this collection requires you change your provider context to MMT_2. Would you like to change your provider context and perform this action?')
          end

          context 'when changing provider context' do
            before do
              find('.not-current-provider-link').click
            end

            it 'displays the correct warning text and has a confirmation text field' do
              expect(page).to have_content('This collection has 2 associated granules and 1 associated variable.')
              expect(page).to have_content('Deleting this collection will delete all associated granules and variables.')
              expect(page).to have_content('Please confirm that you wish to continue by entering "I want to delete this collection and the associated records" below.')
              expect(page).to have_field('confirmation-text')
              within '#cascade-delete-modal' do
                expect(page).to have_link('Cancel', href: collection_path(@collection_with_granule_and_variable_ingest_response['concept-id']))
                expect(page).to have_link('Close', href: collection_path(@collection_with_granule_and_variable_ingest_response['concept-id']))
              end
            end

            context 'when the user provides the incorrect confirmation text' do
              before do
                fill_in 'confirmation-text', with: 'Incorrect confirmation text'
                click_on 'Delete Collection'
              end

              it 'does not delete the record' do
                expect(page).to have_content('Collection was not deleted because incorrect confirmation text was provided.')
              end
            end

            context 'when the user cancels from the delete confirmation modal' do
              before do
                click_on 'Cancel'
              end

              it 'refreshes the page' do
                within '.eui-badge--sm.daac' do
                  expect(page).to have_content('MMT_2')
                end
              end
            end

            context 'when the user closes the delete confirmation modal' do
              before do
                within '#cascade-delete-modal' do
                  click_on 'Close'
                end
              end

              it 'refreshes the page' do
                within '.eui-badge--sm.daac' do
                  expect(page).to have_content('MMT_2')
                end
              end
            end
          end
        end
      end

      context 'when deleting the collection by providing the correct confirmation text' do
        before do
          collection_title = SecureRandom.uuid
          collection_ingest_response, _collection_concept_response = publish_collection_draft(entry_title: collection_title)
          _granule_ingest_response, _granule_concept_response = ingest_granules(collection_entry_title: collection_title, count: 1)
          wait_for_cmr # improves reliabliity of finding granules for collection

          visit collection_path(collection_ingest_response['concept-id'])
        end

        context 'when clicking the delete link' do
          before do
            click_on 'Delete Collection Record'
          end
          context 'when changing provider context' do
            before do
              find('.not-current-provider-link').click
            end
            context 'when the user provides the correct confirmation text' do
              before do
                fill_in 'confirmation-text', with: 'I want to delete this collection and the associated records'
                click_on 'Delete Collection'
              end

              it 'deletes the record' do
                expect(page).to have_content('Collection Deleted Successfully!')
              end
            end
          end
        end
      end
    end
  end

  context 'when viewing a published collection with a non url encoded native id' do
    before do
      ingest_response, _concept_response = publish_collection_draft(native_id: 'not & url, encoded / native id')

      visit collection_path(ingest_response['concept-id'])
    end

    context 'when clicking the delete link' do
      before do
        click_on 'Delete Collection Record'

        within '#delete-record-modal' do
          click_on 'Yes'
        end
      end

      it 'displays a confirmation message' do
        expect(page).to have_content('Collection Deleted Successfully!')
      end
    end
  end

  context 'when deleting the collection will fail' do
    before do
      visit collection_path(@ingested_collection_for_delete_messages['concept-id'])
    end

    context 'when CMR provides a message' do
      before do
        error_body = '{"errors": ["You do not have permission to perform that action."]}'
        error_response = Cmr::Response.new(Faraday::Response.new(status: 401, body: JSON.parse(error_body), response_headers: {}))
        allow_any_instance_of(Cmr::CmrClient).to receive(:delete_collection).and_return(error_response)

        click_on 'Delete Collection Record'

        within '#delete-record-modal' do
          click_on 'Yes'
        end
      end

      it 'displays the CMR error message' do
        expect(page).to have_css('.eui-banner--danger', text: 'You do not have permission to perform that action.')
      end
    end

    context 'when CMR does not provide a message' do
      before do
        error_body = '{"message": "useless message"}'
        error_response = Cmr::Response.new(Faraday::Response.new(status: 401, body: JSON.parse(error_body), response_headers: {}))
        allow_any_instance_of(Cmr::CmrClient).to receive(:delete_collection).and_return(error_response)

        click_on 'Delete Collection Record'

        within '#delete-record-modal' do
          click_on 'Yes'
        end
      end

      it 'displays the CMR error message' do
        expect(page).to have_css('.eui-banner--danger', text: 'Collection was not deleted successfully')
      end
    end
  end
end
