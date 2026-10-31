Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$synth.SelectVoice("Microsoft David Desktop")
$synth.Rate = 0
$format = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(44100, [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen, [System.Speech.AudioFormat.AudioChannel]::Mono)

$outDir = "C:\Users\vczle\Documents\Abiotic Factor Mods\CMTA\PlaceholderAudio\CascadeLabs"

$clips = @{
    "S_MTA_Arr_OfficePlaza_MFWest.wav"     = "This is... Office Sector Plaza. Transfer is available to the Cascade Laboratories, Mines, and Hydroplant trams across the platform. Transfer is also available to the Reactors and Residences trams on the upper level."
    "S_MTA_Arr_OfficePlaza_Mines.wav"      = "This is... Office Sector Plaza. Transfer is available to the Manufacturing West, Cascade Laboratories, and Hydroplant trams across the platform. Transfer is also available to the Reactors and Residences trams on the upper level."
    "S_MTA_Arr_OfficePlaza_Hydroplant.wav" = "This is... Office Sector Plaza. Transfer is available to the Manufacturing West, Cascade Laboratories, and Mines trams across the platform. Transfer is also available to the Reactors and Residences trams on the upper level."
}

foreach ($entry in $clips.GetEnumerator()) {
    $filePath = Join-Path $outDir $entry.Key
    $synth.SetOutputToWaveFile($filePath, $format)
    $synth.Speak($entry.Value)
    $synth.SetOutputToNull()
    Write-Host "Generated: $($entry.Key)"
}

# Also generate Dam alias copy
Copy-Item -Path (Join-Path $outDir "S_MTA_Arr_OfficePlaza_Hydroplant.wav") -Destination (Join-Path $outDir "S_MTA_Arr_OfficePlaza_Dam.wav") -Force

Write-Host "Done."
