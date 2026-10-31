# Generate 6 placeholder MTA announcement WAV files for the remaining 3 Office Plaza trams
# Format: 44.1 kHz, 16-bit, Mono PCM

$outDir = "C:\Users\vczle\Documents\Abiotic Factor Mods\CMTA\PlaceholderAudio\CascadeLabs"
if (!(Test-Path $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}

Add-Type -AssemblyName System.Speech
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$synth.SelectVoice("Microsoft David Desktop")
$synth.Rate = 0

$format = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(44100, [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen, [System.Speech.AudioFormat.AudioChannel]::Mono)

$clips = @{
    # 1. Manufacturing West Line
    "S_MTA_Dep_Office_To_MFWest.wav"     = "This is a Manufacturing West-bound tram. The next stop is... Manufacturing West."
    "S_MTA_Arr_MFWest.wav"                = "This is... Manufacturing West."

    # 2. Mines Line
    "S_MTA_Dep_Office_To_Mines.wav"      = "This is a Mines-bound tram. The next stop is... The Mines."
    "S_MTA_Arr_Mines.wav"                 = "This is... The Mines."

    # 3. Hydroplant Line
    "S_MTA_Dep_Office_To_Hydroplant.wav" = "This is a Hydroplant-bound tram. The next stop is... Hydroplant."
    "S_MTA_Arr_Hydroplant.wav"            = "This is... Hydroplant."
}

foreach ($entry in $clips.GetEnumerator()) {
    $filePath = Join-Path $outDir $entry.Key
    $synth.SetOutputToWaveFile($filePath, $format)
    $synth.Speak($entry.Value)
    $synth.SetOutputToNull()
    Write-Host "Generated: $($entry.Key)"
}

# Also generate Dam alias copies for convenience
Copy-Item -Path (Join-Path $outDir "S_MTA_Dep_Office_To_Hydroplant.wav") -Destination (Join-Path $outDir "S_MTA_Dep_Office_To_Dam.wav") -Force
Copy-Item -Path (Join-Path $outDir "S_MTA_Arr_Hydroplant.wav") -Destination (Join-Path $outDir "S_MTA_Arr_Dam.wav") -Force

Write-Host "All placeholder audio files generated successfully."
