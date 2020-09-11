module Approval
  module RequestForm
    class Create < Base
      private

        def prepare
          instrument "request" do |payload|
            ::Approval::Request.transaction do
              payload[:comment] = request.comments.new(user: user, content: reason)
              Array(records).each do |record|
                request.items.new(
                  event: "create",
                  resource_type: record.class.to_s,
                  params: record.create_params_for_approval,
                  #TODO: assign_ignore_fieldsを考慮した形でhash作成する
                  # params: record.create_params_for_approval,
                )
              end
              yield(request)
            end
          end
        end
    end
  end
end
