describe 'Invalid Service Draft Service Information Preview' do
  let(:service_draft) { create(:invalid_service_draft, user: User.where(urs_uid: 'testuser').first) }
  let(:draft)         { service_draft.draft }

  before do
    login
    visit service_draft_path(service_draft)
  end

  context 'When examining the Service Information section' do
    let(:anchors) { %w[name-label long-name-label type-label version-label description-label url] }

    it 'displays the form title as an edit link' do
      within '#service_information-progress' do
        expect(page).to have_link('Service Information', href: edit_service_draft_path(service_draft, 'service_information'))
      end
    end

    it 'displays the correct status icon' do
      within '#service_information-progress' do
        within '.status' do
          expect(page).to have_content('Service Information is incomplete')
        end
      end
    end

    it 'displays the correct progress indicators for invalid fields' do
      within '#service_information-progress .progress-indicators' do
        anchors.each do |anchor|
          expect(page).to have_css(".eui-icon.eui-fa-minus-circle.icon-red.#{anchor}")
          expect(page).to have_link(nil, href: edit_service_draft_path(service_draft, 'service_information', anchor: anchor))
        end
      end
    end

    it 'displays the stored values correctly within the preview' do
      within '.umm-preview.service_information' do
        expect(page).to have_css('.umm-preview-field-container', count: 10)

        within '#service_draft_draft_name_preview' do
          expect(page).to have_css('h5', text: 'Name')
          expect(page).to have_link(nil, href: edit_service_draft_path(service_draft, 'service_information', anchor: 'service_draft_draft_name'))

          expect(page).to have_css('p', text: draft['Name'])
        end

        within '#service_draft_draft_long_name_preview' do
          expect(page).to have_css('h5', text: 'Long Name')
          expect(page).to have_link(nil, href: edit_service_draft_path(service_draft, 'service_information', anchor: 'service_draft_draft_long_name'))

          expect(page).to have_css('p', text: draft['LongName'])
        end

        within '#service_draft_draft_type_preview' do
          expect(page).to have_css('h5', text: 'Type')
          expect(page).to have_link(nil, href: edit_service_draft_path(service_draft, 'service_information', anchor: 'service_draft_draft_type'))

          expect(page).to have_css('p', text: draft['Type'])
        end

        within '#service_draft_draft_version_preview' do
          expect(page).to have_css('h5', text: 'Version')
          expect(page).to have_link(nil, href: edit_service_draft_path(service_draft, 'service_information', anchor: 'service_draft_draft_version'))

          expect(page).to have_css('p', text: draft['Version'])
        end

        within '#service_draft_draft_description_preview' do
          expect(page).to have_css('h5', text: 'Description')
          expect(page).to have_link(nil, href: edit_service_draft_path(service_draft, 'service_information', anchor: 'service_draft_draft_description'))

          expect(page).to have_css('p', text: draft['Description'])
        end

        within '#service_draft_draft_url_preview' do
          expect(page).to have_css('h5', text: 'Description')
          expect(page).to have_link(nil, href: edit_service_draft_path(service_draft, 'service_information', anchor: 'service_draft_draft_url'))

          expect(page).to have_css('p', text: draft['URL']['Description'])
        end
      end
    end
  end
end
