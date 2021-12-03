# frozen_string_literal: true

class MigrateLinkedinUserInfo < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
    INSERT INTO user_associated_accounts (
      provider_name,
      provider_uid,
      user_id,
      info,
      last_used,
      created_at,
      updated_at
    ) SELECT
      'linkedin',
      uid,
      user_id,
      json_build_object('email', email, 'name', name),
      updated_at,
      created_at,
      updated_at
    FROM oauth2_user_infos
    WHERE provider = 'linkedin'
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
