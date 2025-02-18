# frozen_string_literal: true

module GoodJob
  ACTIVE_RECORD_PARENT_CLASS = Object.const_get(GoodJob.active_record_parent_class)

  # Base ActiveRecord class that all GoodJob models inherit from.
  # Parent class can be configured with +GoodJob.active_record_parent_class+.
  # @!parse
  #   class BaseRecord < ActiveRecord::Base; end
  class BaseRecord < ACTIVE_RECORD_PARENT_CLASS
    self.abstract_class = true

    def self.migration_pending_warning!
      GoodJob.deprecator.warn(<<~DEPRECATION)
        GoodJob has pending database migrations. To create the migration files, run:
            rails generate good_job:update
        To apply the migration files, run:
            rails db:migrate
      DEPRECATION
      nil
    end

    # Checks for whether the schema is up to date.
    # Can be overriden by child class.
    # @return [Boolean]
    def self.migrated?
      return true if table_exists?

      migration_pending_warning!
      false
    end
  end
end
