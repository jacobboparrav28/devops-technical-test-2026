for ($i=1; $i -le 100; $i++) {
    try {
        $null = Invoke-RestMethod -Uri "devopstestapi2026.online/transaction"
        Write-Host "Peticion enviada exitosamente: $i" -ForegroundColor Green
    } catch {
        Write-Host "Peticion $i fallida (Error HTTP):" -ForegroundColor Red
    }
}

## Este script envía 100 peticiones HTTP a la API para generar tráfico y probar el escalado automático.