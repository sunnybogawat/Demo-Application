class AddFirstnameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
  end

  def self.down
    remove_column :user,:firs_tname
  end
end
