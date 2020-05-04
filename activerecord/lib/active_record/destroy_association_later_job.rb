# frozen_string_literal: true

module ActiveRecord
  class DestroyAssociationLaterError < StandardError
  end

  # Job to destroy the records associated with a destroyed record in background.
  class DestroyAssociationLaterJob < ActiveJob::Base
    queue_as { ActiveRecord::Base.queues[:destroy] }

    discard_on ActiveJob::DeserializationError

    def perform(
      owner_model_name: nil, owner_id: nil,
      association_class: nil, association_ids: nil, association_primary_key_column: nil,
      owner_ensuring_destroy_method: nil
    )
      association_model = association_class.constantize
      owner_class = owner_model_name.constantize
      owner = owner_class.find_by(owner_class.primary_key.to_sym => owner_id)

      if !owner_destroyed?(owner, owner_ensuring_destroy_method)
        raise DestroyAssociationLaterError, "owner record not destroyed"
      end

      association_model.where(association_primary_key_column => association_ids).find_each do |r|
        r.destroy
      end
    end

    private
      def owner_destroyed?(owner, owner_ensuring_destroy_method)
        !owner ||
          (owner_ensuring_destroy_method && owner.public_send(owner_ensuring_destroy_method))
      end
  end
end
