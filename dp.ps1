$errorcode=0
while (!$errorcode) {
    ./random | Out-File data.in;
    $sw1 = [Diagnostics.Stopwatch]::StartNew();
    Get-Content data.in | ./my | Out-File my.out;
    $my_code=$LASTEXITCODE;
    $sw1.Stop();
    $sw2 = [Diagnostics.Stopwatch]::StartNew();
    Get-Content data.in | ./std | Out-File std.out;
    $std_code=$LASTEXITCODE;
    $sw2.Stop();
    Write-Output ("my.exe finished with exit code "+$my_code+" within "+$sw1.Elapsed.TotalMilliseconds+"ms");
    Write-Output ("std.exe finished with exit code "+$std_code+" within "+$sw2.Elapsed.TotalMilliseconds+"ms"),"";
    $my=Get-Content my.out;
    $std=Get-Content std.out;
    $errorcode=Compare-Object $my $std
}
Write-Output ("Error occurred:"),("******my.out******"),$my,("******std.out******"),$std,("******data.in*******"),(Get-Content data.in),"******finished******"
Pause