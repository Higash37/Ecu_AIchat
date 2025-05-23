-- messagesテーブルにuser_idカラム（uuid型）を追加
ALTER TABLE messages ADD COLUMN user_id uuid;
-- 必要に応じてNOT NULL制約やデフォルト値、外部キー制約を追加してください
-- 例: ALTER TABLE messages ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id);
