$errorcode=0;$totmytime=0;$totstdtime=0;
[Console]::TreatControlCAsInput = $True;
while (!$errorcode) {
    If ($Host.UI.RawUI.KeyAvailable -and ($Key = $Host.UI.RawUI.ReadKey("AllowCtrlC,NoEcho,IncludeKeyUp"))) {
        If ([Int]$Key.Character -eq 3) {
            Write-Host "KeyboardInterrupted" -ForegroundColor Red;
            [Console]::TreatControlCAsInput = $False;
            break;
        }
    }
    ./random | Out-File data.in;
    $sw1 = [Diagnostics.Stopwatch]::StartNew();
    Get-Content data.in | ./my | Out-File my.out;
    $my_code=$LASTEXITCODE;
    $sw1.Stop();
    $sw2 = [Diagnostics.Stopwatch]::StartNew();
    Get-Content data.in | ./std | Out-File std.out;
    $std_code=$LASTEXITCODE;
    $sw2.Stop();
    Write-Host "No difference" -BackgroundColor Green;
    Write-Host ("my.exe finished with exit code "+$my_code+" within "+$sw1.Elapsed.TotalMilliseconds+"ms");
    Write-Host ("std.exe finished with exit code "+$std_code+" within "+$sw2.Elapsed.TotalMilliseconds+"ms"),`n;
    $totmytime+=$sw1.Elapsed.TotalMilliseconds
    $totstdtime+=$sw2.Elapsed.TotalMilliseconds
    $my=Get-Content my.out;
    $std=Get-Content std.out;
    $errorcode=Compare-Object $my $std
}
if($errorcode){
    Write-Host "Error occurred:","******my.out******",$my,"******std.out******",$std,"******data.in*******",(Get-Content data.in) -Separator "`n"
    Write-Host "******finished******" -BackgroundColor Yellow -ForegroundColor Red
}
Write-Host ("my.exe used "+$totmytime+" ms") -ForegroundColor Gray
Write-Host ("std.exe used "+$totstdtime+" ms") -ForegroundColor Gray
Pause;