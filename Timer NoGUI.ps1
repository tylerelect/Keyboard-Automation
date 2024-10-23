# Define the duration of the timer in seconds
$durationSeconds = 300
# 325 sec = 5 min 25 sec
# 300 sec = 5 minutes
# 285 sec= 4min 45sec

# Path to the Alarm05.wav sound file (Jingle alarm)
$soundPath = "C:\Windows\Media\Alarm05.wav"

# Create a SoundPlayer object and point to the soundPath you want
$soundPlayer = New-Object System.Media.SoundPlayer
$soundPlayer.SoundLocation = $soundPath

# Start the countdown
for ($i = $durationSeconds; $i -gt 0; $i--) {
    Write-Host "$i seconds remaining" -ForegroundColor White
    Start-Sleep -Seconds 1
}

# Prints output and play the provided sound when the timer is up
Write-Host "Time's up!" -ForegroundColor Red
$soundPlayer.PlaySync() 