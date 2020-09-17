class CreateLinqDashboards < ActiveRecord::Migration[5.2]
  tag :postdeploy

  def change
    create_table :linq_dashboards do |t|
      t.string :title
      t.text :note
      t.date :completed

      t.timestamps
    end
  end
end
