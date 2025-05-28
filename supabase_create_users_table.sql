-- Supabase usersテーブル（ニックネーム＋パスワード認証用）
create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  nickname text not null unique,
  password_hash text not null,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- messagesテーブルのuser_idをusers.idと外部キーで紐付け（既存messagesテーブルにuser_idカラムがある場合）
-- ALTER TABLE messages ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id);

-- 必要に応じて、chatテーブルにもuser_idを追加して分離可能に
-- ALTER TABLE chats ADD COLUMN user_id uuid;
-- ALTER TABLE chats ADD CONSTRAINT fk_chat_user FOREIGN KEY (user_id) REFERENCES users(id);
