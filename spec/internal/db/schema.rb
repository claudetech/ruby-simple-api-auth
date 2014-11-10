ActiveRecord::Schema.define version: 0 do
  create_table :authenticable_models do |t|
    t.string :saa_key
    t.string :saa_secret
  end
  add_index :authenticable_models, :saa_key, unique: true
end
