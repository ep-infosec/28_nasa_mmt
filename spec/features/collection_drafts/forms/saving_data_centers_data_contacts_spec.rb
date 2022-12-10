# rails_helper require was added for RAILS5 upgrade to eliminate a race condition
require 'rails_helper'

describe 'Saving Data Contacts and Data Centers', js: true do
  before do
    login
  end

  context 'when saving Data Contacts when Data Centers already exist' do
    before do
      draft = create(:collection_draft_all_required_fields, user: User.where(urs_uid: 'testuser').first)
      visit collection_draft_path(draft)

    end

    it 'has the Data Center on the preview page' do
      within '#metadata-preview' do
        expect(page).to have_content('AARHUS-HYDRO')
        expect(page).to have_content('Hydrogeophysics Group, Aarhus University')
      end
    end

    context 'when adding a Non Data Center Contact' do
      before do
        click_on 'Data Contacts', match: :first

        select 'Non Data Center Contact Group', from: 'Data Contact Type'

        within '.multiple.data-contacts' do
          select 'Data Center Contact', from: 'Role'
          select 'User Services', from: 'Role'
          fill_in 'Group Name', with: 'NDC Group Name'
          fill_in 'Non Data Center Affiliation', with: 'Big Name Research Lab'
        end

        within '.nav-top' do
          click_on 'Done'
        end

        expect(page).to have_content('Metadata Fields')
      end

      it 'displays the Data Contact on the preview page' do
        within '#metadata-preview' do
          expect(page).to have_content('NDC Group Name')
          expect(page).to have_content('Big Name Research Lab')
          expect(page).to have_content('AARHUS-HYDRO')
          expect(page).to have_content('Hydrogeophysics Group, Aarhus University')
        end
      end

      context 'when then adding another Data Center' do
        before do
          click_on 'Data Centers', match: :first

          expect(page).to have_content('Data Centers')
          click_on 'Add another Data Center'

          within '.multiple.data-centers > .multiple-item-1' do
            select 'Originator', from: 'Role'
            add_data_center_with_retry('ESA/ED')
          end

          within '.nav-top' do
            click_on 'Done'
          end

          expect(page).to have_content('Metadata Fields')
        end

        it 'displays both Data Centers on the preview page' do
          within '#metadata-preview' do
            expect(page).to have_content('AARHUS-HYDRO')
            expect(page).to have_content('Hydrogeophysics Group, Aarhus University')

            expect(page).to have_content('ESA/ED')
            expect(page).to have_content('Educational Office, Ecological Society of America')
            expect(page).to have_content('ORIGINATOR')
          end
        end

        it 'still displays the Data Contact on the preview page' do
          within '#metadata-preview' do
            expect(page).to have_content('NDC Group Name')
            expect(page).to have_content('Big Name Research Lab')
          end
        end
      end

    end
  end
end
