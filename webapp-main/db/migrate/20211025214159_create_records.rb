class CreateRecords < ActiveRecord::Migration[6.1]
    def change
      create_table :records do |t|
        t.string :key_name
        t.string :result
  
        t.timestamps
      end
    end
  end