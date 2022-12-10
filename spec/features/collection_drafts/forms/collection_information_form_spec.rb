describe 'Collection Information form', js: true do
  before do
    login
    draft = create(:collection_draft, user: User.where(urs_uid: 'testuser').first)
    visit collection_draft_path(draft)
    within '.metadata' do
      click_on 'Collection Information'
    end
  end
  
  context 'when checking the accordion headers for required icons' do
    it 'displays required icons on the Collection Information accordion' do
      expect(page).to have_css('h3.eui-required-o.always-required', count: 1)
      expect(page).to have_css('h3.eui-required-o.always-required', text: 'Collection Information')
    end
  end

  context 'when submitting the form' do
    before do

      fill_in 'Short Name', with: '12345'
      fill_in 'Version', with: 'v2'
      fill_in 'Version Description', with: 'v2 description'
      fill_in 'Entry Title', with: 'Draft Title'
      script = '$("#draft_doi_NotAvailable").click();'
      page.execute_script script
      select 'Not Applicable', from: 'Missing Reason'
      fill_in 'Explanation', with: 'No DOI here'
      fill_in 'DOI', with: 'Associated DOI'
      fill_in 'Title', with: 'Associated DOI Title'
      fill_in 'Authority', with: 'Associated DOI Authority'
      fill_in 'Abstract', with: 'This is a long description of the collection'
      fill_in 'Purpose', with: 'This is the purpose field'
      select 'English', from: 'Data Language'

      within '.nav-top' do
        click_on 'Save'
      end
    end

    it 'does not have a template name field' do
      expect(page).to have_no_field('Template Name')
    end

    it 'displays a confirmation message' do
      expect(page).to have_content('Collection Draft Updated Successfully!')
    end

    it 'populates the form with the values' do
      expect(page).to have_field('Short Name', with: '12345')
      expect(page).to have_field('Version', with: 'v2')
      expect(page).to have_field('Version Description', with: 'v2 description')
      expect(page).to have_field('Entry Title', with: 'Draft Title')
      expect(page).to have_field('Missing Reason', with: 'Not Applicable')
      expect(page).to have_field('Explanation', with: 'No DOI here')
      expect(page).to have_field('DOI', with: 'Associated DOI')
      expect(page).to have_field('Title', with: 'Associated DOI Title')
      expect(page).to have_field('Authority', with: 'Associated DOI Authority')
      expect(page).to have_field('Abstract', with: 'This is a long description of the collection')
      expect(page).to have_field('Purpose', with: 'This is the purpose field')
      expect(page).to have_field('Data Language', with: 'eng')
    end
  end
end
