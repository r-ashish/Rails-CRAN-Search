class CreateContributors < ActiveRecord::Migration[5.2]
  def change
    create_table :contributors do |t|
      t.string :role

      t.references :package
      t.references :user
    end
  end
end
