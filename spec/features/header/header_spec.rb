describe 'Header' do
  before :all do
    @original_c_config = Rails.configuration.umm_c_version
    Rails.configuration.umm_c_version = "vnd.nasa.cmr.umm+json; version=2.34"
    @original_var_config = Rails.configuration.umm_var_version
    Rails.configuration.umm_var_version = "vnd.nasa.cmr.umm+json; version=3.45"
    @original_s_config = Rails.configuration.umm_s_version
    Rails.configuration.umm_s_version = "vnd.nasa.cmr.umm+json; version=4.56"
    @original_t_config = Rails.configuration.umm_t_version
    Rails.configuration.umm_t_version = "vnd.nasa.cmr.umm+json; version=5.67"
  end

  after :all do
    Rails.configuration.umm_c_version = @original_c_config
    Rails.configuration.umm_var_version = @original_var_config
    Rails.configuration.umm_s_version = @original_s_config
    Rails.configuration.umm_t_version = @original_t_config
  end

  before do
    login
  end

  context 'when viewing the header' do
    context 'when proposal mode is turned off' do
      before do
        set_as_mmt_proper
      end

      context 'when the user does not have Draft MMT Approver permissions' do
        before do
          allow_any_instance_of(PermissionChecking).to receive(:is_non_nasa_draft_approver?).and_return(false)
        end

        context 'from the Manage Collections page' do
          before do
            visit manage_collections_path
          end

          it 'has "Manage Collections" as the underlined current header link' do
            within 'main header' do
              expect(page).to have_css('h2.current', text: 'Manage Collections')
            end
          end

          it 'has version label' do
            within 'main header h2.current' do
              expect(page).to have_css('span.eui-badge--sm.umm-version-label')
              expect(page).to have_content('v2.34')
            end
          end

          it 'has the correct header tab links' do
            within 'main header' do
              expect(page).to have_content('Manage Collections')
              expect(page).to have_content('Manage Variables')
              expect(page).to have_content('Manage Services')
              expect(page).to have_content('Manage Tools')
              expect(page).to have_content('Manage CMR')

              expect(page).to have_no_content('Manage Proposals')
              expect(page).to have_no_content('Manage Collection Proposals')
            end
          end

          it 'does not display the badge for MMT for Non-NASA users' do
            within 'header.mmt-header' do
              expect(page).to have_no_content('Non-NASA Users')
            end
          end
        end

        context 'from the Manage Variables page' do
          before do
            visit manage_variables_path
          end

          it 'has "Manage Variables" as the underlined current header link' do
            within 'main header' do
              expect(page).to have_css('h2.current', text: 'Manage Variables')
            end
          end

          it 'has version label' do
            within 'main header h2.current' do
              expect(page).to have_css('span.eui-badge--sm.umm-version-label')
              expect(page).to have_content('v3.45')
            end
          end

          it 'has the correct header tab links' do
            within 'main header' do
              expect(page).to have_content('Manage Collections')
              expect(page).to have_content('Manage Variables')
              expect(page).to have_content('Manage Services')
              expect(page).to have_content('Manage Tools')
              expect(page).to have_content('Manage CMR')

              expect(page).to have_no_content('Manage Proposals')
              expect(page).to have_no_content('Manage Collection Proposals')
            end
          end

          it 'does not display the badge for MMT for Non-NASA users' do
            within 'header.mmt-header' do
              expect(page).to have_no_content('Non-NASA Users')
            end
          end
        end

        context 'from the Manage Services page' do
          before do
            visit manage_services_path
          end

          it 'has "Manage Services" as the underlined current header link' do
            within 'main header' do
              expect(page).to have_css('h2.current', text: 'Manage Services')
            end
          end

          it 'has version label' do
            within 'main header h2.current' do
              expect(page).to have_css('span.eui-badge--sm.umm-version-label')
              expect(page).to have_content('v4.56')
            end
          end

          it 'has the correct header tab links' do
            within 'main header' do
              expect(page).to have_content('Manage Collections')
              expect(page).to have_content('Manage Variables')
              expect(page).to have_content('Manage Services')
              expect(page).to have_content('Manage Tools')
              expect(page).to have_content('Manage CMR')

              expect(page).to have_no_content('Manage Proposals')
              expect(page).to have_no_content('Manage Collection Proposals')
            end
          end

          it 'does not display the badge for MMT for Non-NASA users' do
            within 'header.mmt-header' do
              expect(page).to have_no_content('Non-NASA Users')
            end
          end
        end

        context 'from the Manage Tools page' do
          before do
            visit manage_tools_path
          end

          it 'has "Manage Tools" as the underlined current header link' do
            within 'main header' do
              expect(page).to have_css('h2.current', text: 'Manage Tools')
            end
          end

          it 'has version label' do
            within 'main header h2.current' do
              expect(page).to have_css('span.eui-badge--sm.umm-version-label')
              expect(page).to have_content('v5.67')
            end
          end

          it 'has the correct header tab links' do
            within 'main header' do
              expect(page).to have_content('Manage Collections')
              expect(page).to have_content('Manage Variables')
              expect(page).to have_content('Manage Services')
              expect(page).to have_content('Manage Tools')
              expect(page).to have_content('Manage CMR')

              expect(page).to have_no_content('Manage Proposals')
              expect(page).to have_no_content('Manage Collection Proposals')
            end
          end

          it 'does not display the badge for MMT for Non-NASA users' do
            within 'header.mmt-header' do
              expect(page).to have_no_content('Non-NASA Users')
            end
          end
        end

        context 'from the Manage Cmr page' do
          before do
            visit manage_cmr_path
          end

          it 'has "Manage CMR" as the underlined current header link' do
            within 'main header' do
              expect(page).to have_css('h2.current', text: 'Manage CMR')
            end
          end

          it 'has the correct header tab links' do
            within 'main header' do
              expect(page).to have_content('Manage Collections')
              expect(page).to have_content('Manage Variables')
              expect(page).to have_content('Manage Services')
              expect(page).to have_content('Manage Tools')
              expect(page).to have_content('Manage CMR')

              expect(page).to have_no_content('Manage Proposals')
              expect(page).to have_no_content('Manage Collection Proposals')
            end
          end

          it 'does not display the badge for MMT for Non-NASA users' do
            within 'header.mmt-header' do
              expect(page).to have_no_content('Non-NASA Users')
            end
          end
        end

        context 'when clicking the profile link' do
          before do
            visit manage_collections_path
            click_on 'profile-link'
          end

          it 'displays the User Info Dropdown Menu with the correct links' do
            within '#login-info' do
              expect(page).to have_link('Change Provider')
              expect(page).to have_link("User's Guide", href: 'https://wiki.earthdata.nasa.gov/display/CMR/Metadata+Management+Tool+%28MMT%29+User%27s+Guide')
              expect(find_link("User's Guide")[:target]).to eq('_blank')
              expect(page).to have_link('Logout', href: logout_path)
            end
          end
        end
      end

      context 'when the user has Draft MMT Approver permissions' do
        before do
          allow_any_instance_of(PermissionChecking).to receive(:is_non_nasa_draft_approver?).and_return(true)
        end

        context 'from the Manage Proposals page' do
          before do
            visit manage_proposals_path
          end

          it 'has "Manage Proposals" as the underlined current header link' do
            within 'main header' do
              expect(page).to have_css('h2.current', text: 'Manage Proposals')
            end
          end

          it 'has the correct header tab links' do
            within 'main header' do
              expect(page).to have_content('Manage Collections')
              expect(page).to have_content('Manage Variables')
              expect(page).to have_content('Manage Services')
              expect(page).to have_content('Manage Tools')
              expect(page).to have_content('Manage CMR')
              expect(page).to have_content('Manage Proposals')

              expect(page).to have_no_content('Manage Collection Proposals')
            end
          end

          it 'does not display the badge for MMT for Non-NASA users' do
            within 'header.mmt-header' do
              expect(page).to have_no_content('Non-NASA Users')
            end
          end
        end
      end
    end

    context 'when proposal mode is turned on' do
      before do
        set_as_proposal_mode_mmt(with_required_acl: true)
      end

      context 'from the Manage Collections page' do
        before do
          visit manage_collection_proposals_path
        end

        it 'has "Manage Collection Proposals" as the underlined current header link' do
          within 'main header' do
            expect(page).to have_css('h2.current', text: 'Manage Collection Proposals')
          end
        end

        it 'has the correct header tab links' do
          within 'main header' do
            expect(page).to have_content('Manage Collection Proposals')

            expect(page).to have_no_content('Manage Collections')
            expect(page).to have_no_content('Manage Variables')
            expect(page).to have_no_content('Manage Services')
            expect(page).to have_no_content('Manage Tools')
            expect(page).to have_no_content('Manage CMR')
            expect(page).to have_no_content('Manage Proposals')
          end
        end

        it 'indicates that the user is using the MMT for Non-Nasa Users' do
          within 'header.mmt-header' do
            expect(page).to have_content('Non-NASA Users')
          end
        end
      end
    end
  end
end
