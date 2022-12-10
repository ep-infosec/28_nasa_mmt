describe 'Draft form accordions', js: true do
  before do
    login
    @draft = create(:collection_draft, user: User.where(urs_uid: 'testuser').first)
  end

  context 'when clicking on the header' do
    before do
      visit edit_collection_draft_path(@draft, form: 'acquisition_information')

      # Open the Platforms fieldset accordion
      all('fieldset.eui-accordion > div.eui-accordion__header').first.click

      # Collapse the Platform 1 accordion
      find('.multiple.platforms > .multiple-item-0 > .eui-accordion__header').click
    end

    it 'collapses the accordion' do
      expect(page).to have_css('.multiple-item-0.is-closed')
    end

    it 'hides the fields' do
      expect(page).to have_no_field('Long Name')
    end

    context 'when clicking on the header again' do
      before do
        # Open the Platform 1 accordion
        find('.multiple.platforms > .multiple-item-0.is-closed > .eui-accordion__header').click
      end

      it 'opens the accordion' do
        expect(page).to have_no_css('.multiple-item-0.is-closed')
      end

      it 'shows the fields' do
        expect(page).to have_field('Long Name')
      end
    end
  end

  context 'when viewing a form with only one accordion' do
    before do
      visit edit_collection_draft_path(@draft, form: 'data_centers')
    end

    it 'shows the accordion open by default' do
      expect(page).to have_no_css('.eui-accordion.is-closed')
    end

    it 'does not display an Expand All link' do
      expect(page).to have_no_link('Expand All')
    end

    context 'when clicking on the accordion header' do
      before do
        first('.eui-accordion__header').click
        # sleep 0.5
      end

      it 'does not allow the user to collapse the accordion' do
        expect(page).to have_selector('#draft_data_centers_0_roles', visible: true)
      end
    end
  end

  context 'when clicking a help icon within the accordion header' do
    before do
      visit edit_collection_draft_path(@draft, form: 'metadata_information')
      click_on 'Help modal for Metadata Language'
    end

    it 'displays the help text' do
      within '#help-modal' do
        expect(page).to have_content('Metadata Language')
      end
    end

    it 'does not open the accordion' do
      expect(page).to have_no_field('Metadata Language')
    end
  end

  context 'when clicking the Expand All link' do
    before do
      visit edit_collection_draft_path(@draft, form: 'metadata_information')
      click_on 'Expand All'
    end

    it 'hides the Expand All link' do
      expect(page).to have_link('Expand All', visible: false)
    end

    it 'displays a Collapse All link' do
      expect(page).to have_link('Collapse All')
    end

    it 'expands all the accordions on the page' do
      expect(page).to have_no_css('.eui-accordion.is-closed')
    end

    context 'when clicking the Collapse All link' do
      before do
        click_on 'Collapse All'
      end

      it 'hides the Collapse All link' do
        expect(page).to have_link('Collapse All', visible: false)
      end

      it 'displays a Expand All link' do
        expect(page).to have_link('Expand All')
      end

      it 'collapses all the accordions on the page' do
        expect(page).to have_css('.eui-accordion', count: 2)
        expect(page).to have_css('.eui-accordion.is-closed', count: 2)
      end
    end
  end

  context 'when expanding all accordions manually' do
    before do
      visit edit_collection_draft_path(@draft, form: 'metadata_information')

      within '#metadata-language.eui-accordion' do
        find('.eui-accordion__header').click
      end
      within '#metadata-dates.eui-accordion' do
        find('.eui-accordion__header').click
      end
    end

    it 'changes the Expand All link to Collapse All' do
      expect(page).to have_link('Expand All', visible: false)
      expect(page).to have_link('Collapse All')
    end
  end

  context 'when collapsing all accordions manually' do
    before do
      visit edit_collection_draft_path(@draft, form: 'acquisition_information')

      within '#platforms.eui-accordion' do
        all('.eui-accordion__header').first.click
      end
    end

    it 'changes the Collapse All link to Expand All' do
      expect(page).to have_link('Collapse All', visible: false)
      expect(page).to have_link('Expand All')
    end
  end
end
