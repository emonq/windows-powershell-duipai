$errorcode=0;$totmytime=0;$totstdtime=0;
[Console]::TreatControlCAsInput = $True;

#Your random data genarator
$myrandom=python myrandom.py

foreach($i in Get-ChildItem -Filter *.cpp) {
    g++ $i.Name -o $i.BaseName;
    if($LASTEXITCODE) {
        $errorcode=$LASTEXITCODE;
        if($errorcode) {break;}
    }
}
while (!$errorcode) {
    If ($Host.UI.RawUI.KeyAvailable -and ($Key = $Host.UI.RawUI.ReadKey("AllowCtrlC,NoEcho,IncludeKeyUp"))) {
        If ([Int]$Key.Character -eq 3) {
            Write-Host "KeyboardInterrupted" -ForegroundColor Red;
            [Console]::TreatControlCAsInput = $False;
            break;
        }
    }
    $myrandom | Out-File data.in;
    if($?){Write-Host "data.in Generated" -ForegroundColor Green}
    else {
        Write-Host `r,"data.in Generation failed" -ForegroundColor Red
        break
    }
    $sw1 = [Diagnostics.Stopwatch]::StartNew();
    Get-Content data.in | ./my | Out-File my.out;
    $my_code=$LASTEXITCODE;
    $sw1.Stop();
    if($my_code){
        Write-Host "my.exe went wrong" -ForegroundColor Red
        break
    }
    Write-Host ("my.exe finished with exit code "+$my_code+" within "+$sw1.Elapsed.TotalMilliseconds+"ms");
    $sw2 = [Diagnostics.Stopwatch]::StartNew();
    Get-Content data.in | ./std | Out-File std.out;
    $std_code=$LASTEXITCODE;
    $sw2.Stop();
    Write-Host ("std.exe finished with exit code "+$std_code+" within "+$sw2.Elapsed.TotalMilliseconds+"ms");
    $totmytime+=$sw1.Elapsed.TotalMilliseconds
    $totstdtime+=$sw2.Elapsed.TotalMilliseconds
    $my=Get-Content my.out;
    $std=Get-Content std.out;
    if($my -and $std){$errorcode=Compare-Object $my $std}
    elseif (-not $my -and -not $std){$errorcode=0}
    else {$errorcode=1}
    if($errorcode){break}
    else {Write-Host "No difference" -ForegroundColor Green;}
}
if($errorcode){
    Write-Host "`nError occurred:","******my.out******",$my,"******std.out******",$std,"******data.in*******",(Get-Content data.in),`n -Separator "`n"
    Write-Host "`n******finished******" -BackgroundColor Yellow -ForegroundColor Red
}
Write-Host ("my used "+$totmytime+" ms") -ForegroundColor Gray
Write-Host ("std used "+$totstdtime+" ms") -ForegroundColor Gray
Pause;