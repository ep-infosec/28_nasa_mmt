# MMT-52

require 'rails_helper'

describe 'Draft form help text', js: true do
  before do
    login
    draft = create(:collection_draft, user: User.where(urs_uid: 'testuser').first)
    visit collection_draft_path(draft)
  end

  context 'when viewing a form' do
    context 'when clicking on the help icon with a description' do
      before do
        within '.metadata' do
          click_on 'Collection Information'
        end

        click_on 'Help modal for Short Name'
      end

      it 'displays the field name in a modal' do
        expect(page).to have_content('Short Name')
      end

      it 'displays the description in a modal' do
        expect(page).to have_content('The short name associated with the collection.')
      end
    end

    context 'when clicking on the help icon with minItems' do
      before do
        within '.metadata' do
          click_on 'Related URLs', match: :first
        end

        open_accordions

        click_on 'Help modal for Related URLs'
      end

      it 'displays the validation clue in the modal' do
        expect(page).to have_content('Minimum Items: 1')
      end
    end

    context 'when clicking on the help icon with minLength' do
      before do
        within '.metadata' do
          click_on 'Collection Information'
        end

        click_on 'Help modal for Short Name'
      end

      it 'displays the validation clue in the modal' do
        expect(page).to have_content('Minimum Length: 1')
      end
    end

    context 'when clicking on the help icon with maxLength' do
      before do
        within '.metadata' do
          click_on 'Collection Information'
        end

        click_on 'Help modal for Short Name'
      end

      it 'displays the validation clue in the modal' do
        expect(page).to have_content('Maximum Length: 85')
      end
    end

    # context 'when clicking on the help icon with a pattern' do
    #   before do
    #     find(:xpath, "//a/i[@data-help-path='definitions/OrganizationNameType/properties/Uuid']/..").click # Uuid
    #   end
    #
    #   it 'displays the validation clue in the modal' do
    #     expect(page).to have_content('Pattern: [0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89abAB][0-9a-f]{3}-[0-9a-f]{12}')
    #   end
    # end

    context 'when clicking on the help icon with a format' do
      before do
        within '.metadata' do
          click_on 'Data Identification'
        end

        open_accordions

        click_on 'Help modal for Date'
      end

      it 'displays the validation clue in the modal' do
        expect(page).to have_content("Format: date-time (yyyy-MM-dd'T'HH:mm:ssZ)")
      end
    end

    context 'when clicking on the help icon with a help link in Collection Information' do
      before do
        within '.metadata' do
          click_on 'Collection Information'
        end

        click_on 'Help modal for Version'
      end

      it 'displays the help link in the modal' do
        expect(page).to have_link('View More Information', href: 'https://wiki.earthdata.nasa.gov/display/CMR/Version')
      end
    end

    context 'when clicking on the help icon with a help link in Data Identification' do
      before do
        within '.metadata' do
          click_on 'Data Identification'
        end

        click_on 'Help modal for Data Dates'
      end

      it 'displays the help link in the modal' do
        expect(page).to have_link('View More Information', href: 'https://wiki.earthdata.nasa.gov/display/CMR/Data+Dates')
      end
    end

    context 'when clicking on the help icon with a help link in Descriptive Keywords' do
      before do
        within '.metadata' do
          click_on 'Descriptive Keywords'
        end

        click_on 'Help modal for Ancillary Keywords'
      end

      it 'displays the help link in the modal' do
        expect(page).to have_link('View More Information', href: 'https://wiki.earthdata.nasa.gov/display/CMR/Ancillary+Keywords')
      end
    end

    context 'when clicking on the help icon with a help link in Metadata Information' do
      before do
        within '.metadata' do
          click_on 'Metadata Information'
        end

        click_on 'Help modal for Metadata Language'
      end

      it 'displays the help link in the modal' do
        expect(page).to have_link('View More Information', href: 'https://wiki.earthdata.nasa.gov/display/CMR/Metadata+Language')
      end
    end

    context 'when clicking on the help icon with a help link in Spatial Information' do
      before do
        first('#spatial-information > div.meta-info > a').click

        click_on 'Help modal for Tiling Identification Systems'
      end

      it 'displays the help link in the modal' do
        expect(page).to have_link('View More Information', href: 'https://wiki.earthdata.nasa.gov/display/CMR/Tiling+Identification+System')
      end
    end

    context 'when clicking on the help icon with a help link in Data Contacts' do
      before do
        within '#data-contacts .meta-info' do
          click_link 'Data Contacts', match: :first
        end

        select 'Data Center Contact Group', from: 'Data Contact Type'
        click_on 'Help modal for Data Center Contact Group'
      end

      it 'displays the help link in the modal' do
        expect(page).to have_link('View More Information', href: 'https://wiki.earthdata.nasa.gov/display/CMR/Data+Center+-+Contact+Group')
      end
    end
  end
end
