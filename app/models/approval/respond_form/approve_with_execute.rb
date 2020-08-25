module Approval
  module RespondForm
    class ApproveWithExecute < Base
      validate :ensure_user_cannot_respond_to_my_request

      private

        def prepare
          instrument "approve_with_execute" do |payload|
            ::Approval::Request.transaction do
              request.lock!
              request.assign_attributes(state: :approved, approved_at: Time.current, respond_user: user)
              payload[:comment] = request.comments.new(user: user, content: reason)
              request.execute
              yield(request)
            end
          end
        end
    end
  end
end
