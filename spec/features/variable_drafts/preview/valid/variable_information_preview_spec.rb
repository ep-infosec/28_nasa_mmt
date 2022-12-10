describe 'Valid Variable Draft Variable Information Preview' do
  let(:variable_draft) { create(:full_variable_draft, draft_entry_title: 'Volume mixing ratio of sum of peroxynitrates in air', draft_short_name: 'PNs_LIF', user: User.where(urs_uid: 'testuser').first) }

  before do
    login
    visit variable_draft_path(variable_draft)
  end

  context 'When examining the Variable Information section' do
    let(:anchors_req)     { %w[name-label definition-label long-name-label] }
    let(:anchors_non_req) { %w[standard-name-label additional-identifiers-label variable-type-label variable-sub-type-label units-label data-type-label scale-label offset-label valid-ranges-label index-ranges-label] }

    context 'when examining the progress circles section' do
      it 'displays the form title as an edit link' do
        within '#variable_information-progress' do
          expect(page).to have_link('Variable Information', href: edit_variable_draft_path(variable_draft, 'variable_information'))
        end
      end

      it 'displays the correct status icon' do
        within '#variable_information-progress' do
          within '.status' do
            expect(page).to have_css('.eui-icon.icon-green.eui-check')
          end
        end
      end

      it 'displays the correct progress indicators for required fields' do
        within '#variable_information-progress .progress-indicators' do
          anchors_req.each do |anchor|
            expect(page).to have_css(".eui-icon.eui-required.icon-green.#{anchor}")
            expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: anchor))
          end
        end
      end

      it 'displays the correct progress indicators for non required fields' do
        within '#variable_information-progress .progress-indicators' do
          anchors_non_req.each do |anchor|
            expect(page).to have_css(".eui-icon.eui-fa-circle.icon-grey.#{anchor}")
            expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: anchor))
          end
        end
      end
    end

    context 'when examining the metadata preview section' do
      it 'displays links to edit/update the data' do
        within(first('.umm-preview.variable_information')) do
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_name'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_long_name'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_definition'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_standard_name'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_additional_identifiers'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_additional_identifiers_0_identifier'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_additional_identifiers_0_description'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_additional_identifiers_1_identifier'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_additional_identifiers_1_description'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_variable_type'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_variable_sub_type'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_units'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_data_type'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_scale'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_offset'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_valid_ranges'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_valid_ranges_0_min'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_valid_ranges_0_max'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_valid_ranges_0_code_system_identifier_meaning'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_valid_ranges_0_code_system_identifier_value'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_valid_ranges_1_min'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_valid_ranges_1_max'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_valid_ranges_1_code_system_identifier_meaning'))
          expect(page).to have_link(nil, href: edit_variable_draft_path(variable_draft, 'variable_information', anchor: 'variable_draft_draft_valid_ranges_1_code_system_identifier_value'))
        end
      end

      include_examples 'Variable Information Full Preview'
    end
  end
end
