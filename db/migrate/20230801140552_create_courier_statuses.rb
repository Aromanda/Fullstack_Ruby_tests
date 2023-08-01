class CreateCourierStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :courier_statuses do |t|
      t.string :name, null: false
      t.timestamps
    end
    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO courier_statuses (name, created_at, updated_at) VALUES ('free', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
          INSERT INTO courier_statuses (name, created_at, updated_at) VALUES ('busy', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
          INSERT INTO courier_statuses (name, created_at, updated_at) VALUES ('full', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
          INSERT INTO courier_statuses (name, created_at, updated_at) VALUES ('offline', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
        SQL
      end
    end
  end
end