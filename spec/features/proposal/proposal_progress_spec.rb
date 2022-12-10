describe 'Viewing Progress Page for Collection Metadata Proposals', js: true do
  context 'when viewing the progress page as a user' do
    before do
      real_login(method: 'urs')
      set_as_proposal_mode_mmt(with_draft_user_acl: true)
      @collection_draft_proposal = create(:empty_collection_draft_proposal, user: get_user)
    end

    context 'when viewing an incomplete proposal in work' do
      before do
        visit progress_collection_draft_proposal_path(@collection_draft_proposal)
      end

      it 'displays the correct progress' do
        within '#timeline-create-submission' do
          expect(page).to have_content('In Work')
          expect(page).to have_css('div.timeline-node-active')
          expect(page).to have_css('div.timeline-line-faded-active')
          expect(page).to have_no_content('Submitted')
          expect(page).to have_no_content('By')
        end

        within '#timeline-review-submission' do
          expect(page).to have_css('p.timeline-stage-inactive', text: 'Approval')
          expect(page).to have_css('div.timeline-node-faded')
          expect(page).to have_css('div.timeline-line-faded')
        end
      end

      it 'displays the correct actions' do
        within '.progress-actions' do
          expect(page).to have_content('Make additional changes or submit this proposal for approval.')
          expect(page).to have_link('Submit for Review')
          expect(page).to have_link('Edit Proposal')
          expect(page).to have_link('Delete Proposal')
        end
      end

      context 'when trying to submit an incomplete proposal' do
        before do
          click_on 'Submit for Review'
        end

        it 'cannot be submitted' do
          expect(page).to have_content('This proposal is not ready to be submitted. Please use the progress indicators on the proposal preview page to address incomplete or invalid fields.')
        end
      end
    end

    context 'when viewing a submitted proposal' do
      before do
        mock_submit(@collection_draft_proposal)
        visit progress_collection_draft_proposal_path(@collection_draft_proposal)
      end

      it 'displays the correct progress' do
        within '#timeline-create-submission' do
          expect(page).to have_content('Submitted for Review')
          expect(page).to have_content('Submitted: 2019-10-11 01:00')
          expect(page).to have_content('By: TestUser1')
          expect(page).to have_css('div.timeline-node-active')
          expect(page).to have_css('div.timeline-line-active')
        end

        within '#timeline-review-submission' do
          expect(page).to have_css('p.timeline-stage-inactive', text: 'Approval')
          expect(page).to have_css('div.timeline-node-faded')
          expect(page).to have_css('div.timeline-line-faded')
        end
      end

      it 'displays the correct actions' do
        within '.progress-actions' do
          expect(page).to have_content('You may cancel this proposal to make additional changes.')
          expect(page).to have_link('Cancel Proposal Submission')

          expect(page).to have_no_link('Approve Proposal Submission')
          expect(page).to have_no_link('Reject Proposal Submission')
        end
      end
    end

    context 'when viewing an approved proposal' do
      before do
        mock_approve(@collection_draft_proposal)
        visit progress_collection_draft_proposal_path(@collection_draft_proposal)
      end

      it 'displays the correct progress' do
        within '#timeline-create-submission' do
          expect(page).to have_content('Submitted for Review')
          expect(page).to have_content('Submitted: 2019-10-11 01:00')
          expect(page).to have_content('By: TestUser1')
          expect(page).to have_css('div.timeline-node')
          expect(page).to have_css('div.timeline-line')
        end

        within '#timeline-review-submission' do
          expect(page).to have_content('Approved')
          expect(page).to have_content('Approved: 2019-10-11 02:00')
          expect(page).to have_content('By: TestUser2')
          expect(page).to have_css('div.timeline-node')
          expect(page).to have_css('div.timeline-line')
        end

        within '#timeline-waiting-to-publish' do
          expect(page).to have_css('p.timeline-stage', text: 'Ready to Publish')
          expect(page).to have_css('div.timeline-node-active')
          expect(page).to have_css('div.timeline-line-active')
        end
      end

      it 'displays the correct actions' do
        within '.progress-actions' do
          expect(page).to have_content('No actions are possible.')

          expect(page).to have_no_content('Please visit the Metadata Management Tool for NASA users to finish publishing this metadata.')
        end
      end
    end

    context 'when viewing a rejected proposal' do
      context 'when viewing a rescinded rejected proposal' do
        before do
          mock_rescind(@collection_draft_proposal)
          visit progress_collection_draft_proposal_path(@collection_draft_proposal)
        end

        it 'displays the correct progress' do
          within '#timeline-create-submission' do
            expect(page).to have_content('In Work')
            expect(page).to have_css('div.timeline-node-active')
            expect(page).to have_css('div.timeline-line-faded-active')
            expect(page).to have_no_content('Submitted')
            expect(page).to have_no_content('By')
          end

          within '#timeline-review-submission' do
            expect(page).to have_content('Rejected')
            expect(page).to have_content('Rejected: 2019-10-11 03:00')
            expect(page).to have_content('By: TestUser3')
            expect(page).to have_content('Reason(s): Misspellings/Grammar and Other')
            expect(page).to have_content('Note: Test Reason for rejecting a proposal')
            expect(page).to have_link('Click for full details')
            expect(page).to have_css('div.timeline-node-faded')
            expect(page).to have_css('div.timeline-line-faded-rejected')
          end
        end

        it 'displays the correct actions' do
          within '.progress-actions' do
            expect(page).to have_content('Make additional changes or submit this proposal for approval.')
            expect(page).to have_link('Submit for Review')
            expect(page).to have_link('Edit Proposal')
          end
        end

        context 'when viewing a rescinded rejected proposal that is then submitted' do
          before do
            mock_submit(@collection_draft_proposal)
            visit progress_collection_draft_proposal_path(@collection_draft_proposal)
          end

          it 'displays the correct progress' do
            within '#timeline-create-submission' do
              expect(page).to have_content('Submitted for Review')
              expect(page).to have_content('Submitted: 2019-10-11 01:00')
              expect(page).to have_content('By: TestUser1')
              expect(page).to have_css('div.timeline-node-active')
              expect(page).to have_css('div.timeline-line-active')
            end

            within '#timeline-review-submission' do
              expect(page).to have_css('p.timeline-stage-inactive', text: 'Approval')
              expect(page).to have_css('div.timeline-node-faded')
              expect(page).to have_css('div.timeline-line-faded')

              expect(page).to have_no_content('Rejected')
              expect(page).to have_no_content('Reason(s)')
              expect(page).to have_no_content('Note')
              expect(page).to have_no_link('Click for full details')
            end
          end

          it 'displays the correct actions' do
            within '.progress-actions' do
              expect(page).to have_content('You may cancel this proposal to make additional changes.')
              expect(page).to have_link('Cancel Proposal Submission')

              expect(page).to have_no_link('Approve Proposal Submission')
              expect(page).to have_no_link('Reject Proposal Submission')
            end
          end
        end
      end

      context 'when viewing a rejected proposal which has not been rescinded' do
        before do
          mock_reject(@collection_draft_proposal)
          visit progress_collection_draft_proposal_path(@collection_draft_proposal)
        end

        it 'displays the correct progress' do
          within '#timeline-create-submission' do
            expect(page).to have_content('Submitted for Review')
            expect(page).to have_css('div.timeline-node')
            expect(page).to have_css('div.timeline-line')
            expect(page).to have_content('Submitted: 2019-10-11 01:00')
            expect(page).to have_content('By: TestUser1')
          end

          within '#timeline-review-submission' do
            expect(page).to have_content('Rejected')
            expect(page).to have_content('Rejected: 2019-10-11 03:00')
            expect(page).to have_content('By: TestUser3')
            expect(page).to have_content('Reason(s): Misspellings/Grammar and Other')
            expect(page).to have_content('Note: Test Reason for rejecting a proposal')
            expect(page).to have_link('Click for full details')
            expect(page).to have_css('div.timeline-node-rejected')
            expect(page).to have_css('div.timeline-line-faded-rejected')
          end
        end

        it 'displays the correct actions' do
          within '.progress-actions' do
            expect(page).to have_content('You may cancel this proposal to make additional changes.')
            expect(page).to have_link('Cancel Proposal Submission')
          end
        end

        context 'when clicking on the link for full details' do
          before do
            within '#timeline-review-submission' do
              click_on 'Click for full details'
            end
          end

          it 'displays the modal with the rejection feedback' do
            within '#rejection-reasons-modal' do
              expect(page).to have_content('Reason(s): Misspellings/Grammar and Other')
              expect(page).to have_content('Note: Test Reason for rejecting a proposal')
            end
          end
        end
      end

      context 'when viewing a rejected proposal which has no feedback' do
        before do
          mock_reject(@collection_draft_proposal, false)
          visit progress_collection_draft_proposal_path(@collection_draft_proposal)
        end

        it 'displays the correct progress' do
          within '#timeline-create-submission' do
            expect(page).to have_content('Submitted for Review')
            expect(page).to have_css('div.timeline-node')
            expect(page).to have_css('div.timeline-line')
            expect(page).to have_content('Submitted: 2019-10-11 01:00')
            expect(page).to have_content('By: TestUser1')
          end

          within '#timeline-review-submission' do
            expect(page).to have_content('Rejected')
            expect(page).to have_content('Rejected: 2019-10-11 03:00')
            expect(page).to have_content('By: TestUser3')
            expect(page).to have_content('Reason(s): No Reason Provided')
            expect(page).to have_content('Note: No Notes Provided')
            expect(page).to have_link('Click for full details')
            expect(page).to have_css('div.timeline-node-rejected')
            expect(page).to have_css('div.timeline-line-faded-rejected')
          end
        end

        it 'displays the correct actions' do
          within '.progress-actions' do
            expect(page).to have_content('You may cancel this proposal to make additional changes.')
            expect(page).to have_link('Cancel Proposal Submission')
          end
        end

        context 'when clicking on the link for full details' do
          before do
            within '#timeline-review-submission' do
              click_on 'Click for full details'
            end
          end

          it 'displays the modal with the rejection feedback' do
            within '#rejection-reasons-modal' do
              expect(page).to have_content('Reason(s): No Reason Provided')
              expect(page).to have_content('Note: No Notes Provided')
            end
          end
        end
      end
    end

    context 'when viewing a done proposal' do
      before do
        mock_publish(@collection_draft_proposal)
        visit progress_collection_draft_proposal_path(@collection_draft_proposal)
      end

      it 'displays the correct progress' do
        within '#timeline-create-submission' do
          expect(page).to have_content('Submitted for Review')
          expect(page).to have_content('Submitted: 2019-10-11 01:00')
          expect(page).to have_content('By: TestUser1')
          expect(page).to have_css('div.timeline-node')
          expect(page).to have_css('div.timeline-line')
        end

        within '#timeline-review-submission' do
          expect(page).to have_content('Approved')
          expect(page).to have_content('Approved: 2019-10-11 02:00')
          expect(page).to have_content('By: TestUser2')
          expect(page).to have_css('div.timeline-node')
          expect(page).to have_css('div.timeline-line')
        end

        within '#timeline-waiting-to-publish' do
          expect(page).to have_css('p.timeline-stage', text: 'Ready to Publish')
          expect(page).to have_css('div.timeline-node')
          expect(page).to have_css('div.timeline-line')
        end

        within '#timeline-published' do
          expect(page).to have_css('p.timeline-stage', text: 'Published')
          expect(page).to have_css('div.timeline-node-active')
          expect(page).to have_content('Published: 2019-10-11 04:00')
          expect(page).to have_content('By: TestUser4')
        end
      end

      it 'displays the correct actions' do
        within '.progress-actions' do
          expect(page).to have_content('No actions are possible.')
        end
      end
    end
  end

  context 'when viewing the progress page as an approver' do
    before do
      login
      set_as_proposal_mode_mmt(with_draft_approver_acl: true)
      @collection_draft_proposal = create(:empty_collection_draft_proposal)
    end

    context 'when viewing an incomplete proposal in work' do
      before do
        visit progress_collection_draft_proposal_path(@collection_draft_proposal)
      end

      it 'displays the correct progress' do
        within '#timeline-create-submission' do
          expect(page).to have_content('In Work')
          expect(page).to have_css('div.timeline-node-active')
          expect(page).to have_css('div.timeline-line-faded-active')
          expect(page).to have_no_content('Submitted')
          expect(page).to have_no_content('By')
        end

        within '#timeline-review-submission' do
          expect(page).to have_css('p.timeline-stage-inactive', text: 'Approval')
          expect(page).to have_css('div.timeline-node-faded')
          expect(page).to have_css('div.timeline-line-faded')
        end
      end

      it 'displays the correct actions' do
        within '.progress-actions' do
          expect(page).to have_content('Make additional changes or submit this proposal for approval.')
          expect(page).to have_link('Submit for Review')
          expect(page).to have_link('Edit Proposal')
        end
      end

      it 'cannot be submitted' do
        click_on 'Submit for Review'
        expect(page).to have_content('This proposal is not ready to be submitted. Please use the progress indicators on the proposal preview page to address incomplete or invalid fields.')
      end
    end

    context 'when viewing a submitted proposal' do
      before do
        mock_submit(@collection_draft_proposal)
        visit progress_collection_draft_proposal_path(@collection_draft_proposal)
      end

      it 'displays the correct progress' do
        within '#timeline-create-submission' do
          expect(page).to have_content('Submitted for Review')
          expect(page).to have_content('Submitted: 2019-10-11 01:00')
          expect(page).to have_content('By: TestUser1')
          expect(page).to have_css('div.timeline-node-active')
          # expect(page).to have_css('div.timeline-line-faded-active')
          expect(page).to have_css('div.timeline-line-active')
        end

        within '#timeline-review-submission' do
          expect(page).to have_css('p.timeline-stage-inactive', text: 'Approval')
          expect(page).to have_css('div.timeline-node-faded')
          expect(page).to have_css('div.timeline-line-faded')
        end
      end

      it 'displays the correct actions' do
        within '.progress-actions' do
          expect(page).to have_link('Approve Proposal Submission')
          expect(page).to have_link('Reject Proposal Submission')
          expect(page).to have_link('Cancel Proposal Submission')

          expect(page).to have_no_content('You may rescind this proposal to make additional changes.')
        end
      end
    end

    context 'when viewing an approved proposal' do
      before do
        mock_approve(@collection_draft_proposal)
        visit progress_collection_draft_proposal_path(@collection_draft_proposal)
      end

      it 'displays the correct progress' do
        within '#timeline-create-submission' do
          expect(page).to have_content('Submitted for Review')
          expect(page).to have_content('Submitted: 2019-10-11 01:00')
          expect(page).to have_content('By: TestUser1')
          expect(page).to have_css('div.timeline-node')
          expect(page).to have_css('div.timeline-line')
        end

        within '#timeline-review-submission' do
          expect(page).to have_content('Approved')
          expect(page).to have_content('Approved: 2019-10-11 02:00')
          expect(page).to have_content('By: TestUser2')
          expect(page).to have_css('div.timeline-node')
          expect(page).to have_css('div.timeline-line')
        end

        within '#timeline-waiting-to-publish' do
          expect(page).to have_css('p.timeline-stage', text: 'Ready to Publish')
          expect(page).to have_css('div.timeline-node-active')
          expect(page).to have_css('div.timeline-line-active')
        end
      end

      it 'displays the correct actions' do
        within '.progress-actions' do
          expect(page).to have_content('Please visit the Metadata Management Tool for NASA users to finish publishing this metadata.')

          expect(page).to have_no_content('No actions are possible.')
        end
      end
    end

    context 'when viewing a rejected proposal' do
      context 'when viewing a rescinded rejected proposal' do
        before do
          mock_rescind(@collection_draft_proposal)
          visit progress_collection_draft_proposal_path(@collection_draft_proposal)
        end

        it 'displays the correct progress' do
          within '#timeline-create-submission' do
            expect(page).to have_content('In Work')
            expect(page).to have_css('div.timeline-node-active')
            expect(page).to have_css('div.timeline-line-faded-active')
            expect(page).to have_no_content('Submitted')
            expect(page).to have_no_content('By')
          end

          within '#timeline-review-submission' do
            expect(page).to have_content('Rejected')
            expect(page).to have_content('Rejected: 2019-10-11 03:00')
            expect(page).to have_content('By: TestUser3')
            expect(page).to have_content('Reason(s): Misspellings/Grammar and Other')
            expect(page).to have_content('Note: Test Reason for rejecting a proposal')
            expect(page).to have_link('Click for full details')
            expect(page).to have_css('div.timeline-node-faded')
            expect(page).to have_css('div.timeline-line-faded-rejected')
          end
        end

        it 'displays the correct actions' do
          within '.progress-actions' do
            expect(page).to have_content('Make additional changes or submit this proposal for approval.')
            expect(page).to have_link('Submit for Review')
            expect(page).to have_link('Edit Proposal')
          end
        end

        context 'when viewing a rescinded rejected proposal that is then submitted' do
          before do
            mock_submit(@collection_draft_proposal)
            visit progress_collection_draft_proposal_path(@collection_draft_proposal)
          end

          it 'displays the correct progress' do
            within '#timeline-create-submission' do
              expect(page).to have_content('Submitted for Review')
              expect(page).to have_content('Submitted: 2019-10-11 01:00')
              expect(page).to have_content('By: TestUser1')
              expect(page).to have_css('div.timeline-node-active')
              expect(page).to have_css('div.timeline-line-active')
            end

            within '#timeline-review-submission' do
              expect(page).to have_css('p.timeline-stage-inactive', text: 'Approval')
              expect(page).to have_css('div.timeline-node-faded')
              expect(page).to have_css('div.timeline-line-faded')

              expect(page).to have_no_content('Rejected')
              expect(page).to have_no_content('Reason(s)')
              expect(page).to have_no_content('Note')
              expect(page).to have_no_link('Click for full details')
            end
          end

          it 'displays the correct actions' do
            within '.progress-actions' do
              expect(page).to have_link('Approve Proposal Submission')
              expect(page).to have_link('Reject Proposal Submission')
              expect(page).to have_link('Cancel Proposal Submission')

              expect(page).to have_no_content('You may rescind this proposal to make additional changes.')
            end
          end
        end
      end

      context 'when viewing a rejected proposal which has not been rescinded' do
        before do
          mock_reject(@collection_draft_proposal)
          visit progress_collection_draft_proposal_path(@collection_draft_proposal)
        end

        it 'displays the correct progress' do
          within '#timeline-create-submission' do
            expect(page).to have_content('Submitted for Review')
            expect(page).to have_css('div.timeline-node')
            expect(page).to have_css('div.timeline-line')
            expect(page).to have_content('Submitted: 2019-10-11 01:00')
            expect(page).to have_content('By: TestUser1')
          end

          within '#timeline-review-submission' do
            expect(page).to have_content('Rejected')
            expect(page).to have_content('Rejected: 2019-10-11 03:00')
            expect(page).to have_content('By: TestUser3')
            expect(page).to have_content('Reason(s): Misspellings/Grammar and Other')
            expect(page).to have_content('Note: Test Reason for rejecting a proposal')
            expect(page).to have_link('Click for full details')
            expect(page).to have_css('div.timeline-node-rejected')
            expect(page).to have_css('div.timeline-line-faded-rejected')
          end
        end

        it 'displays the correct actions' do
          within '.progress-actions' do
            expect(page).to have_link('Cancel Proposal Submission')

            expect(page).to have_no_content('You may rescind this proposal to make additional changes.')
          end
        end

        context 'when clicking on the link for full details' do
          before do
            within '#timeline-review-submission' do
              click_on 'Click for full details'
            end
          end

          it 'displays the modal with the rejection feedback' do
            within '#rejection-reasons-modal' do
              expect(page).to have_content('Reason(s): Misspellings/Grammar and Other')
              expect(page).to have_content('Note: Test Reason for rejecting a proposal')
            end
          end
        end
      end
    end

    context 'when viewing a done proposal' do
      before do
        mock_publish(@collection_draft_proposal)
        visit progress_collection_draft_proposal_path(@collection_draft_proposal)
      end

      it 'displays the correct progress' do
        within '#timeline-create-submission' do
          expect(page).to have_content('Submitted for Review')
          expect(page).to have_content('Submitted: 2019-10-11 01:00')
          expect(page).to have_content('By: TestUser1')
          expect(page).to have_css('div.timeline-node')
          expect(page).to have_css('div.timeline-line')
        end

        within '#timeline-review-submission' do
          expect(page).to have_content('Approved')
          expect(page).to have_content('Approved: 2019-10-11 02:00')
          expect(page).to have_content('By: TestUser2')
          expect(page).to have_css('div.timeline-node')
          expect(page).to have_css('div.timeline-line')
        end

        within '#timeline-waiting-to-publish' do
          expect(page).to have_css('p.timeline-stage', text: 'Ready to Publish')
          expect(page).to have_css('div.timeline-node')
          expect(page).to have_css('div.timeline-line')
        end

        within '#timeline-published' do
          expect(page).to have_css('p.timeline-stage', text: 'Published')
          expect(page).to have_css('div.timeline-node-active')
          expect(page).to have_content('Published: 2019-10-11 04:00')
          expect(page).to have_content('By: TestUser4')
        end
      end

      it 'displays the correct actions' do
        within '.progress-actions' do
          expect(page).to have_content('No actions are possible.')
        end
      end
    end
  end

  context 'when viewing a complete draft' do
    # This works through enough of the workflow to verify that the helpers in
    # the controller are storing the time in a way that is retrievable
    before do
      real_login(method: 'urs')
      set_as_proposal_mode_mmt(with_draft_user_acl: true)
      @collection_draft_proposal = create(:full_collection_draft_proposal, user: get_user)
      visit progress_collection_draft_proposal_path(@collection_draft_proposal)
    end

    it 'can submit a proposal' do
      click_on 'Submit for Review'

      click_on 'No'

      visit progress_collection_draft_proposal_path(@collection_draft_proposal)

      within '.progress-actions' do
        expect(page).to have_link('Delete Proposal')
      end
    end
  end
end
