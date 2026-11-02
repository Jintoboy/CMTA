# Generate 3 placeholder MTA inbound departure WAV files
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
    # 1. Manufacturing West -> Office Plaza
    "S_MTA_Dep_MFWest_To_Office.wav"     = "This is an Office Plaza-bound Manufacturing tram. The next stop is... Office Sector Plaza."

    # 2. Mines -> Office Plaza
    "S_MTA_Dep_Mines_To_Office.wav"      = "This is an Office Plaza-bound Mines tram. The next stop is... Office Sector Plaza."

    # 3. Hydroplant -> Office Plaza
    "S_MTA_Dep_Hydroplant_To_Office.wav" = "This is an Office Plaza-bound Hydroplant tram. The next stop is... Office Sector Plaza."
}

foreach ($entry in $clips.GetEnumerator()) {
    $filePath = Join-Path $outDir $entry.Key
    $synth.SetOutputToWaveFile($filePath, $format)
    $synth.Speak($entry.Value)
    $synth.SetOutputToNull()
    Write-Host "Generated: $($entry.Key)"
}

# Also generate Dam alias copy
Copy-Item -Path (Join-Path $outDir "S_MTA_Dep_Hydroplant_To_Office.wav") -Destination (Join-Path $outDir "S_MTA_Dep_Dam_To_Office.wav") -Force

Write-Host "All inbound departure placeholder audio files generated successfully."
