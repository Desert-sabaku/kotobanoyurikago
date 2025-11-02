class AddConfirmableAndLockableToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :username, :string unless column_exists?(:users, :username)
    add_column :users, :admin, :boolean, default: false, null: false unless column_exists?(:users, :admin)

    # ## Confirmable (メール確認機能) 用のカラム
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string

    # ## Lockable (アカウントロック機能) 用のカラム
    add_column :users, :failed_attempts, :integer, default: 0, null: false
    add_column :users, :unlock_token, :string
    add_column :users, :locked_at, :datetime

    # ## インデックスの追加
    add_index :users, :username,             unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :unlock_token,         unique: true
  end
end
