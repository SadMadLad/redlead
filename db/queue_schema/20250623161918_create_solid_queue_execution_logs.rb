class CreateSolidQueueExecutionLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_queue_execution_logs do |t|
      t.text :description
      t.string :job_class, null: false
      t.jsonb :args

      t.timestamps
    end
  end
end
