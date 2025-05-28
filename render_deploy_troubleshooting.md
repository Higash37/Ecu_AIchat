# Render デプロイで「build/web does not exist」エラーが発生した原因と解決方法まとめ

## 問題の概要

Flutter + Render（Static Site）構成で、

- 以前は正常にデプロイできていた
- ある時から「build/web does not exist」エラーでデプロイ失敗
  という現象が発生。

## 原因

1. **Render の Static Site ではビルドコマンドが使えない**

   - Render の Static Site タイプは、`flutter`コマンドなどのビルドツールがプリインストールされていない。
   - ビルドコマンドを指定しても `flutter: command not found` となり失敗する。

2. **Static Site ではビルド済み成果物が必須**

   - Static Site の場合、リポジトリに`build/web`（Flutter の Web ビルド成果物）が含まれていないとデプロイできない。
   - `build/web`がコミットされていない、または push 漏れがあると「build/web does not exist」エラーになる。

3. **.gitignore の設定ミスやコミット漏れも要注意**
   - `.gitignore`で`/build/*`を除外しつつ、`!/build/web`で`build/web`のみ管理対象にする必要がある。
   - これが正しく設定されていないと、`build/web`が Git に含まれない。

## 解決方法

1. ローカルで`flutter build web`を実行し、`build/web`を生成
2. `.gitignore`で`build/web`のみ Git 管理対象にする（`!/build/web` `!/build/web/**`）
3. `git add build/web && git commit -m "add build/web for Render deploy" && git push`でリモートに push
4. Render の「ビルドコマンド」は空欄、「Publish directory」は`build/web`に設定
5. これでデプロイが成功

## 補足

- Render の Static Site は「ビルド済みファイルをそのまま公開」する仕組み。ビルドコマンドは使えない。
- Flutter の Web ビルド成果物（build/web）は、アプリを更新するたびに再ビルド＆コミットが必要。
- Docker や Web Service タイプを使えば、ビルドコマンドを使った自動ビルドも可能。

## まとめ

- Static Site で Flutter アプリを Render にデプロイする場合は、**build/web を必ず Git 管理＆push**すること。
- ビルドコマンドは空欄で OK。
- .gitignore の設定とコミット漏れに注意。

---

この手順で「build/web does not exist」エラーは解消できます。
