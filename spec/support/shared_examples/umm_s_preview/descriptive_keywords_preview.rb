shared_examples_for 'Descriptive Keywords Full Preview' do
  it 'displays the stored values correctly within the preview' do
    within '.umm-preview.descriptive_keywords' do
      expect(page).to have_css('.umm-preview-field-container', count: 2)

      within '#service_service_keywords_preview, #service_draft_draft_service_keywords_preview' do
        keyword_parts = page.all('ul.arrow-tag-group-list').first.all('li.arrow-tag-group-item')
        expect(keyword_parts[0]).to have_content('EARTH SCIENCE SERVICES')
        expect(keyword_parts[1]).to have_content('DATA ANALYSIS AND VISUALIZATION')
        expect(keyword_parts[2]).to have_content('GEOGRAPHIC INFORMATION SYSTEMS')
        expect(keyword_parts[3]).to have_content('DESKTOP GEOGRAPHIC INFORMATION SYSTEMS')
      end

      within '#service_ancillary_keywords_preview, #service_draft_draft_ancillary_keywords_preview' do
        expect(page).to have_css("h6", text: 'Ancillary Keyword 1')
        expect(page).to have_css("p", text: 'Ancillary keyword 1')
        expect(page).to have_css("h6", text: 'Ancillary Keyword 2')
        expect(page).to have_css("p", text: 'Ancillary keyword 2')
      end
    end
  end
end