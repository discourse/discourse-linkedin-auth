# frozen_string_literal: true
class RemoveOldLinkedinData < ActiveRecord::Migration[6.1]
  def up
    execute "DELETE FROM oauth2_user_infos WHERE provider = 'linkedin'"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
