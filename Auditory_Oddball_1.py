import json
import os
from pydub import AudioSegment
from pydub.playback import play
import random
from pylsl import StreamInfo, StreamOutlet
import time
import winsound

#soundfile1 = "C:/Users/belab/OneDrive - Florida Institute of Technology/Documents/Florida Tech/0_NeuroLab/LiveAmp_pilot_study/tone_100Hz.wav"
#soundfile2 = "C:/Users/belab/OneDrive - Florida Institute of Technology/Documents/Florida Tech/0_NeuroLab/LiveAmp_pilot_study/tone_50Hz.wav"
soundfile1 = "../Audio/Oddball_Audio/dev_v1.wav"
soundfile2 = "../Audio/Oddball_Audio/std_v1.wav"


# Define the LSL stream info
info = StreamInfo(name='Markers', type='Markers', channel_count=1, nominal_srate=0, channel_format='int32', source_id='marker_stream')

# Create the outlet to stream the data
outlet = StreamOutlet(info)
marker_std = 0
marker_dev = 1

# Iterations that the oddball sound will be played
special_indices = [5, 7, 11, 20, 23, 26, 31, 37, 48, 53,
                   62, 65, 73, 74, 77, 79, 82, 86, 88, 92,
                   94, 97, 99, 101, 104, 107, 109, 113, 115, 118,
                   121, 127, 132, 134, 141, 156, 168, 175, 193, 199]

input("Press Enter to continue...")

for i in range(1, 201):
    isi = 1.5 + (random.randint(1, 9) / float(10)) # Interstimulus interval
    b = isi - 0.6

    print(f"Iteration {i}: ISI = {isi:.2f}, b = {b:.2f}")

    if i in special_indices:
        print(f"Playing soundfile1: {soundfile1}")
        winsound.PlaySound(soundfile1, winsound.SND_FILENAME | winsound.SND_ASYNC)
        outlet.push_sample([marker_dev])
        time.sleep(0.600)
        time.sleep(b)
    else:
        print(f"Playing soundfile2: {soundfile2}")
        winsound.PlaySound(soundfile2, winsound.SND_FILENAME | winsound.SND_ASYNC)
        outlet.push_sample([marker_std])
        time.sleep(0.600)
        time.sleep(b)

    print("Sound played and sleep completed\n")