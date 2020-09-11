module Approval
  module ActsAsResource
    extend ActiveSupport::Concern

    included do
      class_attribute :approval_ignore_fields
      self.approval_ignore_fields = %w[id created_at updated_at lock_version]

      has_many :approval_items, class_name: :"Approval::Item", as: :resource
    end

    class_methods do
      def assign_ignore_fields(ignore_fields = [])
        self.approval_ignore_fields = approval_ignore_fields.concat(ignore_fields).map(&:to_s).uniq
      end
    end

    def create_params_for_approval
      results = changing_attributes(self) #.except(*approval_ignore_fields)
byebug
      self.class.reflect_on_all_associations.each do |assoc|
        attribute_name = assoc.name.to_s + '_attributes'
        next unless respond_to?("#{attribute_name}=") # accept_nested_attributes_for がある場合に限定

        child = self.send(assoc.name)
        child_attributes = if assoc.collection?
          child.map {|c| changing_attributes(c) } # has_many, habtm, ...
        else
          changing_attributes(child) # has_one, belongs_to
        end
        results.store(attribute_name, child_attributes)
      end
      results
    end

    def update_params_for_approval
      create_params_for_approval
    end

    def changing_attributes(target)
      results = if target.new_record?
        target.attributes
      else
        ch = target.changes.each_with_object({}) {|(k, v), h| h[k] = v.last }
        ch = ch.merge(id: target.id) if self != target # 子データなら id もキープ。新規でも必要。
        ch
      end
      results['_destroy'] = true if target.marked_for_destruction?
      results.except(*approval_ignore_child_fields) # 親も idキープしたほうがいい
      # results
    end

    def approval_ignore_child_fields
      self.approval_ignore_fields - ['id']
    end
  end
end