import gin/sound
import gin/storage

type
    Sound* = object
        effect: ptr Audio
        name: string
        volume: cint
    SoundManager* = object
        sounds: seq[Sound]

proc initSound(path, name: string, volume: cint): Sound =
    result.effect = createAudio(getFullFilePath(path), 0, 255)
    result.name = name
    result.volume = volume

proc initSoundManager*(): SoundManager =
    result.sounds = @[]

proc add*(sm: var SoundManager, path, name: string, volume: cint) =
    sm.sounds.add(initSound(path, name, volume))

proc play*(sm: SoundManager, id: int) =
    playSoundFromMemory(sm.sounds[id].effect, sm.sounds[id].volume)
    
proc music*(sm: SoundManager, id: int) =
    playMusicFromMemory(sm.sounds[id].effect, sm.sounds[id].volume)
    
proc play*(sm: SoundManager, name: string) =
    for sound in sm.sounds:
        if sound.name == name:
            playSoundFromMemory(sound.effect, sound.volume)
            return
            
proc music*(sm: SoundManager, name: string) =
    for sound in sm.sounds:
        if sound.name == name:
            playMusicFromMemory(sound.effect, sound.volume)
            return
        