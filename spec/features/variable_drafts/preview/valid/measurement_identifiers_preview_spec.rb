describe 'Valid Variable Draft Measurement Identifiers Preview' do
  let(:variable_draft) { create(:full_variable_draft, user: User.where(urs_uid: 'testuser').first) }

  before do
    login
    visit variable_draft_path(variable_draft)
  end

  context 'When examining the Measurement Identifiers section' do
    context 'when examining the progress circles section' do
      it 'displays the form title as an edit link' do
        within '#measurement_identifiers-progress' do
          expect(page).to have_link('Measurement Identifiers', href: edit_variable_draft_path(variable_draft, 'measurement_identifiers'))
        end
      end

      it 'displays the current status icon' do
        within '#measurement_identifiers-progress .status' do
          expect(page).to have_css('.eui-icon.icon-green.eui-check')
        end
      end

      it 'displays the correct progress indicators for non required fields' do
        within '#measurement_identifiers-progress .progress-indicators' do
          expect(page).to have_css('.eui-icon.eui-fa-circle.icon-grey.measurement-identifiers')
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'measurement-identifiers'))
        end
      end
    end

    context 'when examining the metadata preview section' do
      it 'displays links to edit/update the data' do
        within '.umm-preview.measurement_identifiers' do
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_0_measurement_context_medium'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_0_measurement_context_medium_uri'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_0_measurement_object'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_0_measurement_object_uri'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_0_measurement_quantities_0_value'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_0_measurement_quantities_0_measurement_quantity_uri'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_0_measurement_quantities_1_value'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_0_measurement_quantities_1_measurement_quantity_uri'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_1_measurement_context_medium'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_1_measurement_context_medium_uri'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_1_measurement_object'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_1_measurement_object_uri'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_1_measurement_quantities_0_value'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'measurement_identifiers', anchor: 'variable_draft_draft_measurement_identifiers_1_measurement_quantities_0_measurement_quantity_uri'))
        end
      end

      include_examples 'Variable Measurement Identifiers Full Preview'
    end
  end
end
