# Tripl3Slicer

AKA Cut lyrics cut songs cut words to make some anki cloze cards.

I made this impatiently for personal use hence the poor documentation and
distressing use of hardcoded paths and anki variables.

This Ruby script trims audio files based on timestamped lyrics and exports the
clips for language learning. The process is interactive. A prompt asks whether
you want to keep the line or not. If yes, you select which words to cloze
delete. At the end, or with early exit, anki cloze cards are generated using the
selected lines, with the audio slice on the card back.

## Usage

The script accepts the following command line arguments:

```
-l, --lyrics LYRICS: Path to the .lrc lyrics file
-s, --song SONG: Path to the .mp3 song file
-d, --output OUTPUT: Path to output directory
-b, --buffer BUFFER: Buffer duration in seconds (padding to audio ends)
```

Example:

```
ruby main.rb -l lyrics.lrc -s song.mp3 -o output
```

The lyrics file should be formatted with timestamps on each line like:

[00:12.34] This is the first line of lyrics
[00:17.56] This is the second line

The script will trim the song at the specified timestamps and export each clip
as song_card_ln_1.mp3, song_card_ln_2.mp3, etc.

The output is a csv file of the cloze cards, and the trimmed audio clips
(currently these are auto moved to anki media folder). From here there are two
options for import to anki:

- Import the cards to anki manually using the output csv, and manually copy the
  audio files into the anki media folder if the auto move didn't work
- Or, attempt to run the automatic anki import with `send_to_anki.rb`

## Requirements

- Ruby
- Anki desktop app installed
- MP3/audio files and corresponding lyric files
- Implementation Details
- Uses the ruby-audio gem for trimming MP3s

## Tips

Besides the obvious, clozing unknown words, I also like to cloze:

- Known verbs with unfamiliar conjugations,
- Known words in unfamiliar contexts
- Words and conjugations that are commonly used and I understand, but I don't
  have the confidence or familiarity to use them in conversation.

First review in anki:

- Double check that the word is correct - sometimes the lyrics are wrong so
  cross check if a word seems strange
- Check the words meaning and usage
- Add notes to the card back if it's difficult or uses unfamiliar grammar
- Make sure I understand the overall meaning of the sentence
