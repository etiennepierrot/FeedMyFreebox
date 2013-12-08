class AddSessionTokenToFreeboxes < ActiveRecord::Migration
  def change
    add_column :freeboxes, :session_token, :string
  end
end
