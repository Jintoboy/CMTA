Add-Type -AssemblyName System.Speech
$engine = New-Object System.Speech.Recognition.SpeechRecognitionEngine
$engine.LoadGrammar((New-Object System.Speech.Recognition.DictationGrammar))
$engine.SetInputToWaveFile('C:\Users\vczle\Documents\Abiotic Factor Mods\CMTA\PlaceholderAudio\CascadeLabs\S_MTA_Arr_OfficePlaza_Containment.wav')

while ($true) {
    $r = $engine.Recognize()
    if ($r -eq $null) { break }
    Write-Host "Chunk: $($r.Text) (Confidence: $($r.Confidence))"
}
