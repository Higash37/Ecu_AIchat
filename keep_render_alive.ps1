# RenderサーバーにPingを送信して、スリープ状態を防止するスクリプト

$renderUrl = "https://aiedu-backend.onrender.com/chat"  # 実際のRenderのURLに変更してください
$intervalMinutes = 14  # 14分ごとにリクエスト（15分のスリープタイマーより少し短く）

Write-Host "Render起動維持スクリプトを開始します..."
Write-Host "対象URL: $renderUrl"
Write-Host "間隔: $intervalMinutes 分ごと"
Write-Host "Ctrl+Cで終了できます"
Write-Host "----------------------------------"

try {
    while ($true) {
        $timestamp = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
        Write-Host "$timestamp - Renderサーバーにリクエスト送信中..."
        
        try {
            $response = Invoke-WebRequest -Uri $renderUrl -Method GET -TimeoutSec 30
            Write-Host "応答: ステータスコード $($response.StatusCode)"
        }
        catch {
            Write-Host "エラー: $_" -ForegroundColor Red
        }
        
        Write-Host "$intervalMinutes 分間スリープします..."
        Start-Sleep -Seconds ($intervalMinutes * 60)
    }
}
finally {
    Write-Host "スクリプトが終了しました" -ForegroundColor Yellow
}
