-- messagesテーブルに保存対象フラグを追加
ALTER TABLE messages ADD COLUMN is_export boolean DEFAULT false;
