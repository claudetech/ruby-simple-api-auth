ActiveRecord::Schema.define version: 0 do
  create_table :authenticable_models do |t|
    t.string :ssa_key
    t.string :ssa_secret
  end
  add_index :authenticable_models, :ssa_key, unique: true
end
