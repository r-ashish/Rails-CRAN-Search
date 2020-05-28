class CreatePackages < ActiveRecord::Migration[5.2]
  def change
    create_table :packages do |t|
      t.string  :name
      t.string  :version
      t.string  :title
      t.text    :description
      t.datetime :publication_date
    end
  end
end
