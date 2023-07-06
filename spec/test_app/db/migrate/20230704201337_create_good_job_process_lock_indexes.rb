# frozen_string_literal: true
class CreateGoodJobProcessLockIndexes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    reversible do |dir|
      dir.up do
        # Ensure this incremental update migration is idempotent
        # with monolithic install migration.
        return if connection.index_name_exists?(:good_jobs, :index_good_jobs_jobs_on_priority_scheduled_at_when_unfinished_unlocked)

        if connection.index_name_exists?(:good_jobs, :index_good_jobs_on_active_job_id)
          remove_index :good_jobs, [:active_job_id], name: :index_good_jobs_on_active_job_id
        end
      end

      dir.down do
        add_index :good_jobs, [:active_job_id], name: :index_good_jobs_on_active_job_id
      end
    end

    add_index :good_jobs, [:priority, :scheduled_at],
      order: { priority: "ASC NULLS LAST", scheduled_at: :asc },
      where: "finished_at IS NULL AND locked_by_id IS NULL",
      name: :index_good_jobs_on_priority_scheduled_at_unfinished_unlocked,
      algorithm: :concurrently
    add_index :good_jobs, :locked_by_id,
      where: "locked_by_id IS NOT NULL",
      name: "index_good_jobs_on_locked_by_id",
      algorithm: :concurrently
    add_index :good_job_executions, [:process_id, :created_at],
      name: :index_good_job_executions_on_process_id_and_created_at,
      algorithm: :concurrently
  end
end
