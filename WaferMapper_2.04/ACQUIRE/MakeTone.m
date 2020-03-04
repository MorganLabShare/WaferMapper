function MakeTone(SoundFrequency, SoundDuration, SoundAmplitude)
%SoundDuration = 2; %sec
%SoundFrequency = 1000; %Hz
%SoundAmplitude = 0.2;

SoundSamplingRate = 10000; %samples/sec
t = linspace(0, SoundDuration, SoundSamplingRate*SoundDuration);

SoundVector = SoundAmplitude*sin(2*pi*SoundFrequency*t);
sound(SoundVector,SoundSamplingRate);

