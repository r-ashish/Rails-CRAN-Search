class CreateJoinTableUsersPackages < ActiveRecord::Migration[5.2]
  def change
    create_join_table :users, :packages do |t|
      # t.index [:user_id, :package_id]
      # t.index [:package_id, :user_id]
    end
  end
end
